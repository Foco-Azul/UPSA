
// QuizPregunta class
import 'dart:convert';

class QuizPregunta {
  int? id;
  String? titulo;
  String? descripcion;
  List<Map<String, dynamic>>? campos;

  QuizPregunta({
    this.id = -1,
    this.titulo = "",
    this.descripcion = "",
    this.campos,
  });
  static QuizPregunta armarQuizPreguntaPopulateParaLlenar(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return QuizPregunta(
      id: data["id"],
      titulo: data['attributes']["titulo"],
      descripcion: data['attributes']["descripcion"] ?? "",
      campos: _armarCamposConError(data['attributes']["campos"]),
    );
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
      );
      res.add(aux);
    }
    return res;
  }

  static List<Map<String, dynamic>> _armarCamposConError(List<dynamic>? data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var item in data) {
        List<Map<String, dynamic>> aux = [];
        for (var item2 in item["opciones"]) {
          aux.add(
            {
              "id": item2["id"],
              "opcion": item2["opcion"],
              "esCorrecto": item2["esCorrecto"],
            }
          );
        }
        res.add(
          {
            "id": item["id"],
            "label": item["label"],
            "opciones": aux,
            "error": "",
            "respuestaSeleccionada": -1,
          }
        );
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