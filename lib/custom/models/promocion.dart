
// Promocion class
class Promocion {
  Promocion({
    this.id,
    this.nombre,
  });

  int? id;
  String? nombre;

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Promocion{id: $id, nombre: $nombre}';
  }
  
}