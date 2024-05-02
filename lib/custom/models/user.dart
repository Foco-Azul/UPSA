import 'dart:convert';
    
// getting a list of users from json
List<User> UserFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));
// getting a single user from json
User singleUserFromJson(String str) => User.fromJson(json.decode(str)["user"]);
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
    //"userMeta": userMeta,
    //"role": role,
  };
  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, provider: $provider, confirmed: $confirmed, blocked: $blocked, createdAt: $createdAt, updatedAt: $updatedAt, completada: $completada}';
  }
  
}

// getting a single user from json
UserMeta singleUserMetaFromJson(String str) => UserMeta.fromJsonMeta(json.decode(str)["data"]["attributes"]);

UserMeta getSingleUserMetaFronJson(String str) => UserMeta.fromJsonMeta(json.decode(str)['data']['attributes']);

// user class
class UserMeta {

  String? primerNombre;
  String? segundoNombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  String? cedulaDeIdentidad;
  String? extension;
  String? sexo;
  String? fechaDeNacimiento;
  String? celular1;
  String? celular2;
  String? telfDomicilio;
  String? departamentoColegio;
  String? colegio;
  String? cursoDeSecundaria;
  String? tutorNombres;
  String? tutorApellidoPaterno;
  String? tutorApellidoMaterno;
  String? tutorCelular;
  String? tutorEmail;
  String? hermano;
  String? tieneHermano;
  String? hijoDeGraduadoUpsa;

  UserMeta({
    this.primerNombre,
    this.segundoNombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.cedulaDeIdentidad,
    this.extension,
    this.sexo,
    this.fechaDeNacimiento,
    this.celular1,
    this.celular2,
    this.telfDomicilio,
    this.departamentoColegio,
    this.colegio,
    this.cursoDeSecundaria,
    this.tutorNombres,
    this.tutorApellidoPaterno,
    this.tutorApellidoMaterno,
    this.tutorCelular,
    this.tutorEmail,
    this.hermano,
    this.tieneHermano,
    this.hijoDeGraduadoUpsa,
  });

  factory UserMeta.fromJsonMeta(Map<String, dynamic> json) => UserMeta(
    primerNombre: json["primerNombre"] ?? "",
    segundoNombre: json["segundoNombre"] ?? "",
    apellidoPaterno: json["apellidoPaterno"] ?? "",
    apellidoMaterno: json["apellidoMaterno"] ?? "",
    cedulaDeIdentidad: json["cedulaDeIdentidad"] ?? "",
    extension: json["extension"] ?? "",
    sexo: json["sexo"] ?? "",
    fechaDeNacimiento: json["fechaDeNacimiento"] ?? "",
    celular1: json["celular1"] != null ? json["celular1"].toString() : "",
    celular2: json["celular2"] != null ? json["celular2"].toString() : "",
    telfDomicilio: json["telfDomicilio"] != null ? json["telfDomicilio"].toString() : "",
    departamentoColegio: json["departamentoColegio"] ?? "",
    colegio: json["colegio"] ?? "",
    cursoDeSecundaria: json["cursoDeSecundaria"] ?? "",
    tutorNombres: (json["padreMadreTutor"] != null && json["padreMadreTutor"]!['nombres'] != null) ? json["padreMadreTutor"]!['nombres'] : "",
    tutorApellidoPaterno: (json["padreMadreTutor"] != null && json["padreMadreTutor"]!['apellidoPaterno'] != null) ? json["padreMadreTutor"]!['apellidoPaterno'] : "",
    tutorApellidoMaterno: (json["padreMadreTutor"] != null && json["padreMadreTutor"]!['apellidoMaterno'] != null) ? json["padreMadreTutor"]!['apellidoMaterno'] : "",
    tutorCelular: (json["padreMadreTutor"] != null && json["padreMadreTutor"]!['celular'] != null) ? (json["padreMadreTutor"]!)['celular'].toString() : "",
    tutorEmail: (json["padreMadreTutor"] != null && json["padreMadreTutor"]!['email'] != null) ? json["padreMadreTutor"]!['email'] : "",
    hermano: json["hermano"] ?? "",
    tieneHermano: (json["hermano"] == null || json["hermano"] == "") ? "No" : "Sí",
    hijoDeGraduadoUpsa: (json["hijoDeGraduadoUpsa"] ?? false) ? "Sí" : "No",
  );
  Map<String, dynamic> toJson() => {
    "primerNombre": primerNombre,
    "apellidoPaterno": apellidoPaterno,
    "segundoNombre": segundoNombre,
    "apellidoMaterno": apellidoMaterno,
    "cedulaDeIdentidad": cedulaDeIdentidad,
    "extension": extension,
    "sexo": sexo,
    "fechaDeNacimiento": fechaDeNacimiento,
    "celular1": celular1,
    "celular2": celular2,
    "telfDomicilio": telfDomicilio,
    "departamentoColegio": departamentoColegio,
    "colegio": colegio,
    "cursoDeSecundaria": cursoDeSecundaria,
    "tutorNombres": tutorNombres,
    "tutorApellidoPaterno": tutorApellidoPaterno,
    "tutorApellidoMaterno": tutorApellidoMaterno,
    "tutorCelular": tutorCelular,
    "tutorEmail": tutorEmail,
    "hermano": hermano,
    "tieneHermano": tieneHermano,
    "hijoDeGraduadoUpsa": hijoDeGraduadoUpsa,
  };
}
