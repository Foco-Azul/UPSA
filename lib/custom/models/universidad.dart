import 'dart:convert';
    
// getting a list of users from json
List<Universidad> UniversidadesFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData;
  return data.map((item) => Universidad.fromJson(item)).toList();
}

Universidad UniverdadFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData;

  return Universidad.fromJson(data);
}


// Universidad class
class Universidad {
  Universidad({
    this.id,
    this.nombre,
    this.idDepartamento,
  });

  int? id;
  String? nombre;
  int? idDepartamento;

  factory Universidad.fromJson(Map<String, dynamic> json) {
    return Universidad(
      id: int.parse(json["id"]),
      nombre: json["nombre"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Universidad{id: $id, nombre: $nombre}';
  }
  
}