class Participante {
  final String id;
  final String nome;
  final String telefone;
  final String sorteioId;

  Participante({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.sorteioId,
  });

  factory Participante.fromJson(Map<String, dynamic> json, String id) {
    return Participante(
      id: id,
      nome: json['nome'] ?? '',
      telefone: json['telefone'] ?? '',
      sorteioId: json['sorteioId'] ?? '',
    );
  }
}