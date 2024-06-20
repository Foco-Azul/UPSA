import 'dart:convert';
    
// getting a list of users from json
List<User> UserFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));
// getting a single user from json
User singleUserFromJson(String str) => User.fromJson(json.decode(str)["user"]);
User singleUserFromJsonUsers(String str) => User.fromJson(json.decode(str));
User singleUserFromJsonRegister(String str) => User.fromJson(json.decode(str));

// user class
class User {
  User({
    this.id,
    this.username,
    this.email,
    this.provider,
    this.confirmed,
    this.blocked,
    this.createdAt,
    this.updatedAt,
    this.completada,
    this.eventosSeguidos,
    this.qr,
    this.rolCustom,
    this.estado,
    this.actividadesInscritas,
    //required this.userMeta,
    //required this.role,
  });

  int? id;
  String? username;
  String? email;
  String? provider;
  bool? confirmed;
  bool? blocked;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? completada;
  List<int>? eventosSeguidos;
  Map<int,int> eventosInscritos = {};
  String? qr;  
  String? rolCustom; 
  String? estado;
  List<Map<String, dynamic>>? eventosSeguidos2;
  List<Map<String, dynamic>>? eventosInscritos2;
  List<Map<String, dynamic>>? concursosSeguidos;
  List<Map<String, dynamic>>? concursosInscritos;
  List<Map<String, dynamic>>? actividadesInscritas;
  List<Map<String, dynamic>>? actividadesSeguidas;
  //UserMeta userMeta;
  //int role;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    provider: json["provider"],
    confirmed: json["confirmed"],
    blocked: json["blocked"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    completada: json["completada"],
    rolCustom: json["rolCustom"],
    estado: json["estado"],
    //userMeta: json["userMeta"],
    //role: json["role"]["id"],
  );
  
  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "provider": provider,
    "confirmed": confirmed,
    "blocked": blocked,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "completada": completada,
    "rolCustom": rolCustom,
    "estado": estado,
    //"userMeta": userMeta,
    //"role": role,
  };
  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, provider: $provider, confirmed: $confirmed, blocked: $blocked, createdAt: $createdAt, updatedAt: $updatedAt, completada: $completada, rolCustom: $rolCustom, estado: $estado,}';
  }
  
}

// getting a single user from json
UserMeta singleUserMetaFromJson(String str) => UserMeta.fromJsonMeta(json.decode(str)["data"]["attributes"]);

UserMeta getSingleUserMetaFronJson(String str) => UserMeta.fromJsonMeta(json.decode(str)['data']['attributes']);

// user class
class UserMeta {

  String? nombres;
  String? apellidos;
  String? cedulaDeIdentidad;
  String? fechaDeNacimiento;
  String? celular1;
  bool? testVocacional;
  bool? estudiarBolivia;
  String? infoCar;
  String? departamentoEstudiar;
  String? aplicacionTest;
  List<String>? recibirInfo;
  Map<String, dynamic>? promocion;
  Map<String, dynamic>? colegio;
  List<int>? intereses;
  List<int>? carreras;
  List<String>? universidades;
  String? fotoPerfil;
  Map<String, String>? carreraSugerida;
  String? universidadExtranjera;

  UserMeta({
    this.nombres,
    this.apellidos,
    this.cedulaDeIdentidad,
    this.fechaDeNacimiento,
    this.celular1,
    this.testVocacional = false,
    this.estudiarBolivia = true,
    this.infoCar,
    this.departamentoEstudiar = "",
    this.recibirInfo,
    this.intereses,
    this.promocion,
    this.carreras,
    this.universidades,
    this.aplicacionTest,
    this.fotoPerfil,
    this.carreraSugerida,
    this.colegio,
    this.universidadExtranjera
  });

  factory UserMeta.fromJsonMeta(Map<String, dynamic> json) => UserMeta(
    nombres: json["nombres"] ?? "",
    apellidos: json["apellidos"] ?? "",
    cedulaDeIdentidad: json["cedulaDeIdentidad"] ?? "",
    fechaDeNacimiento: json["fechaDeNacimiento"] ?? "",
    celular1: json["celular1"] != null ? json["celular1"].toString() : "",
    promocion: _armarPromocion(json["promocion"]),
    colegio: _armarColegio(json["colegio"]),
    aplicacionTest: json["aplicacionTest"] ?? "",
    fotoPerfil: json["fotoPerfil"]?['data']?['attributes']?['url'] ?? "/uploads/avatar_89f34d0255.png", 
    carreraSugerida: json["carreraSugerida"] != null ? _carreraSugerida(json["carreraSugerida"]) : {},
    universidadExtranjera: json["universidadExtranjera"] ?? "",
  );
  static Map<String, String> _carreraSugerida(Map<String, dynamic> data){
    Map<String, String> res = {};
    if(data["carrera"] != null){
      if(data["facultad"] != null){
        res = {"carrera": data["carrera"]!, "facultad": data["facultad"]!};
      }else{
        res = {"carrera": data["carrera"]!, "facultad": ""};
      }
    }else{
      return res;
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
    static Map<String, dynamic> _armarColegio(Map<String, dynamic> data){
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
