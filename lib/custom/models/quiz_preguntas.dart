
// QuizPregunta class
import 'dart:convert';

import 'package:flutkit/custom/utils/funciones.dart';

class QuizPregunta {
  int? id;
  String? titulo;
  String? descripcion;
  List<Map<String, dynamic>>? campos;
  String? imagen;
  List<Map<String, dynamic>>? usuarios;

  QuizPregunta({
    this.id = -1,
    this.titulo = "",
    this.descripcion = "",
    this.campos,
    this.imagen = "/uploads/default_02263f0f89.png",
    this.usuarios,
  });
  static QuizPregunta armarQuizPreguntaPopulateParaLlenar(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return QuizPregunta(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      descripcion: data['attributes']["descripcion"] ?? "",
      campos: _armarCamposConError(data['attributes']["campos"]),
      usuarios: _armarListaDeUsuarios(data['attributes']["respuestasDeQuizzes"]["data"]),
    );
  }
  static List<Map<String, dynamic>> _armarListaDeUsuarios(dynamic data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var respuesta  in data) {
        if(respuesta["attributes"]["usuario"]["data"] != null){
          bool bandera = false;
          for (var item in res) {
            if(item["id"] == respuesta["attributes"]["usuario"]["data"]["id"]){
              item["cantidad"] = item["cantidad"] + 1;
              bandera = true;
            }
          }
          if(!bandera){
            res.add(
              {
                "id": respuesta["attributes"]["usuario"]["data"]["id"],
                "cantidad": 1,
              }
            );
          }
        }
      }
    }
    return res;
  }
  static List<QuizPregunta> armarQuizPreguntasPopulate(String str) {
    List<QuizPregunta> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      QuizPregunta aux = QuizPregunta(
        id: item["id"],
        titulo: item['attributes']["titulo"],
        descripcion: item['attributes']["descripcion"] ?? "",
        imagen: FuncionUpsa.getImageUrl(item['attributes']["imagen"]['data']),
      );
      res.add(aux);
    }
    return res;
  }

  static List<Map<String, dynamic>> _armarCamposConError(List<dynamic>? data){
    List<Map<String, dynamic>> res = [];
    int pos = 0;
    if(data != null){
      for (var item in data) {
        List<Map<String, dynamic>> aux = [];
        for (var item2 in item["opciones"]) {
          aux.add(
            {
              "id": item2["id"],
              "opcion": item2["opcion"],
              "esCorrecto": item2["esCorrecto"],
              "mensaje": "",
            }
          );
        }
        res.add(
          {
            "id": item["id"],
            "label": item["label"],
            "opciones": aux,
            "respuestaSeleccionada": -1,
            "pos": pos,
          }
        );
        pos++;
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
    return 'QuizPregunta{id: $id, titulo: $titulo}';
  }
  
}