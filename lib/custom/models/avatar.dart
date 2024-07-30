
// Avatar class
import 'dart:convert';

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
        imagen: item["attributes"]["imagen"]["data"] != null ? item["attributes"]["imagen"]["data"]["attributes"]["url"] : "/uploads/avatar_89f34d0255.png",
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
        imagen: data["attributes"]["imagen"]["data"] != null ? data["attributes"]["imagen"]["data"]["attributes"]["url"] : "/uploads/avatar_89f34d0255.png",
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