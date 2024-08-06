import 'dart:convert';
import 'package:flutkit/custom/models/user_meta.dart';

// user class
class User {
  User({
    this.id = -1,
    this.username,
    this.email,
    this.provider,
    this.confirmed,
    this.rolCustom,
    this.estado,
    this.userMeta,
    this.actividadesSeguidas,
    this.actividadesInscritas,
    this.notificacionesHabilitadas,
    this.dispositivos,
    this.solicitudesDeTestVocacional,
    this.retroalimentaciones,
  });

  int? id;
  String? username;
  String? email;
  String? provider;
  bool? confirmed;
  String? rolCustom; 
  String? estado;
  UserMeta? userMeta;
  bool? notificacionesHabilitadas;
  List<String>? dispositivos;
  List<Map<String, dynamic>>? actividadesInscritas;
  List<Map<String, dynamic>>? actividadesSeguidas;
  List<int>? solicitudesDeTestVocacional;
  List<Map<String, dynamic>>? retroalimentaciones;

  static User fromJson(Map<String, dynamic> json){
    return User(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      provider: json["provider"],
      confirmed: json["confirmed"],
      rolCustom: json["rolCustom"],
      estado: json["estado"],
    );
  }
  static List<User> armarUsuarios(String str) {
    List<User> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData;
    for (var item in data) {
      User aux = User(
        id: item["id"],
        username: item["username"],
        email: item["email"],
        provider: item["provider"],
        confirmed: item["confirmed"],
        rolCustom: item["rolCustom"],
        estado: item["estado"],
      );
      res.add(aux);
    }
    return res;
  }
  static User armarUsuarioParaLogin(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData["user"];
    return User(
      id: data["id"],
      username: data["username"],
      email: data["email"],
      provider: data["provider"],
      confirmed: data["confirmed"],
      rolCustom: data["rolCustom"],
      estado: data["estado"],
    );
  }
  static User armarUsuario(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      username: data["username"],
      email: data["email"],
      provider: data["provider"],
      confirmed: data["confirmed"],
      rolCustom: data["rolCustom"],
      estado: data["estado"],
    );
  }
  static User armarUsuarioPorEmail(String str) {
    User res = User();
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData;
    for (var item in data) {
      res = User(
        id: item["id"],
        username: item["username"],
        email: item["email"],
        provider: item["provider"],
        confirmed: item["confirmed"],
        rolCustom: item["rolCustom"],
        estado: item["estado"],
      );
      break;
    }
    return res;
  }
  static User armarUsuarioPopulate(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      username: data["username"],
      email: data["email"],
      provider: data["provider"],
      confirmed: data["confirmed"],
      rolCustom: data["rolCustom"],
      estado: data["estado"],
      dispositivos: _armarDispositivos(data["dispositivos"]),
    );
  }
  static User armarUsuarioPopulateConMetasParaFormularioPerfil(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      estado: data["estado"],
      rolCustom: data["rolCustom"],
      username: data["username"],
      email: data["email"],
      userMeta: UserMeta.armarUsuarioMetaPopulateConMetasParaFormularioPerfil(data["userMeta"]),
    );
  }
  static User armarUsuarioPopulateConMetasParaSolitudDeTestVocacional(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      estado: data["estado"],
      rolCustom: data["rolCustom"],
      username: data["username"],
      email: data["email"],
      solicitudesDeTestVocacional: _armarSolicitudesDeTestVocacional(data["solicitudesDeTestVocacional"]),
    );
  }
  static User armarUsuarioPopulateParaRetroalimentacion(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      estado: data["estado"],
      rolCustom: data["rolCustom"],
      username: data["username"],
      email: data["email"],
      retroalimentaciones: _armarRetroalimentaciones(data["retroalimentaciones"]),
    );
  }
  static User armarUsuarioPopulateConMetasParaFormularioCarrera(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      estado: data["estado"],
      rolCustom: data["rolCustom"],
      username: data["username"],
      email: data["email"],
      userMeta: UserMeta.armarUsuarioMetaPopulateConMetasParaFormularioCarrera(data["userMeta"]),
      actividadesInscritas: _armarActividadesInscritas(data["inscripciones"], 1),
      actividadesSeguidas: _armarActividadesSeguidas(data["eventos"], data["concursos"], data["clubes"], 1),
    );
  }
  static User armarUsuarioPopulateConMetasActividades(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      estado: data["estado"],
      rolCustom: data["rolCustom"],
      username: data["username"],
      email: data["email"],
      notificacionesHabilitadas: data["notificacionesHabilitadas"] ?? true,
      userMeta: UserMeta.armarUsuarioMetaPopulateParaMiPerfil(data["userMeta"]),
      actividadesInscritas: _armarActividadesInscritas(data["inscripciones"], 1),
      actividadesSeguidas: _armarActividadesSeguidas(data["eventos"], data["concursos"], data["clubes"], 1),
      dispositivos: _armarDispositivos(data["dispositivos"]),
    );
  }
  static User armarUsuarioPopulateConActividadesPasadas(String str) {
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData;
    return User(
      id: data["id"],
      estado: data["estado"],
      rolCustom: data["rolCustom"],
      username: data["username"],
      email: data["email"],
      actividadesInscritas: _armarActividadesInscritas(data["inscripciones"], -1),
      actividadesSeguidas: _armarActividadesSeguidas(data["eventos"], data["concursos"], data["clubes"], -1),
    );
  }
  static List<Map<String, dynamic>> _armarRetroalimentaciones(dynamic data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var item in data) {
        Map<String, dynamic> aux = {};
        if(item["evento"] != null){
          aux = {
            "id": item["evento"]["id"],
            "titulo": item["evento"]["titulo"],
            "tipo": "evento",
          };
          res.add(aux);
        }
        if(item["concurso"] != null){
          aux = {
            "id": item["concurso"]["id"],
            "titulo": item["concurso"]["titulo"],
            "tipo": "concurso",
          };
          res.add(aux);
        }
        if(item["club"] != null){
          aux = {
            "id": item["club"]["id"],
            "titulo": item["club"]["titulo"],
            "tipo": "club",
          };
          res.add(aux);
        }
      }
    }
    return res;
  }
  static List<int> _armarSolicitudesDeTestVocacional(List<dynamic>? data){
    List<int> res = [];
    if(data != null){
      for (var item in data) {
        res.add(item["id"]);
      }
    }
    return res;
  }
  static List<String> _armarDispositivos(dynamic data){
    List<String> res = [];
    if(data != null){
      for (var item in data) {
        res.add(item["token"]);
      }
    }
    return res;
  }
  static List<Map<String, dynamic>> _armarActividadesInscritas(dynamic data, int cantidad){
    List<Map<String, dynamic>> res = [];
    int count = 0;
    if(data != null){
      for (var item in data) {
        if (cantidad != -1 && count >= cantidad) break;
        Map<String, dynamic> aux = {};
        if(item["evento"] != null){
          aux = {
            "id": item["evento"]["id"],
            "titulo": item["evento"]["titulo"],
            "tipo": "evento",
          };
          res.add(aux);
        }
        if(item["concurso"] != null){
          aux = {
            "id": item["concurso"]["id"],
            "titulo": item["concurso"]["titulo"],
            "tipo": "concurso",
          };
          res.add(aux);
        }
        if(item["club"] != null){
          aux = {
            "id": item["club"]["id"],
            "titulo": item["club"]["titulo"],
            "tipo": "club",
          };
          res.add(aux);
        }
        count++;
      }
    }
    return res;
  }
  static List<Map<String, dynamic>> _armarActividadesSeguidas(List<dynamic>? data1, List<dynamic>? data2, List<dynamic>? data3, int cantidad){
    List<Map<String, dynamic>> res = [];
    int count = 0;
    if (data1 != null) {
      for (var item in data1) {
        if (cantidad != -1 && count >= cantidad) break;
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item["titulo"],
          "tipo": "evento",
        };
        res.add(aux);
        count++;
      }
    }
    if (data2 != null) {
      for (var item in data2) {
        if (cantidad != -1 && count >= cantidad) break;
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item["titulo"],
          "tipo": "concurso",
        };
        res.add(aux);
        count++;
      }
    }
    if (data3 != null) {
      for (var item in data3) {
        if (cantidad != -1 && count >= cantidad) break;
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item["titulo"],
          "tipo": "club",
        };
        res.add(aux);
        count++;
      }
    }
    return res;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "provider": provider,
    "confirmed": confirmed,
    "rolCustom": rolCustom,
    "estado": estado,
  };
  
  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, provider: $provider, confirmed: $confirmed, rolCustom: $rolCustom, estado: $estado,}';
  }
}