// ganhador.dart
class Ganhador {
  final String id;
  final String nome;
  final String telefone;
  final String sorteioNome;
  final DateTime data;

  Ganhador({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.sorteioNome,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'telefone': telefone,
    'sorteioNome': sorteioNome,
    'data': data.toIso8601String(),
  };
}