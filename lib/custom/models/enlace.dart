
// Enlace class
class Enlace {
  int? id;
  String? nombre;
  String? icono;
  String? enlace;

  Enlace({
    this.id = -1,
    this.nombre = "",
    this.icono = "sin icono",
    this.enlace = "",
  });
  
  static List<Enlace> armarEnlaces(List<dynamic>? data){
    List<Enlace> res = [];
    if (data != null) {
      for (var item in data) {
        res.add(
          Enlace(
            id: item["id"],
            nombre: item["nombre"],
            enlace: item["enlace"] ?? "",
            icono: item["icono"],
          )
        );
      }
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "label": nombre,
  };
  @override
  String toString() {
    return 'Enlace{id: $id, label: $nombre}';
  }
  
}