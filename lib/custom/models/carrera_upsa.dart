import 'dart:convert';

import 'package:flutkit/custom/models/categoria.dart';
    
// getting a list of users from json
List<CarreraUpsa> CarrerasUpsaFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => CarreraUpsa.fromJson(item)).toList();
}

CarreraUpsa CarreraUpsaFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return CarreraUpsa.fromJson(data);
}


// CarreraUpsa class
class CarreraUpsa {
  CarreraUpsa({
    this.id,
    this.nombre,
    this.descripcion,
    this.imagen,
    this.enlaceExterno,
    this.categoria,
    this.masInformacion,
    this.pdf,
  });

  int? id;
  String? nombre;
  String? descripcion;
  String? imagen;
  String? enlaceExterno;
  Categoria? categoria;
  List<dynamic>? masInformacion;
  String? pdf;

  factory CarreraUpsa.fromJson(Map<String, dynamic> json) {
    return CarreraUpsa(
      id: json["id"],
      nombre: json['attributes']["nombre"],
      categoria: Categoria.armarCategoria(json['attributes']["categoria"]["data"]),
    );
  }
  static CarreraUpsa armarCarreraUpsaPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return CarreraUpsa(
      id: data["id"],
      nombre: data['attributes']["nombre"],
      descripcion: data['attributes']["descripcion"],
      imagen: data['attributes']["imagen"]['data'] != null ? data['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",  
      enlaceExterno: data['attributes']["enlaceExterno"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      masInformacion: data['attributes']["masInformacion"] ?? [],
      pdf: data['attributes']["pdf"]['data'] != null ? data['attributes']["pdf"]['data']['attributes']['url'] : "",  
    );
  }
  static List<CarreraUpsa> armarCarrerasUpsaPopulate(String str) {
    List<CarreraUpsa> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      CarreraUpsa aux = CarreraUpsa(
        id: item["id"],
        nombre: item['attributes']["nombre"],
        categoria: Categoria.armarCategoria(item['attributes']["categoria"]["data"]),
      );
      res.add(aux);
    }
    return res;
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'CarreraUpsa{id: $id, nombre: $nombre}';
  }
  
}