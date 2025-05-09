import 'dart:convert';

import 'package:crud_produto/model/produto.dart';

import 'package:http/http.dart' as http;

class ProdutoService {
  final String url = "https://crud-projeto-87237-default-rtdb.firebaseio.com/";

  Future<void> incluirProduto(Produto produto) async {
    var resp = await http.post(//post method
      Uri.parse("$url.json"),//the destination

      body: jsonEncode(produto.toJson()),//the content 
    );

    if (resp.statusCode == 200) {
      //bem sucedido

      print("Incluído com sucesso");
    } else {
      print("${resp.statusCode}: ${resp.body}");
    }
  }

    Future<void> deletarProduto(Produto produto) async {
    var resp = await http.delete(
      Uri.parse("$url.json"),

      body: jsonEncode(produto.toJson()),
    );

    if (resp.statusCode == 200) {
      //bem sucedido

      print("Incluído com sucesso");
    } else {
      print("${resp.statusCode}: ${resp.body}");
    }
  }

  Future<List<Produto>> carregarProdutos() async {
    var resp = await http.get(Uri.parse("$url.json"));
    List<Produto> produtos = [];
    
    if (resp.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(resp.body);

      for (var mapProd in json.values) {
        produtos.add(Produto.fromJson(mapProd));
      }
    } else {
      print("${resp.statusCode}: ${resp.body}");
    }
    print(produtos);
    return produtos;
  }
}
