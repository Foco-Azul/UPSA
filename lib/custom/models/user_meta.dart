import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/colegio.dart';
import 'package:flutkit/custom/models/universidad.dart';
import 'package:flutkit/custom/utils/funciones.dart';

// user class
class UserMeta {
  int? id;
  String? nombres;
  String? apellidos;
  String? cedulaDeIdentidad;
  String? fechaDeNacimiento;
  String? celular1;
  bool? testVocacional;
  String? aplicacionTest;
  List<Map<String, dynamic>>? recibirInformacion;
  Map<String, dynamic>? promocion;
  Colegio? colegio;
  List<int>? intereses;
  List<Carrera>? carreras;
  Universidad? universidad;
  String? avatar;
  Map<String, dynamic>? carreraSugerida;
  String? curso;
  List<Map<String, dynamic>>? insignias;

  UserMeta({
    this.id,
    this.nombres,
    this.apellidos,
    this.cedulaDeIdentidad,
    this.fechaDeNacimiento,
    this.celular1,
    this.testVocacional,
    this.recibirInformacion,
    this.intereses,
    this.promocion,
    this.carreras,
    this.universidad,
    this.aplicacionTest,
    this.avatar,
    this.carreraSugerida,
    this.colegio,
    this.curso,
    this.insignias,
  });

  static UserMeta armarUsuarioMetaPopulateConMetasParaFormularioPerfil(dynamic data) {
    UserMeta res = UserMeta();
    if(data != null){
      res = UserMeta(
        id: data["id"],
        nombres: data["nombres"],
        apellidos: data["apellidos"],
        celular1: data["celular1"] != null ? data["celular1"].toString() : "",
        cedulaDeIdentidad: data["cedulaDeIdentidad"] ?? "",
        fechaDeNacimiento: data["fechaDeNacimiento"] ?? "",
        colegio: _armarColegio(data["colegio"]),
        curso: data["curso"] ?? "",
      );
    }
    return res;
  }
  static UserMeta armarUsuarioMetaPopulateConMetasParaSolitudDeTestVocacional(dynamic data) {
    UserMeta res = UserMeta();
    if(data != null){
      res = UserMeta(
        id: data["id"],
        nombres: data["nombres"],
        apellidos: data["apellidos"],
        celular1: data["celular1"] != null ? data["celular1"].toString() : "",
        cedulaDeIdentidad: data["cedulaDeIdentidad"] ?? "",
        fechaDeNacimiento: data["fechaDeNacimiento"] ?? "",
        curso: data["curso"] ?? "",
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
        universidad: _armarUniversidad(data["universidad"]),
        carreraSugerida: _armarCarreraSugerida(data["carreraSugerida"]),
        recibirInformacion: _armarRecibirInformacion(data["recibirInformacion"]),
      );
    }
    return res;
  }
  static Universidad _armarUniversidad(dynamic data){
    Universidad res = Universidad();
    if(data != null){
      res = Universidad(
        id: data["id"],
        nombre: data["nombre"], 
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
        insignias: _armarInsignias(data["insignias"]),
      );
    }
    return res;
  }
  static List<Map<String, dynamic>> _armarInsignias(dynamic data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var item in data) {
        res.add(
          {
            "id": item["id"],
            "nombre": item["nombre"],
            "imagen": item["imagen"] != null ? item["imagen"]["url"] : "/uploads/avatar_89f34d0255.png",
            "mensaje": item["mensaje"] ?? "",
            "colorFondo": item["colorFondo"] ?? "A_6E51D9",
            "nombreCorto": item["nombreCorto"] ?? "",
          }
        );  
      }
    }
    return res;
  }
  static Colegio _armarColegio(dynamic data){
    Colegio res = Colegio();
    if(data != null){
      List<String> aux = FuncionUpsa.armarGaleriaDeImagenes("imagenesColegio", data["imagenes"]);
      res = Colegio(
        id: data["id"],
        nombre: data["nombre"],
        imagenes: aux,
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

  
  Map<String, dynamic> toJson() => {
    "nombres": nombres,
    "apellidos": apellidos,
    "cedulaDeIdentidad": cedulaDeIdentidad,
    "fechaDeNacimiento": fechaDeNacimiento,
    "celular1": celular1,
  };

}
