import 'dart:convert';

import 'package:flutkit/custom/models/categoria.dart';
    
// getting a list of users from json
List<Cursillo> CursillosFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Cursillo.fromJson(item)).toList();
}

Cursillo CursilloFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Cursillo.fromJson(data);
}


// Cursillo class
class Cursillo {
  Cursillo({
    this.id,
    this.titulo,
    this.descripcion,
    this.urlVideo,
    this.categoria,
  });

  int? id;
  String? titulo;
  String? descripcion;
  String? urlVideo;
  Categoria? categoria;

  factory Cursillo.fromJson(Map<String, dynamic> json) {
    return Cursillo(
      id: json["id"],
      titulo: json['attributes']["titulo"],
      descripcion: json['attributes']["descripcion"],
      urlVideo: json['attributes']["urlVideo"],
      categoria: Categoria.armarCategoria(json['attributes']["categoria"]["data"]),
    );
  }
  static Cursillo armarCursilloPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Cursillo(
        id: data["id"],
        titulo: data['attributes']["titulo"],
        descripcion: data['attributes']["descripcion"],
        urlVideo: data['attributes']["urlVideo"],
        categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
    );
  }
  static List<Cursillo> armarCursillosPopulate(String str) {
    List<Cursillo> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Cursillo aux = Cursillo(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        categoria: Categoria.armarCategoria(item['attributes']["categoria"]["data"]),
      );
      res.add(aux);
    }
    return res;
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Cursillo{id: $id, titulo: $titulo}';
  }
  
}