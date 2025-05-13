import 'dart:convert';

import 'package:crud_produto/model/produto.dart';

import 'package:http/http.dart' as http;

class ProdutoService {
  final String url = "https://crud-projeto-87237-default-rtdb.firebaseio.com/products";

Future<List<Produto>> carregarProdutos() async {
  var resp = await http.get(Uri.parse("$url.json"));
  List<Produto> produtos = [];

  try {
    if (resp.statusCode == 200 && resp.body.isNotEmpty && resp.body != 'null') {
      Map<String, dynamic> json = jsonDecode(resp.body);

      json.forEach((key, value) {
        Produto produto = Produto.fromJson(value);
        produto.id = key;
        produtos.add(produto);
      });
    } else {
      print("${resp.statusCode}: ${resp.body}");
    }
  } catch (e) {
    print("Erro ao carregar produtos: $e");
  }

  return produtos;
}

  Future<void> incluirProduto(Produto produto) async {
    var resp = await http.post(
      //post method
      Uri.parse("$url.json"), //the destination

      body: jsonEncode(produto.toJson()), //the content
    );

    if (resp.statusCode == 200) {
      //bem sucedido

      print("Incluído com sucesso");
    } else {
      print("${resp.statusCode}: ${resp.body}");
    }
  }

  Future<void> deletarProduto(String id) async {
    final resp = await http.delete(Uri.parse("${url}$id.json"));

    if (resp.statusCode == 200) {
      print("Produto deletado com sucesso");
    } else {
      print("${resp.statusCode}: ${resp.body}");
    }
  }
}
