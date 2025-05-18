import 'dart:async';
import 'package:crud_produto/screen/status/status_sorteio.dart';
import 'package:flutter/material.dart';
import 'package:crud_produto/model/produto.dart';
import 'package:crud_produto/model/sorteio.dart';
import 'package:crud_produto/service/produto_service.dart';
import 'package:crud_produto/service/sorteio_service.dart';
import 'package:crud_produto/service/ganhador_service.dart';

class CriarSorteio extends StatefulWidget {
  const CriarSorteio({super.key});

  @override
  State<CriarSorteio> createState() => _CriarSorteioState();
}

class _CriarSorteioState extends State<CriarSorteio> {
  final ProdutoService _produtoService = ProdutoService();
  final SorteioService _sorteioService = SorteioService();
  final GanhadorService __ganhadorService = GanhadorService();
  List<Produto> _produtos = [];
  Set<String> _idProdutosSelecionados = {};
  int? _duracaoSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    final produtos = await _produtoService.carregarProdutos();
    setState(() {
      _produtos = produtos;
    });
  }

  Future<void> _criarSorteio() async {
    if (_idProdutosSelecionados.isEmpty || _duracaoSelecionada == null) return;

    final sorteio = Sorteio(
      nome: "Sorteio Automático",
      desc: "Sorteio criado automaticamente.",
      duracao: Duration(minutes: _duracaoSelecionada!),
      idProduto: _idProdutosSelecionados.toList(),
      createdAt: DateTime.now(), // <-- Crucial!
    );

    await _sorteioService.incluirSorteio(sorteio);

    Future.delayed(Duration(minutes: _duracaoSelecionada!), () async {
      if (sorteio.id != null) {
        await _sorteioService.deletarSorteio(sorteio.id!);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sorteio criado com sucesso!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StatusSorteio()),
    );
    await __ganhadorService.limparGanhador();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Sorteio")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Selecionar Produtos",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      ..._produtos.map((produto) {
                        return CheckboxListTile(
                          title: Text(produto.nome),
                          value: _idProdutosSelecionados.contains(produto.id),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _idProdutosSelecionados.add(produto.id!);
                              } else {
                                _idProdutosSelecionados.remove(produto.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Duração do Sorteio",
                  border: OutlineInputBorder(),
                ),
                value: _duracaoSelecionada,
                items:
                    [5, 10, 15, 20].map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value minutos"),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _duracaoSelecionada = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _criarSorteio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3700B3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "Criar Sorteio",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
