import 'dart:io';

import 'package:crud_produto/model/produto.dart';
import 'package:http/http.dart' as http;

import 'package:crud_produto/service/produto_service.dart';

import 'package:flutter/material.dart';

class InclusaoProduto extends StatelessWidget {
  InclusaoProduto({super.key});

  final TextEditingController nomeControler = TextEditingController();

  final TextEditingController descControler = TextEditingController();

  final TextEditingController imgControler = TextEditingController();

  final TextEditingController valorControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Produto"),

        backgroundColor: Colors.blue,
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8),

          child: Column(
            children: [
              TextField(
                controller: nomeControler,

                decoration: InputDecoration(
                  label: Text("nome"),

                  border: OutlineInputBorder(),
                ),
              ),

              TextField(
                controller: descControler,

                decoration: InputDecoration(
                  label: Text("descrição"),

                  border: OutlineInputBorder(),
                ),
              ),

              TextField(
                controller: imgControler,

                decoration: InputDecoration(
                  label: Text("endereço imagem"),

                  border: OutlineInputBorder(),
                ),
              ),

              TextField(
                controller: valorControler,

                decoration: InputDecoration(
                  label: Text("valor"),

                  border: OutlineInputBorder(),
                ),
              ),

              ElevatedButton(
                onPressed: () => incluirProduto(context),

                child: Text("Cadastrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> incluirProduto(BuildContext context) async {
    Produto produto = Produto(
      nome: nomeControler.text,

      desc: descControler.text,

      img: imgControler.text,

      valor: double.tryParse(valorControler.text),
    );

    if (await validarProduto(produto, context)) {
      ProdutoService produtoService = ProdutoService();

      produtoService.incluirProduto(produto);

      produtoService.carregarProdutos();
      Navigator.pop(context);
    } else {
      print("Erro ao validar");
    }
  }

void errorDialog(String e, String t, dynamic context ){
  showDialog(context: context,
   builder: (context) => AlertDialog(
    title: Text(e),
    content: Text(t),
    actions: [
      TextButton(
        onPressed: (){
          Navigator.pop(context);
          }, 
        child: Text("OK"))
    ]
   )
   
   );
}

  Future<bool> validarProduto(Produto produto, dynamic context ) async {
    String e ;
    String t;
   bool validacaoImagem = await validarImagem(produto.img);
    if (produto.nome.length < 3) 
    {
      e = "o nome deve conter no minimo 3 caractes";
      t = "Nome Invalido";
      errorDialog(t, e, context);
      return false; 
    }
    else if  (produto.desc.length < 10)   
    {
      e = "Descrição muito curta";
      t = "Descrição Invalida";
       errorDialog(e, t, context);
      return false; 
    }

    else if(validacaoImagem) 
    {
      e = "Imagem Invalida";
      t =  "endereço de imagem invalido " ;
       errorDialog(t, e, context);
      return false; 
    } 

    else if (produto.valor == null)
     {
      e = "Valor invalido";
      t =  "Atribua um valor ao produto" ;
       errorDialog(t, e, context);
      return false; 
    } ;

    return true;
  }

  Future<bool> validarImagem(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200 &&
          response.headers['content-type']?.startsWith('image/') == true) {
        return true;
      }
    } catch (e) {
      // Print/log the error if needed
    }
    return false;
  }
}
