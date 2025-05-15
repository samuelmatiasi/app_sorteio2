import 'dart:async';
import 'package:crud_produto/screen/status/status_sorteio.dart';
import 'package:flutter/material.dart';
import 'package:crud_produto/model/produto.dart';
import 'package:crud_produto/model/sorteio.dart';
import 'package:crud_produto/service/produto_service.dart';
import 'package:crud_produto/service/sorteio_service.dart';
import 'package:crud_produto/screen/home_page.dart';

class StatusSorteio extends StatefulWidget {
  const StatusSorteio({super.key});

  @override
  State<StatusSorteio> createState() => _StatusSorteioState();
}

class _StatusSorteioState extends State<StatusSorteio> {
  final SorteioService _sorteioService = SorteioService();
  Sorteio? _sorteio;
  bool _loading = true;
  DateTime? _createdTime;

  @override
  void initState() {
    super.initState();
    _carregarSorteio();
  }

  Future<void> _carregarSorteio() async {
    setState(() => _loading = true);
    final sorteio = await _sorteioService.carregarSorteio();
    setState(() {
      _sorteio = sorteio;
      _loading = false;
    });
  }

  Future<void> _finalizarSorteio() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finalizar Sorteio"),
        content: const Text("Tem certeza que deseja finalizar o sorteio?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Finalizar"),
          ),
        ],
      ),
    );

    if (confirm == true && _sorteio != null) {
      await _sorteioService.deletarSorteio(_sorteio!.id!);
      setState(() {
        _sorteio = null;
        _createdTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sorteio finalizado com sucesso.")),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Duration _remainingTime() {
    if (_sorteio == null || _createdTime == null) return Duration.zero;
    final end = _createdTime!.add(_sorteio!.duration);
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Status do Sorteio Atual")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sorteio == null
              ? const Center(child: Text("Nenhum sorteio ativo encontrado."))
              : RefreshIndicator(
                  onRefresh: _carregarSorteio,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sorteio!.nome,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _sorteio!.desc,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.timer),
                                const SizedBox(width: 6),
                                Text("Tempo restante: ${_remainingTime().inMinutes} minutos")
                              ],
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _finalizarSorteio,
                              icon: const Icon(Icons.delete_forever),
                              label: const Text("Finalizar Sorteio"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
