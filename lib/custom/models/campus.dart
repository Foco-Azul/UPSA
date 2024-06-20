import 'dart:convert';  

Campus CampusFromJson(String str) {
  final jsonData = json.decode(str);
  final Map<String, dynamic> data = jsonData['data'];

  return Campus.fromJson(data);
}


// Campus class
class Campus {
  Campus({
    this.imagenes,
  });

  int? id;
  List<String>? imagenes;

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      imagenes: _convertirGaleria(json['attributes']["imagenes"]["data"]),
    );
  }
  static List<String> _convertirGaleria(dynamic data) {
    List<String> res = [];
    if (data != null) {
      for (var item in data) {
        if (item['attributes'] != null) {
          String url = item['attributes']['url'];
          res.add(url);
        }
      }
    }
    return res;
  }
  Map<String, dynamic> toJson() => {
    "imagenes": imagenes,
  };
  @override
  String toString() {
    return 'Campus{id: $id, imagenes: $imagenes}';
  }
  
}