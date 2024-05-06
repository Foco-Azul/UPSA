import 'dart:convert';
import 'dart:developer';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
    
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
      );
      print('RESPUESTA: ${response.body}');
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
  Future<User?> addUser(BuildContext context, String email, String username, String password, String primerNombre, String apellidoPaterno, String token, String tokenDispositivo) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersRegisterEndpoint'));
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"email": email, "username": username, "password": password, "role": "1", "token": token, "dispositivo": [{"pos": 1, "token": tokenDispositivo}]}));
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
      print(e);
      throw Exception(e);
    }
    return null;
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
      int idUserMeta = await _getIdUserMeta(userId) ;
      var url = Uri.parse(dotenv.get('baseUrl') + '/user-metas/'+idUserMeta.toString()+"?populate=*");
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

  Future<List<Categoria>> getCategorias () async{
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/categorias');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      print('RESPONSE: ${response.body}');
      if (response.statusCode == 200) {
        List<Categoria> _categorias = categoriaFromJson(response.body);
        return _categorias;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> registrarEstudiante(UserMeta datos, int id) async {
    await dotenv.load(fileName: ".env");
    try {
      int idUserMeta = await _getIdUserMeta(id) ;
      if(idUserMeta > 0){
        var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas/$idUserMeta");
        var response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode(
            {"data":{
              "segundoNombre": datos.segundoNombre,
              "apellidoMaterno": datos.apellidoMaterno,
              "cedulaDeIdentidad": datos.cedulaDeIdentidad,
              "extension": datos.extension == "" ? null : datos.extension,
              "sexo": datos.sexo == "" ? null : datos.sexo,
              "fechaDeNacimiento": datos.fechaDeNacimiento == "" ? null : datos.fechaDeNacimiento,
              "celular1": datos.celular1 == "" ? null : datos.celular1,
              "celular2": datos.celular2 == "" ? null : datos.celular2,
              "telfDomicilio": datos.telfDomicilio == "" ? null : datos.telfDomicilio,
              "departamentoColegio": datos.departamentoColegio == "" ? null : datos.departamentoColegio,
              "colegio": datos.colegio,
              "cursoDeSecundaria": datos.cursoDeSecundaria == "" ? null : datos.cursoDeSecundaria,
              "padreMadreTutor": {
                "nombres": datos.tutorNombres,
                "apellidoPaterno": datos.tutorApellidoPaterno,
                "apellidoMaterno": datos.tutorApellidoMaterno,
                "celular": datos.tutorCelular == "" ? null : datos.tutorCelular,
                "email": datos.tutorEmail == "" ? null : datos.tutorEmail,
              },
              "hermano": datos.hermano,
              "tieneHermano": datos.tieneHermano,
              "intereses": datos.intereses
            }}
          )
        );
        print(response.body);
        if (response.statusCode == 200) {
          if(await actualizarCompletadoUser(id, true)){
            return true;
          }else{
            return false;
          }
        } else {
          String error = jsonDecode(response.body)['error']['message'];
          throw Exception(error);
        }
      }else{
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> actualizarCompletadoUser(int id, bool estaCompletado) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + "/users/"+id.toString());
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "completada": estaCompletado
          }
        )
      );
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
  Future<int> _getIdUserMeta (int id) async{
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/users/'+id.toString()+'?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["user_meta"]["id"];
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }


  Future<Evento> getEvento(int eventoId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/eventos/'+eventoId.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Evento _evento = EventoFromJson(response.body);
        return _evento;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<int>> getEventosSeguidos(int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/users/'+userId.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<int> eventos = _crearListaEnteros(response.body, "eventos");
        return eventos;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  List<int> _crearListaEnteros(String dataString, String key) {
    List<int> res = [];
    final jsonData = json.decode(dataString);
    List<dynamic> eventos = jsonData[key];

    if (eventos != null) {
      for (var item in eventos) {
        if (item['id'] != null) {
          int id = item['id'];
          res.add(id);
        }
      }
    }

    return res;
  }
  Future<bool> setEventosSeguidos(int idUser, List<int> eventosId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/users/'+idUser.toString());
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "eventos": eventosId
          }
        )
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<int> crearInscripcionEvento(int idUser, int idEvento) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + "/inscripcions");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"data":{"user": idUser, "evento": idEvento}}));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["data"]["id"];
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<Map<int, int>> getEventosInscritos(int userId) async {
    Map<int, int> res = {};
    try {
      List<int> inscripciones = await _getEventosInscritosId(userId);
      inscripciones.forEach((inscripcion) async {
        int? idEvento = await _getEventoId(inscripcion);
        if (idEvento != null) {
          res[idEvento] = inscripcion;
        }
      });
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }
    
  Future<int> _getEventoId(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/inscripcions/'+idInscripcion.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        int evento = jsonDecode(response.body)["data"]["attributes"]["evento"]?["data"]?["id"];
        return evento;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<int>> _getEventosInscritosId(int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/users/'+userId.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<int> eventos = _crearListaEnteros(response.body, "inscripciones");
        return eventos;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}