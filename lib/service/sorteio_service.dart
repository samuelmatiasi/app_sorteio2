import 'dart:convert';
import 'package:crud_produto/model/sorteio.dart';
import 'package:http/http.dart' as http;

class SorteioService {
  final String url = "https://applespace-a00ab-default-rtdb.firebaseio.com/sorteio/";

  Future<Sorteio?> carregarSorteio() async {
  try {
    final resp = await http.get(Uri.parse("$url.json"));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isNotEmpty && resp.body != 'null') {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        if (data.isNotEmpty) {
          final key = data.keys.first;
          final sorteio = Sorteio.fromJson(data[key]);
          sorteio.id = key;
          return sorteio;
        }
      }
    } else {
      print("Erro ao carregar: ${resp.statusCode} - ${resp.body}");
    }
  } catch (e) {
    print("Erro ao carregar sorteio: $e");
  }
  return null;
}


  Future<String?> incluirSorteio(Sorteio sorteio) async {
    try {
      final resp = await http.post(
        Uri.parse("$url.json"),
        body: jsonEncode(sorteio.toJson()),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        try {
          final data = jsonDecode(resp.body);
          if (data is Map<String, dynamic> && data.containsKey('name')) {
            return data['name'] as String;
          } else {
            print("Resposta inválida: $data");
            return null;
          }
        } catch (e) {
          print("Erro ao decodificar resposta: $e");
          return null;
        }
      } else {
        print("Erro ${resp.statusCode}: ${resp.body}");
        return null;
      }
    } catch (e) {
      print("Erro ao incluir sorteio: $e");
      return null;
    }
  }

  Future<void> deletarSorteio(String id) async {
    try {
      final resp = await http.delete(Uri.parse("$url/$id.json"));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print("Sorteio deletado.");
      } else {
        print("Erro ${resp.statusCode}: ${resp.body}");
      }
    } catch (e) {
      print("Erro ao deletar sorteio: $e");
    }
  }
}