class Sorteio {
  String? id;
  String nome;
  String desc;
  Duration duracao;
  List<String> idProduto;
  DateTime? createdAt; 

  Sorteio({
    this.id,
    required this.nome,
    required this.desc,
    required this.duracao,
    required this.idProduto,
    this.createdAt,
  });

  factory Sorteio.fromJson(Map<String, dynamic> map) {
    return Sorteio(
      id: map['id'],
      nome: map['nome'],
      desc: map['desc'],
      duracao: Duration(minutes: map['duration'] ?? 5),
      idProduto: List<String>.from(map['idProduto']),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'desc': desc,
      'duracao': duracao.inMinutes,
      'idProduto': idProduto,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
