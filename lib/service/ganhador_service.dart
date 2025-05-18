// ganhador_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crud_produto/model/ganhador.dart';

class GanhadorService {
  final String url = "https://crud-projeto-87237-default-rtdb.firebaseio.com/ganhador/";

  Future<void> salvarGanhador(Ganhador ganhador) async {
    try {
      final response = await http.post(
        Uri.parse("$url.json"),
        body: jsonEncode(ganhador.toJson()),
      );

      if (response.statusCode >= 400) {
        throw Exception("Failed to save winner: ${response.body}");
      }
    } catch (e) {
      print("Erro ao salvar ganhador: $e");
      rethrow;
    }
  }

   Future<void> limparGanhador() async {
    try {
      final resp = await http.delete(
        Uri.parse("$url.json"),
      );

      if (resp.statusCode >= 400) {
        throw Exception("Failed to clear winners: ${resp.body}");
      }
    } catch (e) {
      print("Erro ao limpar ganhadores: $e");
      rethrow;
    }
  }
}