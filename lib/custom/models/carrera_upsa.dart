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
    this.campoLaboral,
    this.perfilPostulante,
    this.objetivos,
    this.masInformacion,
    this.enlaceExterno,
    this.planEstudios,
    this.categoria,
  });

  int? id;
  String? nombre;
  String? descripcion;
  String? imagen;
  String? campoLaboral;
  String? perfilPostulante;
  String? objetivos;
  String? masInformacion;
  String? enlaceExterno;
  List<Map<String, dynamic>>? planEstudios;
  Categoria? categoria;

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
      campoLaboral: data['attributes']["campoLaboral"],
      perfilPostulante: data['attributes']["perfilPostulante"],
      objetivos: data['attributes']["objetivos"],
      masInformacion: data['attributes']["masInformacion"],
      enlaceExterno: data['attributes']["enlaceExterno"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      planEstudios: _armarPlanDeEstudios(data['attributes']["planEstudios"]),
    );
  }
  static List<Map<String, dynamic>> _armarPlanDeEstudios(List<dynamic>? data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var item in data) {
        Map<String, dynamic> aux = {
          "id": item["id"],
          "semestre": item["semestre"],
          "descripcion": item["descripcion"],
        };
        res.add(aux);
      }
    }
    return res;
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