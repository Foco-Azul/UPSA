
import 'dart:convert';

class Resultado {
  Resultado({
    this.id,
    this.titulo,
    this.descripcion,
    this.idContenido,
    this.categoria,
    this.etiquetas,
    this.tipo,
    this.palabrasClaves,
    this.descripcionClave,
    this.usuariosPermitidos,
  });
    int? id;
    String? titulo;
    String? descripcion;
    int? idContenido;
    String? categoria;
    String? etiquetas;
    String? tipo;
    String? palabrasClaves;
    String? descripcionClave;
    String? usuariosPermitidos;

  static List<Resultado> armarResultadosPopulate(String str) {
    List<Resultado> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Resultado aux = Resultado(
        id: item['id'],
        titulo: item["attributes"]['titulo'],
        descripcion: item["attributes"]['descripcion'],
        idContenido: item["attributes"]['idContenido'],
        categoria: item["attributes"]['categoria'],
        etiquetas: item["attributes"]['etiquetas'],
        tipo: item["attributes"]['tipo'],
        palabrasClaves: item["attributes"]['palabrasClaves'],
        descripcionClave: item["attributes"]['descripcionClave'],
        usuariosPermitidos: item["attributes"]["usuariosPermitidos"] ?? ";-1;",
      );
      res.add(aux);
    }
    return res;
  }
  
  Map<String, dynamic> toJson() => {
    "id": id,
    "titulo": titulo,
    "descripcion": descripcion,
    "idContenido": idContenido,
    "categoria": categoria,
    "etiquetas": etiquetas,
    "tipo": tipo,
    "palabrasClaves": palabrasClaves,
    "descripcionClave": descripcionClave,
  };

  @override
  String toString() {
    return 'Resultado{id: $id, titulo: $titulo, titulo: $titulo, descripcion: $descripcion, idContenido: $idContenido, categoria: $categoria, etiquetas: $etiquetas, tipo: $tipo, palabrasClaves: $palabrasClaves, descripcionClave: $descripcionClave}';
  }
}