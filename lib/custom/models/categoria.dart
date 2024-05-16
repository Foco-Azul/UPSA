import 'dart:convert';
    
// getting a list of users from json
List<Categoria> categoriaFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return List<Categoria>.from(data.map((x) => Categoria.fromJsonEvento(x['attributes'])));
}
//EVENTOS
List<Categoria> categoriasEventosFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return List<Categoria>.from(data.map((x) {
    final eventosData = x['attributes']['eventos']?['data'];
    if (eventosData == null || eventosData!.length <= 0) {
      // O puedes devolver una lista vacía si prefieres
      return null; // O algún valor que indique que no hay datos
    }
    return Categoria.fromJsonEvento(x['attributes']);
  }).where((element) => element != null)); // Filtrar elementos nulos
}
//NOTICIAS
List<Categoria> categoriasNoticiasFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return List<Categoria>.from(data.map((x) {
    final eventosData = x['attributes']['noticias']?['data'];
    if (eventosData == null || eventosData!.length <= 0) {
      // O puedes devolver una lista vacía si prefieres
      return null; // O algún valor que indique que no hay datos
    }
    return Categoria.fromJsonNoticia(x['attributes']);
  }).where((element) => element != null)); // Filtrar elementos nulos
}
// Categoria class
class Categoria {
  Categoria({
    this.id,
    this.nombre,
    this.idsContenido,
  });

  int? id;
  String? nombre;
  List<int>? idsContenido;
  //EVENTOS
  factory Categoria.fromJsonEvento(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nombre: json["nombre"],
    idsContenido: _armarListaIds(json["eventos"]["data"]),
  );
  //NOTICIAS
  factory Categoria.fromJsonNoticia(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nombre: json["nombre"],
    idsContenido: _armarListaIds(json["noticias"]["data"]),
  );

  static List<int> _armarListaIds(List<dynamic> data){
    List<int> res = [];
    for (var item in data) {
      if (item["id"] != null) {
        res.add(item["id"]);
      }
    }
      return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Categoria{id: $id, nombre: $nombre}';
  }
  
}