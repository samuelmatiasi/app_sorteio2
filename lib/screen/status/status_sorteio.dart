import 'dart:async';

import 'package:flutter/material.dart';

import 'package:crud_produto/model/sorteio.dart';

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
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _carregarSorteio();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarSorteio() async {
    setState(() => _loading = true);
    final sorteio = await _sorteioService.carregarSorteio();

    if (sorteio != null && sorteio.createdAt != null) {
      final endTime = sorteio.createdAt!.add(sorteio.duration);
      final remaining = endTime.difference(DateTime.now());

      if (!remaining.isNegative) {
        _startCountdown(endTime);
        Timer(remaining, () async {
          if (mounted && sorteio.id != null) {
            await _sorteioService.deletarSorteio(sorteio.id!);
            if (mounted) {
              setState(() => _sorteio = null);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sorteio expirado e finalizado.")),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            }
          }
        });
      } else {
        await _sorteioService.deletarSorteio(sorteio.id!);
      }
    }

    setState(() {
      _sorteio = sorteio;
      _createdTime = sorteio?.createdAt;
      _remaining = _calculateRemaining();
      _loading = false;
    });
  }

  void _startCountdown(DateTime endTime) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = endTime.difference(now);
      if (diff.isNegative) {
        _countdownTimer?.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining = diff);
      }
    });
  }

  Duration _calculateRemaining() {
    if (_sorteio == null || _createdTime == null) return Duration.zero;
    final end = _createdTime!.add(_sorteio!.duration);
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
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
      _countdownTimer?.cancel();
      setState(() {
        _sorteio = null;
        _createdTime = null;
        _remaining = Duration.zero;
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

  String _formatDuration(Duration duration) {
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours.toString().padLeft(2, '0')}:$min:$sec';
  }

   @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _sorteio == null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Status do Sorteio Atual"),
          automaticallyImplyLeading: _sorteio == null, // Hide back button if sorteio exists
        ),
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
                                  Text("Tempo restante: ${_formatDuration(_remaining)}")
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
      ),
    );
  }
}
