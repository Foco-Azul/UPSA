import 'dart:convert';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/etiqueta.dart';
import 'package:flutkit/custom/models/inscripcion.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/utils/funciones.dart';

// Club class
class Club {
  Club({
    this.id,
    this.titulo,
    this.descripcion,
    this.imagen,
    this.categoria,
    this.imagenes,
    this.inscritos,
    this.publicacion,
    this.fechaDeInicio,
    this.fechaDeFin,
    this.capacidad,
    this.etiquetas,
    this.calendario,     
    this.inscripciones,
    this.noticias,
    this.seguidores,
    this.usuariosHabilitados,
  });

  int? id;
  String? titulo;
  String? descripcion;
  String? imagen;
  Categoria? categoria;
  List<String>? imagenes;
  int? inscritos;
  String? publicacion;
  String? fechaDeInicio;
  String? fechaDeFin;
  int? capacidad;
  List<Etiqueta>? etiquetas;
  List<Map<String, dynamic>>? calendario;
  List<Noticia>? noticias;
  List<Inscripcion>? inscripciones;
  List<int>? seguidores;
  List<int>? usuariosHabilitados;

  static List<Club> armarClubesPopulateFechaOriginal(String str) {
    List<Club> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Club aux = Club(
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
  static List<Club> armarClubesPopulate(String str) {
    List<Club> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Club aux = Club(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        categoria: Categoria.armarCategoria(item['attributes']["categoria"]["data"]),
        publicacion: FuncionUpsa.armarFechaPublicacion(item['attributes']["publishedAt"]), 
        imagen: item['attributes']["imagen"]['data'] != null ? item['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
        imagenes: FuncionUpsa.armarGaleriaImagenes(item['attributes']["imagenes"]['data'], item['attributes']["imagen"]['data']),
        fechaDeInicio: FuncionUpsa.armarFechaDeInicioFinConHora(item['attributes']["fechaDeInicio"]), 
        fechaDeFin: FuncionUpsa.armarFechaDeInicioFinConHora(item['attributes']["fechaDeFin"]),
        descripcion: item['attributes']["descripcion"], 
        etiquetas: Etiqueta.armarEtiquetas(item['attributes']["etiquetas"]['data']),
      );
      res.add(aux);
    }
    return res;
  }
  static Club armarClubPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Club(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      publicacion: FuncionUpsa.armarFechaPublicacion(data['attributes']["publishedAt"]), 
      imagen: data['attributes']["imagen"]['data'] != null ? data['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",  
      imagenes: FuncionUpsa.armarGaleriaImagenes(data['attributes']["imagenes"]['data'], data['attributes']["imagen"]['data']),
      fechaDeInicio: FuncionUpsa.armarFechaDeInicioFinConHora(data['attributes']["fechaDeInicio"]), 
      fechaDeFin: FuncionUpsa.armarFechaDeInicioFinConHora(data['attributes']["fechaDeFin"]),
      descripcion: data['attributes']["descripcion"], 
      etiquetas: Etiqueta.armarEtiquetas(data['attributes']["etiquetas"]['data']),
    );
  }
  static Club armarClubPopulateConInscripcionesSeguidores(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Club(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      publicacion: FuncionUpsa.armarFechaPublicacion(data['attributes']["publishedAt"]), 
      imagen: data['attributes']["imagen"]['data'] != null ? data['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
      imagenes: FuncionUpsa.armarGaleriaImagenes(data['attributes']["imagenes"]['data'], data['attributes']["imagen"]['data']),
      fechaDeInicio: FuncionUpsa.armarFechaDeInicioFinConHora(data['attributes']["fechaDeInicio"]), 
      fechaDeFin: FuncionUpsa.armarFechaDeInicioFinConHora(data['attributes']["fechaDeFin"]),
      descripcion: data['attributes']["descripcion"], 
      etiquetas: Etiqueta.armarEtiquetas(data['attributes']["etiquetas"]['data']),
      calendario: FuncionUpsa.armarFechaCalendarioConHora(data['attributes']["calendario"]), 
      capacidad: data['attributes']["capacidad"] ?? -1,
      inscritos: data['attributes']["inscripciones"]['data'].length,
      inscripciones: Inscripcion.armarInscripciones(data['attributes']['inscripciones']['data'], data["id"], "evento"),
      seguidores: FuncionUpsa.armarSeguidores(data['attributes']['usuarios']['data']),
      usuariosHabilitados: FuncionUpsa.armarSeguidores(data['attributes']['usuariosHabilitados']['data']),
      noticias: Noticia.armarNoticiasRelacionadas(data['attributes']['noticias']['data']),
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Club{id: $id, titulo: $titulo}';
  }
}