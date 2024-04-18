import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:upsa/custom/models/user.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
    
class ApiService {
  //LOGIN
  Future<User?> login(String email, String pass) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersEndpoint'));
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
        body: json.encode({ 
          "identifier": email, 
          "password": pass 
          }),
        //body: body,
      );

      if (response.statusCode == 200) {
        User _model = singleUserFromJson(response.body);
        return _model;
      } else {
        if(response.statusCode == 400){
          return User();
        }else{
          String error = jsonDecode(response.body)['error']['message'];
          throw Exception(error);
        }
      }
    } catch (e) {
      log(e.toString());
      return null; // Opcional: devuelve null en caso de error
    }
  }
  // Getting users
  Future<User?> getUsers(String email, String pass) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersEndpoint'));
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
        body: json.encode({ 
          "identifier": email, 
          "password": pass 
          }),
        //body: body,
      );
      print(response.body);
      if (response.statusCode == 200) {
        User _model = singleUserFromJson(response.body);
        return _model;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      log(e.toString());
      return null; // Opcional: devuelve null en caso de error
    }
  }

    
  // Adding user
  Future<User?> addUser(BuildContext context, String email, String username, String password, String primerNombre, String apellidoPaterno, String token) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersRegisterEndpoint'));
      var response = await http.post(url,
          headers: {
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: {"email": email, "username": username, "password": password, "role": "1", "token": token});
      if (response.statusCode == 201) {
        dynamic jsonResponse = jsonDecode(response.body);
        bool seCreoUserMeta = await registrarMeta(context, jsonResponse["id"], primerNombre, apellidoPaterno);
        if(seCreoUserMeta){
          bool seEnvioCorreo = await enviarCorreo({"codigoDeVerificacion":token}, "Código de verificación", email);
          if(seEnvioCorreo){
            User _model = singleUserFromJsonRegister(response.body);
            return _model;
          }
        }
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> registrarMeta(BuildContext context, int idUser, String primerNombre, String apellidoPaterno) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + "/user-metas");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body:  json.encode({"data":{"primerNombre": primerNombre, "apellidoPaterno": apellidoPaterno, "user": idUser}}));
      if (response.statusCode == 200) {
        UserMeta _model = singleUserMetaFromJson(response.body);
        Provider.of<AppNotifier>(context, listen: false).setUserMeta(_model);
        return true;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> enviarCorreo(Object token, String motivo, String email) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + "/correos");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"data":{"destino": email, "motivo": motivo, "contenidoJson": token}}));
      if (response.statusCode == 200) {
        return true;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> reenviarToken(int userId, String email) async {
    String token = await pedirTokenUser(userId);
    return await enviarCorreo({"codigoDeVerificacion":token}, "Código de verificación", email);
  }
  Future<String> pedirTokenUser (int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/users/'+userId.toString());
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        String _token = jsonDecode(response.body)['token'];
        return _token;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> verificarCuenta(int userId, String tokenIngresado) async {
    String token = await pedirTokenUser(userId);
    if(tokenIngresado == token){
      return await activarCuenta(true, userId);
    }else{
      return false;
    }
  }
  Future<bool> activarCuenta(bool estado, int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + "/users/"+userId.toString());
      var response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"confirmed":true}));
      if (response.statusCode == 200) {
        return true;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<UserMeta> getUserMeta (int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/users/'+userId.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        UserMeta _userMeta = getSingleUserMetaFronJson(response.body);
        return _userMeta;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}