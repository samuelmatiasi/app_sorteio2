import 'dart:convert';
import 'package:http/http.dart' as http;// In SorteioService class
import 'package:crud_produto/model/participante.dart';

class ParticipanteService{
final String url = "https://applespace-a00ab-default-rtdb.firebaseio.com/participantes/";

Future<List<Participante>> carregarParticipantes(String sorteioId) async {
  try {
    final resp = await http.get(Uri.parse("$url/$sorteioId.json"));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isNotEmpty && resp.body != 'null') {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        return data.entries.map((entry) => Participante.fromJson(entry.value, entry.key)).toList();
      }
    } else {
      print("Erro ao carregar participantes: ${resp.statusCode}");
    }
  } catch (e) {
    print("Erro ao carregar participantes: $e");
  }
  return [];
}
}