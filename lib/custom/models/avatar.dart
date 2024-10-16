
// Avatar class
import 'dart:convert';

import 'package:flutkit/custom/utils/funciones.dart';

class Avatar {
  int? id;
  String? nombre;
  String? imagen;

  Avatar({
    this.id,
    this.nombre,
    this.imagen,
  });
    static List<Avatar> armarAvataresPopulate(String str) {
    List<Avatar> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Avatar aux = Avatar(
        id: item["id"],
        nombre: item["attributes"]["nombre"],
        imagen: FuncionUpsa.getImageUrl(item['attributes']["imagen"]['data']),
      );
      res.add(aux);
    }
    return res;
  }
  static Avatar armarAvatar(dynamic data){
    Avatar res = Avatar();
    if (data != null) {
      res = Avatar(
        id: data["id"],
        nombre: data["attributes"]["nombre"],
        imagen: FuncionUpsa.getImageUrl(data['attributes']["imagen"]['data']),
      );
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
  @override
  String toString() {
    return 'Avatar{id: $id, nombre: $nombre}';
  }
  
}