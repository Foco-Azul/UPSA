import 'dart:convert';
import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/colegio.dart';
import 'package:flutkit/custom/models/universidad.dart';
// getting a single user from json
UserMeta singleUserMetaFromJson(String str) => UserMeta.fromJsonMeta(json.decode(str));

UserMeta getSingleUserMetaFronJson(String str) => UserMeta.fromJsonMeta(json.decode(str));

// user class
class UserMeta {
  int? id;
  String? nombres;
  String? apellidos;
  String? cedulaDeIdentidad;
  String? fechaDeNacimiento;
  String? celular1;
  bool? testVocacional;
  bool? estudiarEnBolivia;
  String? informacionCarrera;
  String? departamentoUniversidad;
  String? aplicacionTest;
  List<Map<String, dynamic>>? recibirInformacion;
  Map<String, dynamic>? promocion;
  Colegio? colegio;
  List<int>? intereses;
  List<Carrera>? carreras;
  List<Universidad>? universidades;
  String? avatar;
  Map<String, dynamic>? carreraSugerida;
  String? universidadExtranjera;

  UserMeta({
    this.id,
    this.nombres,
    this.apellidos,
    this.cedulaDeIdentidad,
    this.fechaDeNacimiento,
    this.celular1,
    this.testVocacional,
    this.estudiarEnBolivia,
    this.informacionCarrera,
    this.departamentoUniversidad,
    this.recibirInformacion,
    this.intereses,
    this.promocion,
    this.carreras,
    this.universidades,
    this.aplicacionTest,
    this.avatar,
    this.carreraSugerida,
    this.colegio,
    this.universidadExtranjera
  });

  factory UserMeta.fromJsonMeta(Map<String, dynamic> json) => UserMeta(
    id: json['data']['id'],
    nombres: json['data']['attributes']["nombres"] ?? "",
    apellidos: json['data']['attributes']["apellidos"] ?? "",
    cedulaDeIdentidad: json['data']['attributes']["cedulaDeIdentidad"] ?? "",
    fechaDeNacimiento: json['data']['attributes']["fechaDeNacimiento"] ?? "",
    celular1: json['data']['attributes']["celular1"] != null ? json['data']['attributes']["celular1"].toString() : "",
    promocion: _armarPromocion(json['data']['attributes']["promocion"]),
    colegio: _armarColegio(json['data']['attributes']["colegio"]),
    aplicacionTest: json['data']['attributes']["aplicacionTest"] ?? "",
    carreraSugerida: _armarCarreraSugerida(json['data']['attributes']["carreraSugerida"]),
    universidadExtranjera: json['data']['attributes']["universidadExtranjera"] ?? "",
    testVocacional: json['data']['attributes']["testVocacional"],
    estudiarEnBolivia: json['data']['attributes']["estudiarEnBolivia"],
    departamentoUniversidad: json['data']['attributes']["departamentoUniversidad"] ?? "",
    carreras: _armarCarreras(json['data']['attributes']["carreras"]),
    informacionCarrera: json['data']['attributes']["informacionCarrera"] ?? "",
  );
  static UserMeta armarUsuarioMetaPopulateConMetasParaFormularioPerfil(dynamic data) {
    UserMeta res = UserMeta();
    if(data != null){
      res = UserMeta(
        id: data["id"],
        nombres: data["nombres"],
        apellidos: data["apellidos"],
        celular1: data["celular1"] ?? "",
        cedulaDeIdentidad: data["cedulaDeIdentidad"] ?? "",
        fechaDeNacimiento: data["fechaDeNacimiento"] ?? "",
        colegio: _armarColegio(data["colegio"]),
      );
    }
    return res;
  }
  static UserMeta armarUsuarioMetaPopulateConMetasParaFormularioCarrera(dynamic data) {
    UserMeta res = UserMeta();
    if(data != null){
      res = UserMeta(
        id: data["id"],
        testVocacional: data["testVocacional"] ?? "",
        aplicacionTest: data["aplicacionTest"] ?? "",
        carreras: _armarCarreras(data["carreras"]),
        informacionCarrera: data["informacionCarrera"] ?? "",
        estudiarEnBolivia: data["estudiarEnBolivia"] ?? true,
        universidadExtranjera: data["universidadExtranjera"] ?? "",
        departamentoUniversidad: data["departamentoUniversidad"] ?? "",
        universidades: _armarUniversidades(data["universidades"]),
        carreraSugerida: _armarCarreraSugerida(data["carreraSugerida"]),
        recibirInformacion: _armarRecibirInformacion(data["recibirInformacion"]),
      );
    }
    return res;
  }
  static UserMeta armarUsuarioMetaPopulateParaMiPerfil(dynamic data) {
    UserMeta res = UserMeta();
    if(data != null){
      res = UserMeta(
        id: data["id"],
        nombres: data["nombres"],
        apellidos: data["apellidos"],
        avatar: data["avatar"] != null ? data["avatar"]["imagen"]["url"] : "/uploads/avatar_89f34d0255.png",
        colegio: _armarColegio(data["colegio"]),
        carreraSugerida: _armarCarreraSugerida(data["carreraSugerida"]),
      );
    }
    return res;
  }
  static Colegio _armarColegio(dynamic data){
    Colegio res = Colegio();
    if(data != null){
      res = Colegio(
        id: data["id"],
        nombre: data["nombre"],
      );
    }
    return res;
  }
  static Map<String, dynamic> _armarCarreraSugerida(dynamic data){
    Map<String, dynamic> res = {};
    if(data != null){
      res = {
        "idCarreraUpsa": data["idCarreraUpsa"] ?? -1,
        "nombre": data["nombre"] ?? "Ninguna",
        "facultad": data["facultad"] ?? "",
      };
    }else{
      res = {
        "idCarreraUpsa": -1,
        "nombre": "Ninguna",
        "facultad": "",
      };
    }
    return res;
  }
  static List<Universidad> _armarUniversidades(List<dynamic>? data){
    List<Universidad> res = [];
    if(data != null){
      for (var item in data) {
        Universidad aux = Universidad(
          id: item["id"],
          nombre: item["nombre"],
          idDepartamento: item["idDepartamento"] 
        );
        res.add(aux);
      }
    }
    return res;
  }
  static List<Carrera> _armarCarreras(List<dynamic>? data){
    List<Carrera> res = [];
    if(data != null){
      for (var item in data) {
        Carrera aux = Carrera(
          id: item["id"],
          nombre: item["nombre"],
        );
        res.add(aux);
      }
    }
    return res;
  }
  static List<Map<String, dynamic>> _armarRecibirInformacion(List<dynamic>? data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var item in data) {
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item["titulo"]
        };
        res.add(aux);
      }
    }
    return res;
  }
  static Map<String, dynamic> _armarPromocion(Map<String, dynamic> data){
    Map<String, dynamic> res = {};
    if(data["data"] != null){
      res = {"id": data["data"]["id"], "nombre": data["data"]["attributes"]["nombre"]};
    }
    return res;
  }
  Map<String, dynamic> toJson() => {
    "nombres": nombres,
    "apellidos": apellidos,
    "cedulaDeIdentidad": cedulaDeIdentidad,
    "fechaDeNacimiento": fechaDeNacimiento,
    "celular1": celular1,
  };
}
