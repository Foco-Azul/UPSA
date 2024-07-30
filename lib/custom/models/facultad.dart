import 'dart:convert';

import 'package:flutkit/custom/models/carrera_upsa.dart';
    
// getting a list of users from json
List<Facultad> FacultadesFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Facultad.fromJson(item)).toList();
}

Facultad FacultadFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Facultad.fromJson(data);
}


// Facultad class
class Facultad {
  Facultad({
    this.id,
    this.nombre,
    this.carreras,
    this.icono,
  });

  int? id;
  String? nombre;
  String? icono;
  List<CarreraUpsa>? carreras;

  factory Facultad.fromJson(Map<String, dynamic> json) {
    return Facultad(
      id: json["id"],
      nombre: json['attributes']["nombre"],
      icono: json['attributes']["icono"],
      carreras: _armarCarreras(json['attributes']["carreras"]["data"]),
    );
  }
  static List<CarreraUpsa> _armarCarreras(List<dynamic> data){
    List<CarreraUpsa> res = [];
    for (var item in data) {
      CarreraUpsa aux = CarreraUpsa(id: item["id"], nombre: item["attributes"]["nombre"]);
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
    return 'Facultad{id: $id, nombre: $nombre}';
  }
  
}