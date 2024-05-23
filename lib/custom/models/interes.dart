import 'dart:convert';
    
// getting a list of users from json
List<Interes> InteresesFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Interes.fromJson(item)).toList();
}

Interes InteresFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Interes.fromJson(data);
}


// Interes class
class Interes {
  Interes({
    this.id,
    this.nombre,
  });

  int? id;
  String? nombre;

  factory Interes.fromJson(Map<String, dynamic> json) {
    return Interes(
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
    return 'Interes{id: $id, nombre: $nombre}';
  }
  
}