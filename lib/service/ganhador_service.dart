// ganhador_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crud_produto/model/ganhador.dart';

class GanhadorService {
  final String baseUrl = "https://crud-projeto-87237-default-rtdb.firebaseio.com/ganhador";

  Future<void> salvarGanhador(Ganhador ganhador) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl.json"),
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
}