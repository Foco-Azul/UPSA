
// Configuracion class
import 'dart:convert';

class Configuracion {
  Configuracion({
    this.version = "-1",
    this.android = "",
    this.ios = "",
    this.novedades = "",
    this.versionIos = "-1",
    this.novedadesIos = "",
  });

  String? version;
  String? android;
  String? ios;
  String? novedades;
  String? versionIos;
  String? novedadesIos;

  static Configuracion armarConfiguracion(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Configuracion(
      version: data['attributes']["version"] ?? "-1",
      android: data['attributes']["android"] ?? "",
      ios: data['attributes']["ios"] ?? "",
      novedades: data['attributes']["novedades"] ?? "",
      versionIos: data['attributes']["versionIos"] ?? "-1",
      novedadesIos: data['attributes']["novedadesIos"] ?? "",
    );
  }  
}