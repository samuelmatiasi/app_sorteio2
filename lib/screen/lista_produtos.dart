import 'package:crud_produto/model/produto.dart';

import 'package:crud_produto/screen/inclusao_produto.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sorteio Aplle space"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(234, 96, 4, 182),),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirTelaIclusao,

        child: Icon(Icons.add_circle_outline_outlined),
      ),

      body:
          estaCarregando
              ? Center(child: CircularProgressIndicator())
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

                      trailing: Icon(Icons.delete), onTap: deleteProduto(produto),
                      
                    ),
                  );
                },
              ),
    );
  }

  void abrirTelaIclusao() async {
    await Navigator.push(
      context,

      MaterialPageRoute(builder: (context) => InclusaoProduto()),
    );

    carregaProdutos();
  }
}
