// ganhador.dart
class Ganhador {
  final String id;
  final String nome;
  final String telefone;
  final DateTime data;

  Ganhador({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'telefone': telefone,
    'data': data.toIso8601String(),
  };
}