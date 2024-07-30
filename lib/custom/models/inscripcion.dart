 
// Inscripcion class
class Inscripcion {
  int? id;
  String? qr;
  int? user;
  int? actividad;
  bool? asistencia;
  String? tipo;

  Inscripcion({
    this.id,
    this.qr = "",
    this.user,
    this.actividad,
    this.asistencia,
    this.tipo,
  });
  
  static List<Inscripcion> armarInscripciones(List<dynamic> data, int id, String tipo){
    List<Inscripcion> res = [];
    for (var item in data) {
      Inscripcion aux = Inscripcion(
        id: item["id"],
        qr: item["attributes"]["qr"],
        user: item["attributes"]["user"]["data"]["id"],
        actividad: id,
        asistencia: item["attributes"]["asistencia"],
        tipo: tipo,
      );
      res.add(aux);
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "qr": qr,
  };
  @override
  String toString() {
    return 'Inscripcion{id: $id, qr: $qr}';
  }
  
}