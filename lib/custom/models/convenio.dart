import 'dart:convert';

import 'package:flutkit/custom/models/enlace.dart';  

// Convenio class
class Convenio {
  Convenio({
    this.id,
    this.titulo,
    this.internacionalizacion,
    this.paises,
    this.paisesConvenio,
    this.enlaces,
  });

  int? id;
  String? titulo;
  String? internacionalizacion;
  String? paisesConvenio;
  List<dynamic>? paises;
  List<Enlace>? enlaces;

  static Convenio armarConvenioPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Convenio(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      internacionalizacion: data['attributes']["internacionalizacion"],
      paisesConvenio: data['attributes']["paisesConvenio"],
      paises: data['attributes']["paises"],
      enlaces: Enlace.armarEnlaces(data["attributes"]["contactos"]),
    );
  }
  Map<String, dynamic> toJson() => {
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Convenio{id: $id, titulo: $titulo}';
  }
}