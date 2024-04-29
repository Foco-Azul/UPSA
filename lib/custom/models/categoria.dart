import 'dart:convert';
    
// getting a list of users from json
List<Categoria> categoriaFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return List<Categoria>.from(data.map((x) => Categoria.fromJson(x['attributes'])));
}


// Categoria class
class Categoria {
  Categoria({
    this.id,
    this.nombre,
  });

  int? id;
  String? nombre;

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nombre: json["nombre"],
  );
  
  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Categoria{id: $id, nombre: $nombre}';
  }
  
}