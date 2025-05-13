import 'package:crud_produto/model/produto.dart';

import 'package:crud_produto/screen/produtos/inclusao_produto.dart';

import 'package:crud_produto/service/produto_service.dart';

import 'package:flutter/material.dart';

class ListaProdutos extends StatefulWidget {
  @override
  State<ListaProdutos> createState() => _ListaProdutosState();
}

class _ListaProdutosState extends State<ListaProdutos> {
  ProdutoService produtoService = ProdutoService();

  List<Produto> produtos = [];

  bool estaCarregando = true;

  void initState() {
    super.initState();

    carregaProdutos();
  }

  Future<void> carregaProdutos() async {
    produtos = await produtoService.carregarProdutos();

    setState(() {
      this.produtos = produtos;
    });

    estaCarregando = false;
  }

  void deleteProduto(Produto produto) async {
    await produtoService.deletarProduto(produto.id!);

    setState(() {
      produtos.remove(produto);
    });
  }

void abrirTelaIclusao() async {
  Produto? novoProduto = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => InclusaoProduto()),
  );

  if (novoProduto != null) {
    setState(() {
      produtos.add(novoProduto); // Only added locally
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sorteio Aplle space"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(234, 96, 4, 182),
      ),
      floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      heroTag: "add",
      onPressed: abrirTelaIclusao,
      child: Icon(Icons.add),
    ),
    SizedBox(height: 10),
    FloatingActionButton(
      heroTag: "register",
      backgroundColor: Colors.green,
      onPressed: registrarProdutos,
      child: Icon(Icons.cloud_upload),
    ),
  ],
),
      
      body: estaCarregando
    ? Center(child: CircularProgressIndicator())
    : produtos.isEmpty
        ? Center(
            child: Text(
              'Não há produtos para listar aqui.',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              Produto produto = produtos[index];
              return Card(
                child: ListTile(
                  leading: Image.network(produto.img, width: 50),
                  title: Text(
                    produto.nome,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Comic Sans",
                    ),
                  ),
                  subtitle: Text(produto.desc),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteProduto(produto),
                  ),
                ),
              );
            },
          ),
    );
  }

 void registrarProdutos() async {
  for (var produto in produtos) {
    if (produto.id == null) {
      await produtoService.incluirProduto(produto);
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Produtos registrados com sucesso!")),
  );

  // Recarrega do banco, caso deseje ver com IDs atualizados
  carregaProdutos();
}
}
