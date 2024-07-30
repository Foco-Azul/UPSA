
// Etiqueta class
class Etiqueta {
  int? id;
  String? nombre;
  bool? activo;
  List<dynamic>? contenido;

  Etiqueta({
    this.id = -1,
    this.nombre = "Sin etiqueta",
    this.activo = false,
    
  });
  
  static List<Etiqueta> armarEtiquetas(List<dynamic> data){
    List<Etiqueta> res = [];
    for (var item in data) {
      Etiqueta aux = Etiqueta(
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
    return 'Etiqueta{id: $id, nombre: $nombre}';
  }
  
}