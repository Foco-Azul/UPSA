import 'dart:convert';  

Contacto ContactoFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];
  return Contacto.fromJson(data);
}
// Contacto class
class Contacto {
  Contacto({
    this.id,
    this.titulo,
    this.descripcion,
    this.descripcionFormularioContacto,
    this.enlacesContacto,
    this.redesSociales,
  });

  int? id;
  String? titulo;
  String? descripcion;
  String? descripcionFormularioContacto;
  List<Map<String, dynamic>>? enlacesContacto;
  List<Map<String, dynamic>>? redesSociales;

  factory Contacto.fromJson(Map<String, dynamic> json) {
    return Contacto(
      id: json["id"],
      titulo: json['attributes']["titulo"],
      descripcion: json['attributes']["descripcion"],
      descripcionFormularioContacto: json['attributes']["descripcionFormularioContacto"],
      enlacesContacto: _parsearMap(json['attributes']["enlacesContacto"]),
      redesSociales: _parsearMap(json['attributes']["redesSociales"]),
    );
  }
  static List<Map<String, dynamic>> _parsearMap(List<dynamic> data){
    List<Map<String, dynamic>> res = [];
    for (var item in data) {
      Map<String, dynamic> aux = {
        "nombre": item["nombre"],
        "enlace": item["enlace"],
        "icono": item["icono"],
      };
      res.add(aux);
    }
    return res;
  }
  Map<String, dynamic> toJson() => {
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Contacto{id: $id, titulo: $titulo}';
  }
}