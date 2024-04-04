import 'dart:convert';
    import 'dart:developer';
    import 'package:http/http.dart' as http;
    import 'package:flutter_dotenv/flutter_dotenv.dart';
    import 'package:upsa/models/user.dart';
    import 'package:upsa/models/post.dart';
    
    class ApiService {
      // Getting users
      Future<List<User>?> getUsers() async {
        await dotenv.load(fileName: ".env");
        try {
          var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersEndpoint'));
          var response = await http.get(url,
              //headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
              headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
          if (response.statusCode == 200) {
            List<User> _model = UserFromJson(response.body);
            return _model;
          } else {
            String error = jsonDecode(response.body)['error']['message'];
            throw Exception(error);
          }
        } catch (e) {
          log(e.toString());
        }
      }
    
      // Adding user
      Future<User?> addUser(String email, String username, String password) async {
        await dotenv.load(fileName: ".env");
        try {
          var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersEndpoint'));
          var response = await http.post(url,
              headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"},
              body: {"email": email, "username": username, "password": password, "role": "2"});
    
          if (response.statusCode == 201) {
            User _model = singleUserFromJson(response.body);
            return _model;
          } else {
            String error = jsonDecode(response.body)['error']['message'];
            throw Exception(error);
          }
        } catch (e) {
          throw Exception(e);
        }
      }
    
      // Getting posts
      Future<List<Post>?> getPosts() async {
        try {
          var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('postsEndpoint'));
          var response = await http.get(url,
              headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
    
          if (response.statusCode == 200) {
            var _model = postFromJson(jsonDecode(response.body)['data']);
            return _model;
          } else {
            throw Exception(jsonDecode(response.body)["error"]["message"]);
          }
        } catch (e) {
          throw Exception(e);
        }
      }
    }