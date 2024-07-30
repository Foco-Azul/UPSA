import 'dart:convert';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/etiqueta.dart';
import 'package:flutkit/custom/utils/funciones.dart';
    
// Noticia class
class Noticia {
  Noticia({
    this.id,
    this.titulo,
    this.categoria,
    this.publicacion,
    this.imagen,
    this.notaCompleta,
    this.descripcion,
    this.etiquetas,
  });

  int? id;
  String? titulo;
  Categoria? categoria;
  String? publicacion;
  String? imagen;
  String? notaCompleta;
  String? descripcion;
  List<Etiqueta>? etiquetas;

  static List<Noticia> armarNoticiasPopulate(String str) {
    List<Noticia> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Noticia aux = Noticia(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        categoria: Categoria.armarCategoria(item['attributes']["categoria"]["data"]),
        publicacion: FuncionUpsa.armarFechaPublicacion(item['attributes']["publishedAt"]), 
        imagen: item['attributes']["imagen"]['data'] != null ? item['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
        notaCompleta: item['attributes']["notaCompleta"], 
        descripcion: item['attributes']["descripcion"], 
        etiquetas: Etiqueta.armarEtiquetas(item['attributes']["etiquetas"]['data']),
      );
      res.add(aux);
    }
    return res;
  }
  static Noticia armarNoticiaPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Noticia(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      categoria: Categoria.armarCategoria(data['attributes']["categoria"]["data"]),
      publicacion: FuncionUpsa.armarFechaPublicacion(data['attributes']["publishedAt"]), 
      imagen: data['attributes']["imagen"]['data'] != null ? data['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png", 
      notaCompleta: data['attributes']["notaCompleta"], 
      descripcion: data['attributes']["descripcion"], 
      etiquetas: Etiqueta.armarEtiquetas(data['attributes']["etiquetas"]['data']),
    );
  }
  static List<Noticia> armarNoticiasRelacionadas(List<dynamic> data){
    List<Noticia> res = [];
    for (var item in data) {
      Noticia aux = Noticia(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        imagen: item['attributes']["imagen"]['data'] != null ? item['attributes']["imagen"]['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",
      );
      res.add(aux);
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Noticia{id: $id, titulo: $titulo}';
  }
  
}