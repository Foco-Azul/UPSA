import 'dart:convert';
    
// getting a list of users from json
List<Promocion> PromocionesFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Promocion.fromJson(item)).toList();
}

Promocion PromocionFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Promocion.fromJson(data);
}


// Promocion class
class Promocion {
  Promocion({
    this.id,
    this.nombre,
  });

  int? id;
  String? nombre;

  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
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
    return 'Promocion{id: $id, nombre: $nombre}';
  }
  
}