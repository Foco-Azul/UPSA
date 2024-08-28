import 'dart:convert';
    
// getting a list of users from json
List<Carrera> CarrerasFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Carrera.fromJson(item)).toList();
}

// Carrera class
class Carrera {
  Carrera({
    this.id,
    this.nombre,
  });

  int? id;
  String? nombre;

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
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
    return 'Carrera{id: $id, nombre: $nombre}';
  }
  
}