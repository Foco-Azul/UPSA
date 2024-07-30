import 'dart:convert';

import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/etiqueta.dart';
import 'package:flutkit/custom/models/inscripcion.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/utils/funciones.dart';

// Evento class
class Evento {
  Evento({
    this.id,
    this.titulo,
    this.categoria,
    this.publicacion,
    this.imagen,
    this.imagenes,
    this.fechaDeInicio,
    this.fechaDeFin,
    this.descripcion,
    this.etiquetas,
    this.calendario,
    this.capacidad,
    this.inscritos,
    this.inscripciones,
    this.noticias,
    this.seguidores
  });

  int? id;
  String? titulo;
  Categoria? categoria;
  String? publicacion;
  String? imagen;
  List<String>? imagenes;
  String? fechaDeInicio;
  String? fechaDeFin;
  String? descripcion;
  List<Etiqueta>? etiquetas;
  List<Map<String, dynamic>>? calendario;
  int? capacidad;
  int? inscritos;
  List<Noticia>? noticias;
  List<Inscripcion>? inscripciones;
  List<int>? seguidores;

  static List<Evento> armarEventosPopulateFechaOriginal(String str) {
    List<Evento> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Evento aux = Evento(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        categoria: Categoria.armarCategoria(item['attributes']["categoria"]["data"]),
        publicacion: FuncionUpsa.armarFechaPublicacion(item['attributes']["publishedAt"]), 
        imagen: item['attributes']["imagen"]['data'] != null ? item['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
        imagenes: FuncionUpsa.armarGaleriaImagenes(item['attributes']["imagenes"]['data'], item['attributes']["imagen"]['data']),
        fechaDeInicio: item['attributes']["fechaDeInicio"], 
        fechaDeFin: item['attributes']["fechaDeFin"],
        descripcion: item['attributes']["descripcion"], 
        etiquetas: Etiqueta.armarEtiquetas(item['attributes']["etiquetas"]['data']),
      );
      res.add(aux);
    }
    return res;
  }
  static List<Evento> armarEventosPopulate(String str) {
    List<Evento> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Evento aux = Evento(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        categoria: Categoria.armarCategoria(item['attributes']["categoria"]["data"]),
        publicacion: FuncionUpsa.armarFechaPublicacion(item['attributes']["publishedAt"]), 
        imagen: item['attributes']["imagen"]['data'] != null ? item['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
        imagenes: FuncionUpsa.armarGaleriaImagenes(item['attributes']["imagenes"]['data'], item['attributes']["imagen"]['data']),
        fechaDeInicio: FuncionUpsa.armarfechaDeInicioFinConHora(item['attributes']["fechaDeInicio"]), 
        fechaDeFin: FuncionUpsa.armarfechaDeInicioFinConHora(item['attributes']["fechaDeFin"]),
        descripcion: item['attributes']["descripcion"], 
        etiquetas: Etiqueta.armarEtiquetas(item['attributes']["etiquetas"]['data']),
      );
      res.add(aux);
    }
    return res;
  }
  static Evento armarEventoPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Evento(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      publicacion: FuncionUpsa.armarFechaPublicacion(data['attributes']["publishedAt"]), 
      imagen: data['attributes']["imagen"]['data'] != null ? data['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",  
      imagenes: FuncionUpsa.armarGaleriaImagenes(data['attributes']["imagenes"]['data'], data['attributes']["imagen"]['data']),
      fechaDeInicio: FuncionUpsa.armarfechaDeInicioFinConHora(data['attributes']["fechaDeInicio"]), 
      fechaDeFin: FuncionUpsa.armarfechaDeInicioFinConHora(data['attributes']["fechaDeFin"]),
      descripcion: data['attributes']["descripcion"], 
      etiquetas: Etiqueta.armarEtiquetas(data['attributes']["etiquetas"]['data']),
    );
  }
  static Evento armarEventoPopulateConInscripcionesSeguidores(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Evento(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      publicacion: FuncionUpsa.armarFechaPublicacion(data['attributes']["publishedAt"]), 
      imagen: data['attributes']["imagen"]['data'] != null ? data['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
      imagenes: FuncionUpsa.armarGaleriaImagenes(data['attributes']["imagenes"]['data'], data['attributes']["imagen"]['data']),
      fechaDeInicio: FuncionUpsa.armarfechaDeInicioFinConHora(data['attributes']["fechaDeInicio"]), 
      fechaDeFin: FuncionUpsa.armarfechaDeInicioFinConHora(data['attributes']["fechaDeFin"]),
      descripcion: data['attributes']["descripcion"], 
      etiquetas: Etiqueta.armarEtiquetas(data['attributes']["etiquetas"]['data']),
      calendario: FuncionUpsa.armarFechaCalendarioConHora(data['attributes']["calendario"]), 
      capacidad: data['attributes']["capacidad"] ?? -1,
      inscritos: data['attributes']["inscripciones"]['data'].length,
      inscripciones: Inscripcion.armarInscripciones(data['attributes']['inscripciones']['data'], data["id"], "evento"),
      seguidores: FuncionUpsa.armarSeguidores(data['attributes']['usuarios']['data']),
      noticias: Noticia.armarNoticiasRelacionadas(data['attributes']['noticias']['data']),
    );
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