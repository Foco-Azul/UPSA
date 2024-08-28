import 'dart:convert';
    
// getting a list of users from json
List<Colegio> ColegiosFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Colegio.fromJson(item)).toList();
}

// Colegio class
class Colegio {
  Colegio({
    this.id = -1,
    this.nombre = "",
    this.imagenes,
  });

  int? id;
  String? nombre;
  List<String>? imagenes;

  factory Colegio.fromJson(Map<String, dynamic> json) {
    return Colegio(
      id: json["id"],
      nombre: json['attributes']["nombre"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Colegio{id: $id, nombre: $nombre}';
  }
  
}