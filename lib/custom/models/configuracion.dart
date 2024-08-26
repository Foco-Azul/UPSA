
// Configuracion class
import 'dart:convert';

class Configuracion {
  Configuracion({
    this.version = "-1",
    this.android = "",
    this.ios = "",
    this.novedades = "",
  });

  String? version;
  String? android;
  String? ios;
  String? novedades;

  static Configuracion armarConfiguracion(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Configuracion(
      version: data['attributes']["version"] ?? "",
      android: data['attributes']["android"] ?? "",
      ios: data['attributes']["ios"] ?? "",
      novedades: data['attributes']["novedades"] ?? "",
    );
  }  
}