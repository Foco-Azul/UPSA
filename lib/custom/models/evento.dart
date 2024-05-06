import 'dart:convert';
    
// getting a list of users from json
List<Evento> EventosFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return [
    Evento.fromJson(data),
  ];
}

Evento EventoFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Evento.fromJson(data);
}


// Evento class
class Evento {
  Evento({
    this.id,
    this.titulo,
    this.categoria,
    this.publicacion,
    this.fotoPrincipal,
    this.galeriaDeFotos,
    this.fechaDeInicio,
    this.fechaDeFin,
    this.cuerpo,
    this.etiquetas,
    this.calendario,
  });

  String? id;
  String? titulo;
  String? categoria;
  String? publicacion;
  String? fotoPrincipal;
  List<String>? galeriaDeFotos;
  String? fechaDeInicio;
  String? fechaDeFin;
  String? cuerpo;
  List<String>? etiquetas;
  List<Map<String, String>>? calendario;



  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json["id"].toString(),
      titulo: json['attributes']["titulo"],
      categoria: json['attributes']["categoria"]?['data']?['attributes']?['nombre'] ?? "Sin categoría",
      publicacion: _convertirFechaPublicacion(json['attributes']["publishedAt"]), 
      fotoPrincipal: json['attributes']["fotoPrincipal"]?['data']?['attributes']?['url'] ?? "/uploads/default_02263f0f89.png", 
      galeriaDeFotos: _convertirGaleria(json['attributes']["galeriaDeFotos"]['data']), 
      fechaDeInicio: json['attributes']["fechaDeInicio"], 
      fechaDeFin: json['attributes']["fechaDeFin"],
      cuerpo: json['attributes']["cuerpo"], 
      etiquetas: _convertirEtiquetas(json['attributes']["etiquetas"]['data']),
      calendario: _convertirCalendario(json['attributes']["calendarioEvento"]), 
    );
  }
  static List<Map<String, String>> _convertirCalendario(dynamic data) {
    List<Map<String, String>> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['calendarioTitulo'] != null && item['calendarioFecha'] != null) {
          Map<String, String> evento = {
            item['calendarioTitulo']: item['calendarioFecha']
          };
          res.add(evento);
        }
      }
    }
    return res;
  }

  static List<String> _convertirEtiquetas(dynamic data) {
    List<String> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['attributes'] != null) {
          String url = item['attributes']['nombre'];
          if (url != null) {
            res.add(url);
          }
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
          if (url != null) {
            res.add(url);
          }
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
      return "Hace ${dias} días";
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Evento{id: $id, titulo: $titulo}';
  }
  
}