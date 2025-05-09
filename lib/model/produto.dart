class Produto {
  int id = 0;

  String nome;

  String desc;

  String img;

  double? valor; //?: Pode ser nulo por enquanto

  Produto({
    required this.nome,

    required this.desc,

    required this.img,

    required this.valor,
  });

  //recebe um json e convert em objeto dart
  @override
  String toString () {
    return 'Produto{ nome: $nome, valor: $valor}';
  }

  // Método fromJson


  static fromJson(Map<String, dynamic> json) {
    return Produto(
      nome: json['nome'],

      desc: json['desc'],

      img: json['img'],

      valor: (json['valor'] as num).toDouble(),
    );
  }

  // Método toJson

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'desc': desc, 'img': img, 'valor': valor};
  }
}
