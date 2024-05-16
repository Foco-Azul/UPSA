import 'dart:convert';
    
// getting a list of users from json
List<Noticia> NoticiasFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Noticia.fromJson(item)).toList();
}
List<Noticia> NoticiasFromJsonCategoria(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData["data"][0]["attributes"]["noticias"]["data"];
  return data.map((item) => Noticia.fromJson(item)).toList();
}


Noticia NoticiaFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Noticia.fromJson(data);
}


// Noticia class
class Noticia {
  Noticia({
    this.id,
    this.titular,
    this.categoria,
    this.publicacion,
    this.foto,
    this.galeriaDeFotos,
    this.notaCompleta,
    this.descripcion,
    this.etiquetas,
  });

  int? id;
  String? titular;
  String? categoria;
  String? publicacion;
  String? foto;
  List<String>? galeriaDeFotos;
  String? notaCompleta;
  String? descripcion;
  List<String>? etiquetas;

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: json["id"],
      titular: json['attributes']["titular"],
      categoria: json['attributes']["categoria"]?['data']?['attributes']?['nombre'] ?? "Sin categoría",
      publicacion: _convertirFechaPublicacion(json['attributes']["publishedAt"]), 
      foto: json['attributes']["foto"]?['data']?['attributes']?['url'] ?? "/uploads/default_02263f0f89.png", 
      galeriaDeFotos: _convertirGaleria(json['attributes']["galeriaFotos"]?['data']), 
      notaCompleta: json['attributes']["notaCompleta"], 
      descripcion: json['attributes']["descripcion"], 
      etiquetas: _convertirEtiquetas(json['attributes']["etiquetas"]?['data']),
    );
  }

  static List<String> _convertirEtiquetas(dynamic data) {
    List<String> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['attributes'] != null) {
          String url = item['attributes']['nombre'];
          res.add(url);
        }
      }
    }
    return res;
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
  static String _convertirFechaPublicacion(String data) {
    DateTime fechaPublicacion = DateTime.parse(data);
    DateTime ahora = DateTime.now();
    Duration diferencia = ahora.difference(fechaPublicacion);

    if (diferencia.inHours < 24) {
      return "Hace ${diferencia.inHours} horas";
    } else {
      int dias = diferencia.inDays;
      if (diferencia.inHours % 24 != 0) {
        dias++; // Añadir un día si hay horas extras
      }
      return "Hace $dias días";
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "titular": titular,
  };
  @override
  String toString() {
    return 'Noticia{id: $id, titular: $titular}';
  }
  
}