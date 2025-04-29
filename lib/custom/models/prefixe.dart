import 'dart:convert';

class Prefixe {
  int? id;
  String? pais;
  String? condicionPrimerDigito;
  String? condicionCandidaDigitos;
  String? codigoDePais;
  String? codigoDeTelefono;

  Prefixe({
    this.id,
    this.pais,
    this.condicionPrimerDigito,
    this.condicionCandidaDigitos,
    this.codigoDePais,
    this.codigoDeTelefono,
  });
  static List<Prefixe> armarPrefixesPopulate(String str) {
    List<Prefixe> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Prefixe aux = Prefixe(
        id: item["id"],
        pais: item['attributes']["pais"],
        condicionPrimerDigito: item['attributes']["condicionPrimerDigito"] ?? "",
        condicionCandidaDigitos: item['attributes']["condicionCandidaDigitos"] ?? "",
        codigoDePais: item['attributes']["codigoDePais"],
        codigoDeTelefono: item['attributes']["codigoDeTelefono"],
      );
      res.add(aux);
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "pais": pais,
    "condicionPrimerDigito": condicionPrimerDigito,
    "condicionCandidaDigitos": condicionCandidaDigitos,
    "codigoDePais": codigoDePais,
    "codigoDeTelefono": codigoDeTelefono,
  };
  @override
  String toString() {
    return 'Prefixe{id: $id, pais: $pais}';
  }
}