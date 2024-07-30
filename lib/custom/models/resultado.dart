
import 'dart:convert';

List<Resultado> ResultadosFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];
  return data.map((item) => Resultado.fromJson(item)).toList();
}
Resultado ResultadoFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];
  return Resultado.fromJson(data);
} 

class Resultado {
  Resultado({
    this.id,
    this.titulo,
    this.descripcion,
    this.idContenido,
    this.categoria,
    this.etiquetas,
    this.tipo,
    this.palabrasClaves,
    this.descripcionClave,
  });
    int? id;
    String? titulo;
    String? descripcion;
    int? idContenido;
    String? categoria;
    String? etiquetas;
    String? tipo;
    String? palabrasClaves;
    String? descripcionClave;

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      id: json['id'],
      titulo: json["attributes"]['titulo'],
      descripcion: json["attributes"]['descripcion'],
      idContenido: json["attributes"]['idContenido'],
      categoria: json["attributes"]['categoria'],
      etiquetas: json["attributes"]['etiquetas'],
      tipo: json["attributes"]['tipo'],
      palabrasClaves: json["attributes"]['palabrasClaves'],
      descripcionClave: json["attributes"]['descripcionClave'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
    "descripcion": descripcion,
    "idContenido": idContenido,
    "categoria": categoria,
    "etiquetas": etiquetas,
    "tipo": tipo,
    "palabrasClaves": palabrasClaves,
    "descripcionClave": descripcionClave,
  };

  @override
  String toString() {
    return 'Resultado{id: $id, titulo: $titulo, titulo: $titulo, descripcion: $descripcion, idContenido: $idContenido, categoria: $categoria, etiquetas: $etiquetas, tipo: $tipo, palabrasClaves: $palabrasClaves, descripcionClave: $descripcionClave}';
  }
}