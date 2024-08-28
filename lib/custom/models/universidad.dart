import 'dart:convert';
    
// Universidad class
class Universidad {
  Universidad({
    this.id = -1,
    this.nombre = "",
    this.idDepartamento,
  });

  int? id;
  String? nombre;
  int? idDepartamento;

  static List<Universidad> armarUniversidadesPopulate(String str) {
    List<Universidad> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Universidad aux = Universidad(
        id: item["id"],
        nombre: item["attributes"]["nombre"],
      );
      res.add(aux);
    }
    return res;
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