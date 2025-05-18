class Produto {
  String? id;
  String nome;
  String desc;
  String img;

  Produto({
    this.id,
    required this.nome,
    required this.desc,
    required this.img,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      nome: json['nome'],
      desc: json['desc'],
      img: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'desc': desc,
      'img': img,
    };
  }
}

//make the image work 