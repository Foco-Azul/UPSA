import 'dart:convert';
    
// getting a list of users from json
List<Concurso> ConcursosFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData['data'];

  return data.map((item) => Concurso.fromJson(item)).toList();
}
List<Concurso> ConcursosFromJsonCategoria(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> data = jsonData["data"][0]["attributes"]["concursos"]["data"];
  return data.map((item) => Concurso.fromJson(item)).toList();
}


Concurso ConcursoFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Concurso.fromJson(data);
}


// Concurso class
class Concurso {
  Concurso({
    this.id,
    this.titulo,
    this.categoria,
    this.publicacion,
    this.fotoPrincipal,
    this.galeriaDeFotos,
    this.fechaInicio,
    this.fechaFin,
    this.descripcion,
    this.etiquetas,
    this.calendario,
    this.capacidad,
    this.inscritos,
    this.inscripciones,
    this.noticiasRelacionadas,
  });

  int? id;
  String? titulo;
  String? categoria;
  String? publicacion;
  String? fotoPrincipal;
  List<String>? galeriaDeFotos;
  String? fechaInicio;
  String? fechaFin;
  String? descripcion;
  List<String>? etiquetas;
  List<Map<String, dynamic>>? calendario;
  int? capacidad;
  int? inscritos;
  List<Map<String, dynamic>>? inscripciones;
  List<int>? noticiasRelacionadas;
  
  factory Concurso.fromJson(Map<String, dynamic> json) {
    return Concurso(
      id: json["id"],
      titulo: json['attributes']["titulo"],
      categoria: json['attributes']["categoria"]?['data']?['attributes']?['nombre'] ?? "Sin categoría",
      publicacion: _convertirFechaPublicacion(json['attributes']["publishedAt"]), 
      fotoPrincipal: json['attributes']["fotoPrincipal"]?['data']?['attributes']?['url'] ?? "/uploads/default_02263f0f89.png", 
      galeriaDeFotos: _convertirGaleria(json['attributes']["galeriaDeFotos"]?['data']), 
      fechaInicio: json['attributes']["fechaInicio"], 
      fechaFin: json['attributes']["fechaFin"],
      descripcion: json['attributes']["descripcion"], 
      etiquetas: _convertirEtiquetas(json['attributes']["etiquetas"]?['data']), 
      capacidad: json['attributes']["capacidad"] ?? -1,
      inscritos: json['attributes']?["inscripciones"]?['data']?.length ?? 0,
      inscripciones: _convertirInscripciones(json['attributes']?['inscripciones']?['data']),
      noticiasRelacionadas: json['attributes']['noticias']["data"] != null ? _convertirNoticiasRelacionadas(json['attributes']['noticias']["data"]) : [],
      calendario: _convertirCalendario(json['attributes']?["calendario"]), 
    );
  }
  static String _convertirFecha(String fecha) {
    // Dividir la cadena en año, mes y día
    List<String> partes = fecha.split('-');
    if (partes.length != 3) {
      throw ArgumentError('La fecha debe estar en formato YYYY-MM-DD');
    }

    // Convertir el mes a nombre
    List<String> meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    int mes = int.tryParse(partes[1]) ?? 0;
    if (mes < 1 || mes > 12) {
      throw ArgumentError('El mes debe estar entre 1 y 12');
    }

    // Crear la fecha en el formato deseado
    return '${int.parse(partes[2])} de ${meses[mes]} del ${partes[0]}';
  }
  static List<int> _convertirNoticiasRelacionadas(dynamic data) {
    List<int> res = [];
    for (var item in data) {
      int idNoticia = item["id"];
      res.add(idNoticia);
    }
    return res;
  }
  static List<Map<String, String>> _convertirInscripciones(dynamic data) {
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
          Map<String, String> concurso = {
            "titulo":item['calendarioTitulo'],
            "inicio":item['calendarioFecha'],
            "fin":item['calendarioFechaFin'] != null ? " - "+ _convertirFecha(item['calendarioFechaFin']) : "",
          };
          res.add(concurso);
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
    return 'Concurso{id: $id, titulo: $titulo}';
  }
  
}