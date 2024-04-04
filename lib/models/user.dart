import 'dart:convert';
    
    // getting a list of users from json
    List<User> UserFromJson(String str) =>
       List<User>.from(json.decode(str).map((x) => User.fromJson(x)));
    // getting a single user from json
    User singleUserFromJson(String str) => User.fromJson(json.decode(str));
    
    // user class
    class User {
      User({
       required this.id,
       required this.username,
       required this.email,
       required this.provider,
       required this.confirmed,
       required this.blocked,
       required this.createdAt,
       required this.updatedAt,
      });
    
      int id;
      String username;
      String email;
      String provider;
      bool confirmed;
      bool blocked;
      DateTime createdAt;
      DateTime updatedAt;
    
      factory User.fromJson(Map<String, dynamic> json) => User(
         id: json["id"],
         username: json["username"],
         email: json["email"],
         provider: json["provider"],
         confirmed: json["confirmed"],
         blocked: json["blocked"],
         createdAt: DateTime.parse(json["createdAt"]),
         updatedAt: DateTime.parse(json["updatedAt"]),
        );
    }