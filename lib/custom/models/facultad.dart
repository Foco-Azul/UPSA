
import 'package:flutkit/custom/models/carrera_upsa.dart';

// Facultad class
class Facultad {
  Facultad({
    this.id,
    this.nombre,
    this.carreras,
    this.icono,
  });

  int? id;
  String? nombre;
  String? icono;
  List<CarreraUpsa>? carreras;
  
  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Facultad{id: $id, nombre: $nombre}';
  }
  
}