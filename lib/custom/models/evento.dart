import 'dart:convert';
    
// getting a list of users from json
List<Evento> EventoFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return List<Evento>.from(data.map((x) => Evento.fromJson(x['attributes'])));
}


// Evento class
class Evento {
  Evento({
    this.id,
    this.nombre,
  });

  int? id;
  String? nombre;

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
    id: json["id"],
    nombre: json["nombre"],
  );
  
  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Evento{id: $id, nombre: $nombre}';
  }
  
}