import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crud_produto/model/produto.dart';
import 'package:crud_produto/model/sorteio.dart';
import 'package:crud_produto/service/produto_service.dart';
import 'package:crud_produto/service/sorteio_service.dart';

class CriarSorteio extends StatefulWidget {
  const CriarSorteio({super.key});

  @override
  State<CriarSorteio> createState() => _CriarSorteioState();
}

class _CriarSorteioState extends State<CriarSorteio> {
  final ProdutoService _produtoService = ProdutoService();
  final SorteioService _sorteioService = SorteioService();
  List<Produto> _produtos = [];
  Set<String> _selectedProductIds = {};
  int? _selectedDuration;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  Future<void> _loadProdutos() async {
    final produtos = await _produtoService.carregarProdutos();
    setState(() {
      _produtos = produtos;
    });
  }

  Future<void> _criarSorteio() async {
    if (_selectedProductIds.isEmpty || _selectedDuration == null) return;

    final sorteio = Sorteio(
      nome: _nomeController.text,
      desc: _descController.text,
      img: _imgController.text,
      duration: Duration(minutes: _selectedDuration!),
      productIds: _selectedProductIds.toList(),
    );

    await _sorteioService.incluirSorteio(sorteio);

    // schedule deletion
    Future.delayed(Duration(minutes: _selectedDuration!), () async {
      if (sorteio.id != null) {
        await _sorteioService.deletarSorteio(sorteio.id!);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sorteio criado com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Sorteio")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Nome do Sorteio"),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Descrição"),
              ),
              TextField(
                controller: _imgController,
                decoration: InputDecoration(labelText: "Imagem URL"),
              ),
              SizedBox(height: 20),
              ExpansionTile(
                title: Text("Selecionar Produtos (${_selectedProductIds.length})"),
                children: _produtos.map((produto) {
                  return CheckboxListTile(
                    title: Text(produto.nome),
                    value: _selectedProductIds.contains(produto.id),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedProductIds.add(produto.id!);
                        } else {
                          _selectedProductIds.remove(produto.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Duração (minutos)"),
                value: _selectedDuration,
                items: [5, 10, 15, 20].map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value minutos"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _criarSorteio,
                child: Text("Criar Sorteio"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
