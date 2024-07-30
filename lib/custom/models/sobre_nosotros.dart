import 'dart:convert';
    
// getting a list of users from json
SobreNosotros SobreNosotroFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return SobreNosotros.fromJson(data);
}


// SobreNosotros class
class SobreNosotros {
  SobreNosotros({
    this.id,
    this.titulo,
    this.imagenes,
    this.descripcion,
    this.mision,
    this.vision,
    this.valores,
    this.comunidad,
    this.objetivo,
    this.respaldoLegal,
  });

  int? id;
  String? titulo;
  List<String>? imagenes;
  String? descripcion;
  String? mision;
  String? vision;
  String? valores;
  String? comunidad;
  String? objetivo;
  String? respaldoLegal;

  factory SobreNosotros.fromJson(Map<String, dynamic> json) {
    return SobreNosotros(
      id: json["id"],
      titulo: json['attributes']["titulo"],
      descripcion: json['attributes']["descripcion"], 
      mision: json['attributes']["mision"], 
      vision: json['attributes']["vision"], 
      valores: json['attributes']["valores"], 
      comunidad: json['attributes']["comunidad"], 
      objetivo: json['attributes']["objetivo"], 
      respaldoLegal: json['attributes']["respaldoLegal"], 
      imagenes: _convertirGaleria(json['attributes']["imagenes"]?['data']), 
    );
  }

  static List<String> _convertirGaleria(dynamic data) {
    List<String> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['attributes'] != null) {
          String url = item['attributes']['url'];
          res.add(url);
        }
      }
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'SobreNosotros{id: $id, titulo: $titulo}';
  }
  
}