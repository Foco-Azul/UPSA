
// Configuracion class
import 'dart:convert';

class Configuracion {
  Configuracion({
    this.version,
    this.android,
    this.ios,
  });

  String? version;
  String? android;
  String? ios;

  static Configuracion armarConfiguracion(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    return Configuracion(
      version: data['attributes']["version"] ?? "",
      android: data['attributes']["android"] ?? "",
      ios: data['attributes']["ios"] ?? "",
    );
  }  
}