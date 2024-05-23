import 'dart:convert';
import 'dart:developer';
import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/models/interes.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/promocion.dart';
import 'package:flutkit/custom/models/universidad.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
    
class ApiService {
  //USER
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
      if (response.statusCode == 200) {
        User model = singleUserFromJson(response.body);
        return model;
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
  Future<User?> getUserForId(int idUser) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$idUser?populate=*");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        User model = singleUserFromJsonUsers(response.body);
        return model;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      log(e.toString());
      return null; // Opcional: devuelve null en caso de error
    }
  }
  Future<List<Map<String, dynamic>>> getEventosInscritosForUserNotPopulate(int idUser) async {
    List<Map<String, dynamic>> res = [];
    try {
      List<int> idInscripciones = await _getEventosInscritosId(idUser);
      idInscripciones.forEach((idInscripcion) async {
        var inscripcion = await _getEventoForId(idInscripcion);
          Map<String, dynamic> aux = {
            "id": inscripcion["id"], 
            "titulo": inscripcion["attributes"]["titulo"], 
            "actividad": "evento"
            };
          res.add(aux);
      });
      return res;
    } catch (e) {
      return res;
    }
  }
  Future<Map<String, dynamic>> _getEventoForId(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions/$idInscripcion?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Map<String, dynamic> inscripcion = (json.decode(response.body))["data"]["attributes"]["evento"]["data"];
        return inscripcion;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Map<String, dynamic>>> getEventosSeguidosForUserNotPopulate(int userId) async {
    List<Map<String, dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        var eventos = json.decode(response.body)["eventos"];
        if(eventos != null){
          for (var evento in eventos) {
            Map<String, dynamic> aux = {
              "id": evento["id"],
              "titulo": evento["titulo"],
              "actividad": "evento",
            };
            res.add(aux);
          }
        }
        return res;
      } else {
        print(jsonDecode(response.body)["error"]["message"]);
        return res;
      }
    } catch (e) {
      print(e);
      return res;
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
      if (response.statusCode == 200) {
        User model = singleUserFromJson(response.body);
        return model;
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
  Future<User?> addUser(String email, String username, String password, String token, String tokenDispositivo) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersRegisterEndpoint'));
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"email": email, "username": username, "password": password, "role": "1", "token": token, "dispositivos": [{"token": tokenDispositivo}]}));
      if (response.statusCode == 201) {
        bool seEnvioCorreo = await enviarCorreo({"codigoDeVerificacion":token}, "Código de verificación", email);
        if(seEnvioCorreo){
          User model = singleUserFromJsonRegister(response.body);
          return model;
        }
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
    return null;
  }
  Future<bool> enviarCorreo(Object token, String motivo, String email) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/correos");
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
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        String token = jsonDecode(response.body)['token'];
        return token;
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
      var url = Uri.parse("${dotenv.get('baseUrl')}/users/$userId");
      var response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"confirmed":true, "estado": "Verificado"}));
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
      var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas/+${idUserMeta.toString()}+?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        UserMeta userMeta = getSingleUserMetaFronJson(response.body);
        return userMeta;
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
      var url = Uri.parse(dotenv.get('baseUrl') + '/categorias/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Categoria> _categorias = categoriasEventosFromJson(response.body);
        return _categorias;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> registrarPerfil(UserMeta datos, int idUser) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas/");
      var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":{
            "user": idUser,
            "nombres": capitalizeEachWord(datos.nombres!),
            "apellidos":capitalizeEachWord(datos.apellidos!),
            "cedulaDeIdentidad": datos.cedulaDeIdentidad,
            "fechaDeNacimiento": datos.fechaDeNacimiento == "" ? null : datos.fechaDeNacimiento,
            "celular1": datos.celular1 == "" ? null : datos.celular1,
            "promocion": datos.promocion!["id"],
          }}
        )
      );
      if (response.statusCode == 200) {
        if(await setEstadoUser(idUser, "Perfil parte 1")){
          return true;
        }else{
          return false;
        }
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<bool> setEstadoUser(int id, String estado) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/users/$id");
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "estado": estado
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
  Future<bool> registrarCarrera(UserMeta datos, int id) async {
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
              "testVocacional": datos.testVocacional,
              "estudiarBolivia": datos.estudiarBolivia,
              "infoCar": datos.infoCar,
              "departamentoEstudiar": datos.departamentoEstudiar,
              "recibirInfo": datos.recibirInfo,
              "carreras": datos.carreras,
              "aplicacionTest": datos.aplicacionTest,
              "universidades": datos.universidades != null ? datos.universidades!.map((nombre) => {'nombre': nombre}).toList() : [],
            }}
          )
        );
        if (response.statusCode == 200) {
          if(await setEstadoUser(id, "Perfil parte 2")){
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
  Future<bool> registrarIntereses(UserMeta datos, int id) async {
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
              "intereses": datos.intereses,
            }}
          )
        );
        if (response.statusCode == 200) {
          if(await setEstadoUser(id, "Completado")){
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

  //EVENTOS
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

    for (var item in eventos) {
      if (item['id'] != null) {
        int id = item['id'];
        res.add(id);
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
      DateTime now = DateTime.now();
      DateTime utcPlus4 = now.add(Duration(hours: 4));
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(utcPlus4);

      int hash = formattedDate.hashCode.abs(); // Convertir la fecha en un número
      String code = hash.toRadixString(36).toUpperCase(); // Convertir el número en una cadena en base 36
      var url = Uri.parse(dotenv.get('baseUrl') + "/inscripcions");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({
            "data": {"user": idUser, "evento": idEvento, "fecha": formattedDate, "qr": "Evento-UPSA-"+code+idUser.toString()+idEvento.toString()}
          }));
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
        res[idEvento] = inscripcion;
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
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
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
  Future<String> getQrEvento(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/inscripcions/'+idInscripcion.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        String qr = jsonDecode(response.body)["data"]["attributes"]["qr"];
        return qr;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Evento>> getEventos() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/eventos/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Evento> _eventos = EventosFromJson(response.body);
        return _eventos;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<void> marcarAsistencia(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/inscripcions/'+idInscripcion.toString());
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "data":{
              "asistencia": true
            }
          }
        )
      );
      if (response.statusCode == 200) {
        //return true;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Evento>> getEventosPorIds(List<int> idsEventos) async {
    List<Evento> res = [];
    for (var item in idsEventos) {
        Evento evento =await getEvento(item);
        res.add(evento);
    }
    return res;
  }

  //NOTICIAS
  Future<List<Categoria>> getCategoriasNoticias () async{
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/categoria-noticias/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Categoria> _categorias = categoriasNoticiasFromJson(response.body);
        return _categorias;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Noticia>> getNoticiasRelacionadasConEvento(List<int> idsNoticias) async {
    List<Noticia> res = [];
    idsNoticias.forEach((idNoticia) async {
      Noticia noticia = await getNoticia(idNoticia);
      res.add(noticia);
    });
    return res;
  }
  Future<List<Noticia>> getNoticias() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/noticias/?populate=*&sort=id:desc');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Noticia> noticias = NoticiasFromJson(response.body);
        return noticias;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Noticia>> getNoticiasPorIdsCategorias(List<Categoria> categorias) async {
    List<Noticia> res = [];
    for (var categoria in categorias) {
        for (var lista in categoria.idsContenido!) {
          Noticia noticia =await getNoticia(lista);
          res.add(noticia);
        }
    }
    return res;
  }
  Future<List<Noticia>> getNoticiasPorIdsCategoria(List<int> idsNoticias) async {
    List<Noticia> res = [];
    for (var item in idsNoticias) {
        Noticia noticia =await getNoticia(item);
        res.add(noticia);
    }
    return res;
  }
  Future<Noticia> getNoticia(int noticiaId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/noticias/'+noticiaId.toString()+"?populate=*");
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Noticia noticia = NoticiaFromJson(response.body);
        return noticia;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Noticia>> getOtrasNoticias(int idNoticia) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/noticias/?populate=*&filters[id][\$ne]='+idNoticia.toString()+'&sort=id:desc');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Noticia> noticia = NoticiasFromJson(response.body);
        return noticia;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //PROMOCIONES
  Future<List<Promocion>> getPromociones() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/promociones/?populate=*&sort=id:desc');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Promocion> promociones = PromocionesFromJson(response.body);
        return promociones;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //CARRERAS
  Future<List<Carrera>> getCarreras() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + '/carreras/?populate=*&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Carrera> carreras = CarrerasFromJson(response.body);
        return carreras;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //INTERESES
  Future<List<Interes>> getIntereses() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/intereses/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Interes> intereses = InteresesFromJson(response.body);
        return intereses;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //UNIVERSIDAD
  Future<List<Universidad>> getUnivesidadeForId(int idUniversidad) async {
    try {
      var url = Uri.parse('https://eventos.upsa.edu.bo/universidad-depto/${idUniversidad.toString()}');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<Universidad> universidades = UniversidadesFromJson(response.body);
        return universidades;
      } else {
        throw Exception("Algo salio mal");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //EXTRAS
  String capitalizeEachWord(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
}