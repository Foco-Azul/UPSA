
// Quiz class
class Quiz {
  int? id;
  String? nombre;
  String? icono;
  bool? activo;
  List<int>? idsContenido;

  Quiz({
    this.id = -1,
    this.nombre = "Sin categoría",
    this.icono = "sin icono",
    this.activo = false,
    this.idsContenido,
  });
  

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Quiz{id: $id, nombre: $nombre}';
  }
  
}