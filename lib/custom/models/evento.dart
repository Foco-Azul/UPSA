import 'dart:convert';
    
// getting a list of users from json
List<Evento> EventosFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Evento.fromJson(item)).toList();
}
List<Evento> EventosFromJsonCategoria(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData["data"][0]["attributes"]["eventos"]["data"];
  return data.map((item) => Evento.fromJson(item)).toList();
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
    this.capacidad,
    this.inscritos,
    this.inscripciones,
    this.inscripciones2,
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
  int? capacidad;
  int? inscritos;
  List<Map<String,int>>? inscripciones;
  List<Map<String, String>>? inscripciones2;
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json["id"].toString(),
      titulo: json['attributes']["titulo"],
      categoria: json['attributes']["categoria"]?['data']?['attributes']?['nombre'] ?? "Sin categoría",
      publicacion: _convertirFechaPublicacion(json['attributes']["publishedAt"]), 
      fotoPrincipal: json['attributes']["fotoPrincipal"]?['data']?['attributes']?['url'] ?? "/uploads/default_02263f0f89.png", 
      galeriaDeFotos: _convertirGaleria(json['attributes']["galeriaDeFotos"]?['data']), 
      fechaDeInicio: json['attributes']["fechaDeInicio"], 
      fechaDeFin: json['attributes']["fechaDeFin"],
      cuerpo: json['attributes']["cuerpo"], 
      etiquetas: _convertirEtiquetas(json['attributes']["etiquetas"]?['data']),
      calendario: _convertirCalendario(json['attributes']?["calendarioEvento"]), 
      capacidad: json['attributes']["capacidad"] ?? -1,
      inscritos: json['attributes']?["inscripciones"]?['data']?.length ?? 0,
      inscripciones: _convertirInscripciones(json['attributes']?['inscripciones']?['data']),
      inscripciones2: _convertirInscripciones2(json['attributes']?['inscripciones']?['data']),
    );
  }
  static List<Map<String,int>> _convertirInscripciones(dynamic data) {
    List<Map<String,int>> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['id'] != null && item['attributes'] != null && item['attributes']['qr'] != null) {
          Map<String, int> evento = {
            item['attributes']['qr']:item['id']
          };
          res.add(evento);
        }
      }
    }
    return res;
  }
  static List<Map<String, String>> _convertirInscripciones2(dynamic data) {
    List<Map<String, String>> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['id'] != null && item['attributes'] != null && item['attributes']['qr'] != null && item['attributes']['asistencia'] != null) {
          Map<String, String> asistenciaData = {
            'id':item['id'].toString(),
            'qr':item['attributes']['qr'],
            "asistencia": item['attributes']['asistencia'] ? 'true' : 'false',
          };
          res.add(asistenciaData);
        }
      }
    }
    return res;
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
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Evento{id: $id, titulo: $titulo}';
  }
  
}