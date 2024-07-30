
// Categoria class
class Categoria {
  int? id;
  String? nombre;
  String? icono;
  bool? activo;
  List<int>? idsContenido;

  Categoria({
    this.id = -1,
    this.nombre = "Sin categoría",
    this.icono = "sin icono",
    this.activo = false,
    this.idsContenido,
  });
  
  static Categoria armarCategoria(dynamic data){
    Categoria res = Categoria();
    if (data != null) {
      res = Categoria(
        id: data["id"],
        nombre: data["attributes"]["nombre"],
        icono: data["attributes"]["icono"],
      );
    }
    return res;
  }

  //EVENTOS
  factory Categoria.fromJsonEvento(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nombre: json["nombre"],
    idsContenido: _armarListaIds(json["eventos"]["data"]),
  );
  //EVENTOS
  factory Categoria.fromJsonConcurso(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nombre: json["nombre"],
    idsContenido: _armarListaIds(json["concursos"]["data"]),
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