import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crud_produto/model/ganhador.dart';

class GanhadorService {
  final String url = "https://applespace-a00ab-default-rtdb.firebaseio.com/ganhador";

  Future<void> salvarGanhador(Ganhador ganhador) async {
    try {
      // Ensure the Ganhador model has the sorteioNome field
      if (ganhador.toJson()['sorteioNome'] == null) {
        print("AVISO: ganhador não tem campo sorteioNome!");
      }
      
      final response = await http.post(
        Uri.parse("$url.json"),
        body: jsonEncode(ganhador.toJson()),
      );

      if (response.statusCode >= 400) {
        throw Exception("Failed to save winner: ${response.body}");
      }
      
      print("Ganhador salvo com sucesso: ${response.body}");
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
      
      print("Ganhadores limpos com sucesso");
    } catch (e) {
      print("Erro ao limpar ganhadores: $e");
      rethrow;
    }
  }
  
  // Add a method to get all winners
  Future<List<Map<String, dynamic>>> listarGanhadores() async {
    try {
      final response = await http.get(Uri.parse("$url.json"));
      
      if (response.statusCode == 200) {
        if (response.body == 'null' || response.body == '{}') {
          return [];
        }
        
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> ganhadores = [];
        
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            // Add the Firebase key to the data
            value['id'] = key;
            ganhadores.add(value);
          }
        });
        
        return ganhadores;
      }
      
      return [];
    } catch (e) {
      print("Erro ao listar ganhadores: $e");
      rethrow;
    }
  }

  // Update a winner to add the sorteioNome field
  Future<void> atualizarGanhador(String id, Map<String, dynamic> dados) async {
    try {
      final response = await http.patch(
        Uri.parse("$url/$id.json"),
        body: jsonEncode(dados),
      );

      if (response.statusCode >= 400) {
        throw Exception("Failed to update winner: ${response.body}");
      }
      
      print("Ganhador atualizado com sucesso");
    } catch (e) {
      print("Erro ao atualizar ganhador: $e");
      rethrow;
    }
  }

  // Use this method to check for any winner (regardless of sorteioNome)
  Future<String?> verificarQualquerGanhador() async {
    try {
      final response = await http.get(Uri.parse("$url.json"));
      
      if (response.statusCode == 200) {
        if (response.body == 'null' || response.body == '{}') {
          return null;
        }
        
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Get the first winner (if any exists)
        if (data.isNotEmpty) {
          final firstWinner = data.values.first;
          if (firstWinner is Map<String, dynamic> && 
              firstWinner.containsKey('nome')) {
            return firstWinner['nome'] as String?;
          }
        }
      }
      
      return null;
    } catch (e) {
      print("Erro ao verificar ganhador: $e");
      rethrow;
    }
  }
}