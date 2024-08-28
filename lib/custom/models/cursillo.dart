import 'dart:convert';

import 'package:flutkit/custom/models/categoria.dart';    

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