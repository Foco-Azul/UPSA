import 'dart:convert';  

Matriculate MatriculateFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];
  return Matriculate.fromJson(data);
}
// Matriculate class
class Matriculate {
  Matriculate({
    this.id,
    this.titulo,
    this.comoMatricularse,
    this.ayuda,
    this.beneficios,
    this.masInformacion,
    this.instructivo,
    this.enlaceFormulario,
  });

  int? id;
  String? titulo;
  String? comoMatricularse;
  String? ayuda;
  List<dynamic>? beneficios;
  List<dynamic>? masInformacion;
  String? instructivo;
  String? enlaceFormulario;

  factory Matriculate.fromJson(Map<String, dynamic> json) {
    return Matriculate(
      id: json["id"],
      titulo: json['attributes']["titulo"],
      comoMatricularse: json['attributes']["comoMatricularse"],
      ayuda: json['attributes']["ayuda"],
      beneficios: json['attributes']["beneficios"],
      masInformacion: json['attributes']["masInformacion"],
      instructivo: json['attributes']["instructivo"]["data"] != null ? json['attributes']["instructivo"]["data"]["attributes"]["url"] : "",
      enlaceFormulario: json['attributes']["enlaceFormulario"] ?? "",
    );
  }
  Map<String, dynamic> toJson() => {
    "titulo": titulo,
  };
  @override
  String toString() {
    return 'Matriculate{id: $id, titulo: $titulo}';
  }
}