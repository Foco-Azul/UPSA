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
    //"userMeta": userMeta,
    //"role": role,
  };
  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, provider: $provider, confirmed: $confirmed, blocked: $blocked, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
  
}

// getting a single user from json
UserMeta singleUserMetaFromJson(String str) => UserMeta.fromJsonMeta(json.decode(str)["data"]["attributes"]);

UserMeta getSingleUserMetaFronJson(String str) => UserMeta.fromJsonMeta(json.decode(str)['user_meta']);

// user class
class UserMeta {

  String? primerNombre;
  String? segundoNombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  int? telefono;

  UserMeta({
    this.primerNombre,
    this.segundoNombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.telefono,
  });

  factory UserMeta.fromJsonMeta(Map<String, dynamic> json) => UserMeta(
    primerNombre: json["primerNombre"] ?? "",
    segundoNombre: json["segundoNombre"] ?? "",
    apellidoPaterno: json["apellidoPaterno"] ?? "",
    apellidoMaterno: json["apellidoMaterno"] ?? "",
    telefono: json["telefono"] ?? 0,
  );
  Map<String, dynamic> toJson() => {
    "primerNombre": primerNombre,
    "apellidoPaterno": apellidoPaterno,
  };
}