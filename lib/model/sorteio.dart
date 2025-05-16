class Sorteio {
  String? id;
  String nome;
  String desc;
  String img;
  Duration duration;
  List<String> productIds;
  DateTime? createdAt; // <--- Add this

  Sorteio({
    this.id,
    required this.nome,
    required this.desc,
    required this.img,
    required this.duration,
    required this.productIds,
    this.createdAt,
  });

  // Add this to persist the creation time
  factory Sorteio.fromJson(Map<String, dynamic> map) {
    return Sorteio(
      id: map['id'],
      nome: map['nome'],
      desc: map['desc'],
      img: map['img'],
      duration: Duration(minutes: map['duration']),
      productIds: List<String>.from(map['productIds']),
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
      'img': img,
      'duration': duration.inMinutes,
      'productIds': productIds,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
