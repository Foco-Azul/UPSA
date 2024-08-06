// ignore_for_file: avoid_print

import 'dart:convert';
//import 'package:dio/dio.dart' as dio;
//import 'package:path/path.dart' as path;
import 'package:flutkit/custom/models/avatar.dart';
import 'package:flutkit/custom/models/carrera_upsa.dart';
import 'package:flutkit/custom/models/club.dart';
import 'package:flutkit/custom/models/contacto.dart';
import 'package:flutkit/custom/models/convenio.dart';
import 'package:flutkit/custom/models/cursillo.dart';
import 'package:flutkit/custom/models/facultad.dart';
import 'package:flutkit/custom/models/matriculate.dart';
import 'package:flutkit/custom/models/resultado.dart';
import 'package:flutkit/custom/models/sobre_nosotros.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/models/campus.dart';
import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/colegio.dart';
import 'package:flutkit/custom/models/concurso.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/models/interes.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/promocion.dart';
import 'package:flutkit/custom/models/universidad.dart';
import 'package:flutkit/custom/utils/generadores.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:flutkit/custom/models/user.dart';
    
class ApiService {
  //USER INICIO
  Future<User> login(String email, String pass, String tokenDispositivo) async {
    User res = User();
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
        res = User.armarUsuarioParaLogin(response.body);
        User usuario = await getUsuarioPopulate(res.id!);
        if(!usuario.dispositivos!.contains(tokenDispositivo)){
          usuario.dispositivos!.add(tokenDispositivo);
          await actualizarUsuarioTokens(res.id!, usuario.dispositivos!);
        }
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  login: $error');
        return res;
      }
    } catch (e) {
      print('Error en login: $e');
      return res;
    }
  }
  Future<void> actualizarUsuarioTokens(int idUser, List<String> data) async {
    List<Map<String, dynamic>> dispositivos = [];
    for (var item in data) {
      dispositivos.add(
        {
          "token": item,
        }
      );
    }
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$idUser');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "dispositivos": dispositivos
          }
        )
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<User> getUsuarioPopulate(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulate(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUsuarioPopulate: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUsuarioPopulate: $e');
      return res;
    }
  }
  Future<List<User>> getUsers(String email, String pass) async {
    List<User> res = [];
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
        res = User.armarUsuarios(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUsers: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUsers: $e');
      return res;
    }
  }
  Future<User> getUser(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuario(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUser: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUser: $e');
      return res;
    }
  }
  Future<User?> addUser(Map<String,String> data) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse(dotenv.get('baseUrl') + dotenv.get('usersRegisterEndpoint'));
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"email": data["email"], "username": data["username"], "password": data["password"], "role": "1", "codigoDeVerificacion": data["codigoDeVerificacion"], "dispositivos": [{"token": data["tokenDispositivo"]}]}));
      if (response.statusCode == 201) {
        bool seEnvioCorreo = await enviarCorreo({"codigoDeVerificacion":data["codigoDeVerificacion"]}, "Código de verificación", data["email"]!);
        if(seEnvioCorreo){
          User model = User.armarUsuario(response.body);
          crearUserMeta(model.id!, data);
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
  Future<List<Map<String, dynamic>>> getActividadesSeguidosForUserNotPopulate(int userId) async {
    List<Map<String, dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        var actividades;
        actividades = json.decode(response.body)["eventos"];
        if(actividades != null){
          for (var evento in actividades) {
            Map<String, dynamic> aux = {
              "id": evento["id"],
              "titulo": evento["titulo"],
              "actividad": "evento",
            };
            res.add(aux);
          }
        }
        actividades = json.decode(response.body)["concursos"];
        if(actividades != null){
          for (var evento in actividades) {
            Map<String, dynamic> aux = {
              "id": evento["id"],
              "titulo": evento["titulo"],
              "actividad": "concurso",
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
  Future<bool> setActividadesSeguidos(int idUser, List<Map<String, dynamic>> actividadesSeguidos, String actividad) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$idUser');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
        {
          actividad: actividadesSeguidos.map((actividad) => actividad["id"]).toList()
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
  Future<String> pedirTokenUser (int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        String token = jsonDecode(response.body)['codigoDeVerificacion'];
        return token;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
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
  Future<bool> actualizarCompletadoUser(int id, bool estaCompletado) async {
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
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$id?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["userMeta"]["id"];
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
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
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
  Future<List<Map<String,dynamic>>> getConcursosSeguidos(int userId) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = _crearActividadesSeguidos(response.body, "concursos");
        return res;
      } else {
        print('Error en getConcursosSeguidos: '+jsonDecode(response.body)['error']['message']);
        return res;
      }
    } catch (e) {
      print('Error en getConcursosSeguidos: $e');
      return res;
    }
  }
  Future<bool> setEventosSeguidos(int idUser, List<int> eventosId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$idUser');
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
  Future<int> _getActividadId(int idInscripcion, String actividad) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions/$idInscripcion?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        int evento = jsonDecode(response.body)["data"]["attributes"][actividad]?["data"]?["id"];
        return evento;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Map<String, dynamic>>> _getActividadesInscritosId2(int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> actividades = [];
        var jsonData = json.decode(response.body)["inscripciones"];
        if(jsonData != null){
          for (var inscripcion in jsonData) {
            Map<String, dynamic> aux = {
              "id": inscripcion["id"],
              "qr": inscripcion["qr"],
            };
            actividades.add(aux);
          }
        }
        return actividades;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<int>> _getActividadesInscritosId(int userId) async {
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
  Future<List<Map<String,dynamic>>> getClubesSeguidos(int userId) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Map<String,dynamic>> concursosSeguidos = _crearActividadesSeguidos(response.body, "clubes");
        return concursosSeguidos;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<User> getUserPopulateConMetasActividades(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/?populate[inscripciones][populate][0]=evento&populate[inscripciones][populate][1]=concurso&populate[inscripciones][populate][2]=club&populate[eventos][populate][0]=eventos&populate[concursos][populate][0]=concursos&populate[clubes][populate][0]=clubes&populate[userMeta][populate][0]=carreraSugerida&populate[userMeta][populate][1]=colegio.imagenes&populate[userMeta][populate][2]=avatar.imagen&populate[userMeta][populate][3]=insignias.imagen&populate[dispositivos][populate][0]=dispositivos");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulateConMetasActividades(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPopulateConMetasActividades: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPopulateConMetasActividades: $e');
      return res;
    }
  }
  Future<User> getUserPopulateConMetasParaFormularioCarrera(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/?populate[userMeta][populate][0]=carreras&populate[userMeta][populate][1]=universidades&populate[userMeta][populate][2]=recibirInformacion&populate[userMeta][populate][3]=universidad");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulateConMetasParaFormularioCarrera(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPopulateConMetasEActividades: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPopulateConMetasEActividades: $e');
      return res;
    }
  }
  Future<User> getUserPopulateConMetasParaFormularioPerfil(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/?populate[userMeta][populate][0]=colegio");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulateConMetasParaFormularioPerfil(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPopulateConMetasParaFormularioPerfil: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPopulateConMetasParaFormularioPerfil: $e');
      return res;
    }
  }
  Future<User> getUserPopulateConActividadesPasadas(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/?populate[inscripciones][populate][0]=evento&populate[inscripciones][populate][1]=concurso&populate[inscripciones][populate][2]=club&populate[eventos][populate][0]=eventos&populate[concursos][populate][0]=concursos&populate[clubes][populate][0]=clubes");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulateConActividadesPasadas(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPopulateConActividadesPasadas: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPopulateConActividadesPasadas: $e');
      return res;
    }
  }
  Future<void> setUserParaDesactivarNotificaciones(int idUser, bool estado) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$idUser');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "notificacionesHabilitadas": estado
          }
        )
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<User> getUserPopulateParaSolitudDeTestVocacional(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/?populate=*");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulateConMetasParaSolitudDeTestVocacional(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPopulateParaSolitudDeTestVocacional: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPopulateParaSolitudDeTestVocacional: $e');
      return res;
    }
  }
  Future<User> getUserPopulateParaRetroalimentacion(int id) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/$id/?populate[retroalimentaciones][populate][0]=evento&populate[retroalimentaciones][populate][1]=concurso&populate[retroalimentaciones][populate][2]=club");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPopulateParaRetroalimentacion(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPopulateParaRetroalimentacion: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPopulateParaRetroalimentacion: $e');
      return res;
    }
  }
  Future<void> setUserCursillosVistos(int userId, int cursilloId) async {
    List<int> cursillosVistos = await _getUserCursillosVistos(userId);
    bool bandera = false;
    for (var item in cursillosVistos) {
      if(item == cursilloId){
        bandera = true;
      }
    }
    if(!bandera){
      cursillosVistos.add(cursilloId);
      await dotenv.load(fileName: ".env");
      try {
        var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId');
        var response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode(
            {
              "cursillos": cursillosVistos,
            }
          )
        );
        if (response.statusCode != 200) {
          String e = jsonDecode(response.body)['error']['message'];
          print('Error en setUserCursillosVistos: $e');
        }
      } catch (e) {
        print('Error en setUserCursillosVistos: $e');
      }
    }
  }
  Future<List<int>> _getUserCursillosVistos(int id) async {
    List<int> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/users/$id/?populate=*");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = FuncionUpsa.armarListaEnterosDesdeJsonString("cursillosVistos", response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  _getUserCursillosVistos: $error');
        return res;
      }
    } catch (e) {
      print('Error en _getUserCursillosVistos: $e');
      return res;
    }
  }
  Future<User> getUserPorEmail(String data) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/?filters[\$and][0][email][\$eq]=$data");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPorEmail(response.body);
        if(res.id! != -1){
          await _setActualizarCodigoDeVerificacion(res.id!, data);
        }
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getUserPorEmail: $error');
        return res;
      }
    } catch (e) {
      print('Error en getUserPorEmail: $e');
      return res;
    }
  }
  Future<User> verificarCodigo(String email, String codigo) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}${dotenv.get('usersRegisterEndpoint')}/?filters[\$and][0][email][\$eq]=$email&filters[\$and][1][codigoDeVerificacion][\$eq]=$codigo");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = User.armarUsuarioPorEmail(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  verificarCodigo: $error');
        return res;
      }
    } catch (e) {
      print('Error en verificarCodigo: $e');
      return res;
    }
  }
  Future<void> _setActualizarCodigoDeVerificacion(int userId, String email) async {
    String codigoDeVerificacion = Generador().generarCodigoDeVerificacion();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "codigoDeVerificacion": codigoDeVerificacion,
          }
        )
      );
      if (response.statusCode == 200) {
        await enviarCorreo({"codigoDeVerificacion":codigoDeVerificacion}, "Contraseña olvidada", email);
      }else{
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en _setActualizarCodigoDeVerificacion: $e');
      }
    } catch (e) {
      print('Error en _setActualizarCodigoDeVerificacion: $e');
    }
  }
  Future<User> setActualizarContrasenia(int userId, String password) async {
    User res = User();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/users/$userId');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "password": password,
          }
        )
      );
      if (response.statusCode == 200) {
        res = User.armarUsuario(response.body);
        return res;
      }else{
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en _setActualizarCodigoDeVerificacion: $e');
        return res;
      }
    } catch (e) {
      print('Error en _setActualizarCodigoDeVerificacion: $e');
      return res;
    }
  }
  //USER FIN

  //ACTIVIDADES INICIO
  Future<int> crearInscripcionActividad(int idUser, int id, String actividad) async {
    int res = -1;
    String aux = "";
    if(actividad == "evento"){
      aux = "Evento-UPSA-";
    }
    if(actividad == "club"){
      aux = "Club-UPSA-";
    }
    if(actividad == "concurso"){
      aux = "Concurso-UPSA-";
    }
    await dotenv.load(fileName: ".env");
    try {
      DateTime now = DateTime.now();
      DateTime utcPlus4 = now.add(Duration(hours: 4));
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(utcPlus4);

      int hash = formattedDate.hashCode.abs(); // Convertir la fecha en un número
      String code = hash.toRadixString(36).toUpperCase(); // Convertir el número en una cadena en base 36

      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions');
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({
            "data": {"user": idUser, actividad: id, "qr": aux+code+idUser.toString()+id.toString()}
          }));
      if (response.statusCode == 200) {
        res = jsonDecode(response.body)["data"]["id"];
        return res;
      } else {
        print(jsonDecode(response.body)['error']['message']);
        return res;
      }
    } catch (e) {
      print(e.toString());
      return res;
    }
  }
  //ACTIVIDADES FIN

  //INSCRIPCIONES INICIO
  Future<Map<String, dynamic>> _getInscripcionForId(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions/$idInscripcion?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Map<String, dynamic> inscripcion = (json.decode(response.body))["data"]["attributes"];
        return inscripcion;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
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
            "data": {"user": idUser, "evento": idEvento, "fecha": formattedDate, "qr": "Evento-UPSA-$code$idUser$idEvento"}
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
  Future<int> _getEventoId(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions/$idInscripcion?populate=*');
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
  Future<String> getQrEvento(int idInscripcion) async {
    String res = "";
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions/$idInscripcion?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = jsonDecode(response.body)["data"]["attributes"]["qr"];
        return res;
      } else {
        print('Error en getQrEvento: '+jsonDecode(response.body)['error']['message']);
        return res;
      }
    } catch (e) {
      print('Error en getQrEvento: $e');
      return res;
    }
  }
  Future<void> marcarAsistencia(int idInscripcion) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions/$idInscripcion');
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
  Future<int> crearInscripcionConcurso(int idUser, int id) async {
    await dotenv.load(fileName: ".env");
    try {
      DateTime now = DateTime.now();
      DateTime utcPlus4 = now.add(Duration(hours: 4));
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(utcPlus4);

      int hash = formattedDate.hashCode.abs(); // Convertir la fecha en un número
      String code = hash.toRadixString(36).toUpperCase(); // Convertir el número en una cadena en base 36
      var url = Uri.parse('${dotenv.get('baseUrl')}/inscripcions');
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({
            "data": {"user": idUser, "concurso": id, "fecha": formattedDate, "qr": "Concurso-UPSA-$code$idUser$id"}
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
  //INSCRIPCIONES FIN

  //USER META INICIO
  Future<bool> crearUserMeta(int idUser, data) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"data":{"user": idUser, "nombres": data["nombres"], "apellidos": data["apellidos"]}}));
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
  Future<bool> registrarPerfil(UserMeta datos, int idUser) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas/${datos.id}");
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":{
            "nombres": capitalizeEachWord(datos.nombres!),
            "apellidos":capitalizeEachWord(datos.apellidos!),
            "cedulaDeIdentidad": datos.cedulaDeIdentidad,
            "fechaDeNacimiento": datos.fechaDeNacimiento == "" ? null : datos.fechaDeNacimiento,
            "celular1": datos.celular1 == "" ? null : datos.celular1,
            "colegio": datos.colegio!.id,
            "curso": datos.curso,
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
  Future<bool> registrarCarrera(UserMeta data, User user) async {
    List<Map<String, dynamic>> recibirInformacion = [];
    List<int> carreras = [];
    for (var item in data.recibirInformacion!) {
      recibirInformacion.add(
        {
          "titulo" : item["titulo"],
        }
      );
    }
    for (var item in data.carreras!) {
      carreras.add(item.id!);
    }
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas/${data.id.toString()}");
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":{
            "testVocacional": data.testVocacional,
            "recibirInformacion": recibirInformacion,
            "carreras": carreras,
            "aplicacionTest": data.aplicacionTest,
            "universidad": data.universidad!.id,
            "carreraSugerida": {"facultad": "", "nombre": "Ninguna", "idCarreraUpsa": -1}
          }}
        )
      );
      if (response.statusCode == 200) {
        await crearHistorialDePreferencias(user.id!, data);
        if(user.estado == "Completado"){
          return true;
        }else{
          if(await setEstadoUser(user.id!, "Perfil parte 2")){
            return true;
          }else{
            return false;
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
  Future<bool> setUserMetaAvatar(int userMetaId, int avatarId) async {
    bool res = false;
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/user-metas/$userMetaId");
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":{
            "avatar": avatarId,
          }}
        )
      );
      if (response.statusCode == 200) {
        res = true;
        return res;
      }  else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en setUserMetaAvatar: $e');
        return res;
      }
    } catch (e) {
      print('Error en setUserMetaAvatar: $e');
      return res;
    }
  }
  //USER META FIN

  //CORREOS INICIO
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
  //CORREOS FIN

  //EVENTOS INICIO
  Future<Evento> getEvento(int id) async {
    Evento res = Evento();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/$id?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Evento.armarEventoPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEvento: $e');
        return res;
      }
    } catch (e) {
      print('Error en getEvento: $e');
      return res;
    }
  }
  Future<Evento> getEventoPopulateConInscripcionesSeguidores(int id) async {
    Evento res = Evento();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/$id/?populate[categoria][populate][0]=categoria&populate[etiquetas][populate][0]=etiquetas&populate[calendario][populate][0]=calendario&populate[imagen][populate][0]=imagen&populate[imagenes][populate][0]=imagenes&populate[inscripciones][populate][0]=user&populate[usuarios][populate][0]=usuarios&populate[noticias][populate][0]=imagen&populate[noticias][populate][1]=colegios.usersMeta.user');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Evento.armarEventoPopulateConInscripcionesSeguidores(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEventoPopulateConInscripcionesSeguidores: $e');
        return res;
      }
    } catch (e) {
      print('Error en getEventoPopulateConInscripcionesSeguidores: $e');
      return res;
    }
  }
  Future<List<Evento>> getEventos() async {
    List<Evento> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Evento.armarEventosPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEventos: $e');
        return  res;
      }
    } catch (e) {
      print('Error en getEventos: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getEventosDesde(String fechaActual) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/?populate=*&filters[\$and][0][activo][\$eq]=true&filters[\$and][1][fechaDeInicio][\$gte]=$fechaActual&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Evento> eventos = Evento.armarEventosPopulateFechaOriginal(response.body);
        for (var evento in eventos) {
          Map<String,dynamic> aux = {
            "id": evento.id!,
            "titulo": evento.titulo,
            "tipo": "Evento",
            "fecha": evento.fechaDeInicio,
            "categoria": evento.categoria,
            "color": Color.fromRGBO(91, 119, 245, 0.9),
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEventosDesde: $e');
        return res;
      }
    } catch (e) {
      print('Error en getEventosDesde: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getEventosEnCurso(String fechaActual, String fechaActualMasUno) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/?filters[\$and][1][fechaDeInicio][\$lte]=$fechaActualMasUno&filters[\$and][2][fechaDeFin][\$gte]=$fechaActual&filters[\$and][0][activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200&populate[inscripciones][populate][0]=user.userMeta');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = FuncionUpsa.armarActividadesPopulateParaEscanearEntradas(response.body, "evento");
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEventosEnCurso: $e');
        return res;
      }
    } catch (e) {
      print('Error en getEventosEnCurso: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getEventosUltimas(int cantidad) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=$cantidad');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        for (var item in data) {
          Map<String,dynamic> aux = {
            "tipo":"Eventos",
            "id":  item['id'],
            "titulo": item['attributes']['titulo'],
            "descripcion": item['attributes']['descripcion'],
            "categoria": item['attributes']['categoria']['data'] != null ? item['attributes']['categoria']['data']['attributes']['nombre'] : "Sin categoria", 
            "imagen": item['attributes']['imagen']['data'] != null ? item['attributes']['imagen']['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEventosUltimas: $e');
        return res;
      }
    } catch (e) {
      print('Error en getEventosUltimas: $e');
      return res;
    }
  }
  Future<bool> setEventoSeguidores(int id, List<int> data) async {
    bool res =  false;
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/eventos/$id');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":
            {
              "usuarios": data
            }
          }
        )
      );
      if (response.statusCode == 200) {
        res = true;
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en setEventoSeguidores: $e');
        return res;
      }
    } catch (e) {
      print('Error en setEventoSeguidores: $e');
      return res;
    }
  }
  //EVENTOS FIN

  //NOTICIAS INICIO
  Future<List<Noticia>> getNoticias() async {
    List<Noticia> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/noticias/?populate[imagen][populate][0]=imagen&populate[categoria][populate][0]=categoria&populate[etiquetas][populate][0]=etiquetas&populate[colegios][populate][0]=usersMeta.user&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Noticia.armarNoticiasPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getNoticias: $e');
        return res;
      }
    } catch (e) {
      print('Error en getNoticias: $e');
      return res;
    }
  }
  Future<Noticia> getNoticia(int noticiaId) async {
    Noticia res =  Noticia();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/noticias/$noticiaId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Noticia.armarNoticiaPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getNoticia: $e');
        return res;
      }
    } catch (e) {
      print('Error en getNoticia: $e');
      return res;
    }
  }
  Future<List<Noticia>> getOtrasNoticias(int idNoticia) async {
    List<Noticia> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/noticias/?populate[imagen][populate][0]=imagen&populate[categoria][populate][0]=categoria&populate[etiquetas][populate][0]=etiquetas&populate[colegios][populate][0]=usersMeta.user&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200&filters[id][\$ne]=$idNoticia');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Noticia.armarNoticiasPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getOtrasNoticias: $e');
        return res;
      }
    } catch (e) {
      print('Error en getOtrasNoticias: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getNoticiasUltimas(int cantidad) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/noticias/?populate[imagen][populate][0]=imagen&populate[categoria][populate][0]=categoria&populate[etiquetas][populate][0]=etiquetas&populate[colegios][populate][0]=usersMeta.user&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=$cantidad');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        for (var item in data) {
          Map<String,dynamic> aux = {
            "tipo":"Noticias",
            "id":  item['id'],
            "titulo": item['attributes']['titulo'],
            "descripcion": item['attributes']['descripcion'],
            "categoria": item['attributes']['categoria']['data'] != null ? item['attributes']['categoria']['data']['attributes']['nombre'] : "Sin categoria", 
            "imagen": item['attributes']['imagen']['data'] != null ? item['attributes']['imagen']['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",
            "usuariosPermitidos": Noticia.armarListaDeEnteros(item['attributes']["colegios"]['data']),
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getNoticiasUltimas: $e');
        return res;
      }
    } catch (e) {
      print('Error en getNoticiasUltimas: $e');
      return res;
    }
  }
  //NOTICIAS FIN

  //CLUBES INICIO
  Future<List<Club>> getClubes() async {
    List<Club> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Club.armarClubesPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getClubes: $e');
        return res;
      }
    } catch (e) {
      print('Error en getClubes: $e');
      return res;
    }
  }
  Future<Club> getClub(int eventoId) async {
    Club res = Club();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/$eventoId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Club.armarClubPopulate(response.body);
        return res;
      } else {
        print('Error en getClub: '+jsonDecode(response.body)['error']['message']);
        return res;
      }
    } catch (e) {
      print('Error en getClub: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getClubesUltimas(int cantidad) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=$cantidad');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        for (var item in data) {
          Map<String,dynamic> aux = {
            "tipo":"Clubes",
            "id":  item['id'],
            "titulo": item['attributes']['titulo'],
            "descripcion": item['attributes']['descripcion'],
            "categoria": item['attributes']['categoria']['data'] != null ? item['attributes']['categoria']['data']['attributes']['nombre'] : "Sin categoria", 
            "imagen": item['attributes']['imagen']['data'] != null ? item['attributes']['imagen']['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getClubesUltimas: $e');
        return res;
      }
    } catch (e) {
      print('Error en getClubesUltimas: $e');
      return res;
    }
  }
  Future<Club> getClubPopulateConInscripcionesSeguidores(int id) async {
    Club res = Club();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/$id/?populate[categoria][populate][0]=categoria&populate[etiquetas][populate][0]=etiquetas&populate[calendario][populate][0]=calendario&populate[imagen][populate][0]=imagen&populate[imagenes][populate][0]=imagenes&populate[inscripciones][populate][0]=user&populate[usuarios][populate][0]=usuarios&populate[noticias][populate][0]=imagen&populate[usuariosHabilitados][populate][0]=usuariosHabilitados&populate[noticias][populate][1]=colegios.usersMeta.user');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Club.armarClubPopulateConInscripcionesSeguidores(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getClubPopulateConInscripcionesSeguidores: $e');
        return res;
      }
    } catch (e) {
      print('Error en getClubPopulateConInscripcionesSeguidores: $e');
      return res;
    }
  }
  Future<bool> setClubSeguidores(int id, List<int> data) async {
    bool res =  false;
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/$id');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":
            {
              "usuarios": data
            }
          }
        )
      );
      if (response.statusCode == 200) {
        res = true;
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en setClubSeguidores: $e');
        return res;
      }
    } catch (e) {
      print('Error en setClubSeguidores: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getClubesDesde(String fechaActual) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/?populate=*&filters[\$and][0][activo][\$eq]=true&filters[\$and][1][fechaDeInicio][\$gte]=$fechaActual&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Club> clubes = Club.armarClubesPopulateFechaOriginal(response.body);
        for (var item in clubes) {
          Map<String,dynamic> aux = {
            "id": item.id!,
            "titulo": item.titulo,
            "tipo": "Club",
            "fecha": item.fechaDeInicio,
            "categoria": item.categoria,
            "color": Color.fromRGBO(32, 104, 14, 1),
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getClubesDesde: $e');
        return res;
      }
    } catch (e) {
      print('Error en getClubesDesde: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getClubesEnCurso(String fechaActual, String fechaActualMasUno) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/clubes/?filters[\$and][1][fechaDeInicio][\$lte]=$fechaActualMasUno&filters[\$and][2][fechaDeFin][\$gte]=$fechaActual&filters[\$and][0][activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200&populate[inscripciones][populate][0]=user.userMeta');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = FuncionUpsa.armarActividadesPopulateParaEscanearEntradas(response.body, "club");
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getClubesEnCurso: $e');
        return res;
      }
    } catch (e) {
      print('Error en getClubesEnCurso: $e');
      return res;
    }
  }
  //CLUBES FIN
  
  //MATRICULATE  INICIO
  Future<Matriculate> getMatriculate() async {
    Matriculate res = Matriculate();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/matriculate/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = MatriculateFromJson(response.body);
        return res;
      } else {
        print('Error en getClub: '+jsonDecode(response.body)['error']['message']);
        return res;
      }
    } catch (e) {
      print('Error en getClub: $e');
      return res;
    }
  }
  //MATRICULATE  FIN

  //CONVENIO  INICIO
  Future<Convenio> getConvenioPopulateConEnlacesDePaises() async {
    Convenio res = Convenio();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/convenio/?populate[paises][populate][0]=enlaces&populate[contactos][populate][0]=contactos');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Convenio.armarConvenioPopulate(response.body);
        return res;
      }else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getConvenioPopulate: $e');
        return res;
      }
    } catch (e) {
      print('Error en getConvenioPopulate: $e');
      return res;
    }
  }
  //CONVENIO  FIN

  //PROMOCION  INICIO
  Future<List<Promocion>> getPromociones() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/promociones/?populate=*&sort=id:desc');
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
  //PROMOCION FIN

  //COLEGIO INICIO
  Future<List<Colegio>> getColegios() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/colegios/?populate=*&sort=id:desc');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Colegio> colegios = ColegiosFromJson(response.body);
        return colegios;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //COLEGIO FIN

  //CARRERA INICIO 
  Future<List<Carrera>> getCarreras() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/carreras/?populate=*&pagination[pageSize]=200');
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
  //CARRERA FIN

  //CARRERA UPSA INICIO 
  Future<CarreraUpsa> getCarreraUpsa(int carreraUpsaId) async {
    CarreraUpsa res = CarreraUpsa();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/carreras-upsa/$carreraUpsaId?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = CarreraUpsa.armarCarreraUpsaPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getCarreraUpsa: $e');
        return res;
      }
    } catch (e) {
      print('Error en getCarreraUpsa: $e');
      return res;
    }
  }
  Future<List<CarreraUpsa>> getCarrerasUpsaPopulate() async {
    List<CarreraUpsa> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/carreras-upsa/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = CarreraUpsa.armarCarrerasUpsaPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getCarrerasUpsaPopulate: $e');
        return res;
      }
    } catch (e) {
      print('Error en getCarrerasUpsaPopulate: $e');
      return res;
    }
  }
  //CARRERA UPSA FIN

  //INTERESES INICIO 
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
  //INTERESES FIN

  //eventos.upsa.edu.bo INICIO 
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
  //eventos.upsa.edu.bo FIN

  //CAMPUS INICIO 
  Future<Campus> getDatosCampus() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/campus/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Campus campus = CampusFromJson(response.body);
        return campus;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //CAMPUS FIN

  //CONCURSO INICIO 
  Future<List<Map<String,dynamic>>> getConcursosDesde(String fechaActual) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/?populate=*&filters[\$and][0][activo][\$eq]=true&filters[\$and][1][fechaDeInicio][\$gte]=$fechaActual&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Concurso> concursos = Concurso.armarConcursosPopulateFechaOriginal(response.body);
        for (var concurso in concursos) {
          Map<String,dynamic> aux = {
            "id": concurso.id!,
            "titulo": concurso.titulo,
            "tipo": "Concurso",
            "fecha": concurso.fechaDeInicio,
            "categoria": concurso.categoria,
            "color": Color.fromRGBO(243, 148, 61, 0.9),
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getConcursosDesde: $e');
        return res;
      }
    } catch (e) {
      print('Error en getConcursosDesde: $e');
      return res;
    }
  }
  Future<List<Map<String,dynamic>>> getConcursosEnCurso(String fechaActual, String fechaActualMasUno) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/?filters[\$and][1][fechaDeInicio][\$lte]=$fechaActualMasUno&filters[\$and][2][fechaDeFin][\$gte]=$fechaActual&filters[\$and][0][activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200&populate[inscripciones][populate][0]=user.userMeta');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = FuncionUpsa.armarActividadesPopulateParaEscanearEntradas(response.body, "concurso");
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getConcursosEnCurso: $e');
        return res;
      }
    } catch (e) {
      print('Error en getConcursosEnCurso: $e');
      return res;
    }
  }
  Future<Concurso> getConcursoPopulateConInscripcionesSeguidores(int id) async {
    Concurso res = Concurso();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/$id/?populate[categoria][populate][0]=categoria&populate[etiquetas][populate][0]=etiquetas&populate[calendario][populate][0]=calendario&populate[imagen][populate][0]=imagen&populate[imagenes][populate][0]=imagenes&populate[inscripciones][populate][0]=user&populate[usuarios][populate][0]=usuarios&populate[noticias][populate][0]=imagen&populate[noticias][populate][1]=colegios.usersMeta.user');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Concurso.armarConcursoPopulateConInscripcionesSeguidores(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getConcursoPopulateConInscripcionesSeguidores: $e');
        return res;
      }
    } catch (e) {
      print('Error en getConcursoPopulateConInscripcionesSeguidores: $e');
      return res;
    }
  }
  Future<List<Concurso>> getConcursos() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        List<Concurso> concursos = Concurso.armarConcursosPopulate(response.body);
        return concursos;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<Concurso> getConcurso(int id) async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/$id?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Concurso concurso = Concurso.armarConcursoPopulate(response.body);
        return concurso;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Map<String,dynamic>>> getConcursosUltimas(int cantidad) async {
    List<Map<String,dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=$cantidad');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        for (var item in data) {
          Map<String,dynamic> aux = {
            "tipo":"Concursos",
            "id":  item['id'],
            "titulo": item['attributes']['titulo'],
            "descripcion": item['attributes']['descripcion'],
            "categoria": item['attributes']['categoria']['data'] != null ? item['attributes']['categoria']['data']['attributes']['nombre'] : "Sin categoria", 
            "imagen": item['attributes']['imagen']['data'] != null ? item['attributes']['imagen']['data']['attributes']['url'] : "/uploads/default_02263f0f89.png",
          };
          res.add(aux);
        }
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getConcursosUltimas: $e');
        return res;
      }
    } catch (e) {
      print('Error en getConcursosUltimas: $e');
      return res;
    }
  }
  Future<bool> setConcursoSeguidores(int id, List<int> data) async {
    bool res =  false;
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/concursos/$id');
      var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {"data":
            {
              "usuarios": data
            }
          }
        )
      );
      if (response.statusCode == 200) {
        res = true;
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en setConcursoSeguidores: $e');
        return res;
      }
    } catch (e) {
      print('Error en setConcursoSeguidores: $e');
      return res;
    }
  }
  //CONCURSO FIN

  //SOBRE NOSOTROS INICIO 
  Future<SobreNosotros> getSobreNosotros() async {
    SobreNosotros res = SobreNosotros();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/sobre-nosotro/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = SobreNosotroFromJson(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getSobreNosotros: $e');
        return res;
      }
    } catch (e) {
      print('Error en getSobreNosotros: $e');
      return res;
    }
  }
  //SOBRE NOSOTROS FIN

  //FACULTADES INICIO 
  Future<List<Facultad>> getFacultades() async {
    List<Facultad> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/facultades/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = FacultadesFromJson(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getFacultades: $e');
        return res;
      }
    } catch (e) {
      print('Error en getFacultades: $e');
      return res;
    }
  }
  //FACULTADES FIN

  //CURSILLO INICIO 
  Future<List<Cursillo>> getCursillosPopulate() async {
    List<Cursillo> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/cursillos/?populate=*&filters[activo][\$eq]=true&sort=id:desc&pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Cursillo.armarCursillosPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getCursillosPopulate: $e');
        return res;
      }
    } catch (e) {
      print('Error en getCursillosPopulate: $e');
      return res;
    }
  }
  Future<Cursillo> getCursilloPopulate(int id) async {
    Cursillo res = Cursillo();
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/cursillos/$id?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Cursillo.armarCursilloPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getCursilloPopulate: $e');
        return res;
      }
    } catch (e) {
      print('Error en getCursilloPopulate: $e');
      return res;
    }
  }
  //CURSILLO FIN

  //CONTACTO INICIO 
  Future<Contacto> getContacto() async {
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/contacto/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        Contacto res = ContactoFromJson(response.body);
        return res;
      } else {
        throw Exception(jsonDecode(response.body)["error"]["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  //CONTACTO FIN

  //FORMULARIO DE CONTACTO INICIO
  Future<String> crearContacto(Map<String, dynamic> data) async {
    String res = "fallo";
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/formulario-de-contactos");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode({"data":{"correo": data["email"], "asunto": data["asunto"], "mensaje": data["mensaje"]}}));
      if (response.statusCode == 200) {
        res = "exito";
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  crearContacto$error');
        return res;
      }
    } catch (e) {
      print('Error en  crearContacto$e');
      return res;
    }
  }
  //FORMULARIO DE CONTACTO FIN

  //BUSCADOR INICIO 
  Future<List<Resultado>> getBusquedas(String query) async {
    List<Resultado> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/busquedas').replace(queryParameters: {
        'pagination[pageSize]': '200',
        'filters[\$or][0][titulo][\$contains]': query,
        'filters[\$or][1][descripcion][\$contains]': query,
        'filters[\$or][2][categoria][\$contains]': query,
        'filters[\$or][3][etiquetas][\$contains]': query,
        'filters[\$or][4][palabrasClaves][\$contains]': query,
        'filters[\$or][5][descripcionClave][\$contains]': query,
      });
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Resultado.armarResultadosPopulate(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  crearContacto$error');
        return res;
      }
    } catch (e) {
      print('Error en  crearContacto$e');
      return res;
    }
  }
  //BUSCADOR FIN

  //ETIQUETA INICIO 
  Future<List<Map<String, dynamic>>> getContenidosPorEtiquetas(String etiqueta) async {
    List<Map<String, dynamic>> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/etiquetas/?populate[eventos][populate][0]=eventos&populate[concursos][populate][0]=concursos&populate[clubes][populate][0]=clubes&populate[noticias][populate][0]=noticias&populate[eventos][populate][1]=categoria&populate[concursos][populate][1]=categoria&populate[clubes][populate][1]=categoria&populate[noticias][populate][1]=categoria&populate[noticias][populate][2]=colegios.usersMeta.user&filters[nombre][\$eq]=$etiqueta');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = FuncionUpsa.armarContenidoPorEtiquetas(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getEventoConInscripciones: $e');
        return res;
      }
    } catch (e) {
      print('Error en getEventoConInscripciones: $e');
      return res;
    }
  }
  //ETIQUETA FIN

  //BORRAME INICIO 

  //BORRAME FIN

  //RETROALIMENTACION INICIO 
  Future<String> crearRetroalimentacion(Map<String, dynamic> data, int userId, int actividadId, String tipo) async {
    String res = "fallo";
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/retroalimentaciones/");
      var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "data":{
              "relevancia": data["relevancia"], 
              "calidad": data["calidad"],
              "organizacion": data["organizacion"],
              "queTeGustoMas": data["queTeGustoMas"],
              "queTeGustoMenos": data["queTeGustoMenos"],
              "comoPodriamosMejorar": data["comoPodriamosMejorar"],
              "comentario": data["comentario"],
              "usuario": userId,
              tipo: actividadId,
            }
          }
        )
      );
      if (response.statusCode == 200) {
        res = "exito";
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  crearRetroalimentacion: $error');
        return res;
      }
    } catch (e) {
      print('Error en  crearRetroalimentacion: $e');
      return res;
    }
  }
  //RETROALIMENTACION FIN

  //SOLICITUD DE TEST VOCACIONAL INICIO 
  Future<String> crearSolicitudDeTestVocacional(Map<String, dynamic> data, int id) async {
    String res = "fallo";
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/solicitudes-de-test-vocacional/");
      var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
        },
        body: json.encode(
          {
            "data":{
              "fechas": data["fechas"], 
              "telefono": int.tryParse(data["telefono"]!), 
              "carreras": data["carreras"],
              "usuario": id,
            }
          }
        )
      );
      if (response.statusCode == 200) {
        res = "exito";
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  crearSolicitudDeTestVocacional$error');
        return res;
      }
    } catch (e) {
      print('Error en  crearSolicitudDeTestVocacional$e');
      return res;
    }
  }
  //SOLICITUD DE TEST VOCACIONAL FIN

  //HISTORIAL DE PREFERENCIAS INICIO 
  Future<void> crearHistorialDePreferencias(int id, UserMeta data) async {
    List<Map<String, dynamic>> aux = [];
    aux.add(
      {
        "label": "¿Ya hiciste un Test Vocacional?",
        "value": data.testVocacional == true ? "Si" : "No",
      }
    );
    if(data.testVocacional!){
      aux.add(
        {
          "label": "¿Dónde de aplicarón el test?",
          "value":  data.aplicacionTest,
        }
      );
    }
    String aux2 = "";
    for (int i = 0; i < data.carreras!.length; i++) {
      aux2 += data.carreras![i].nombre!;
      if (i < data.carreras!.length - 1) {
        aux2 += ";";
      }
    }
    aux.add(
      {
        "label": "Seleccioná hasta dos carreras que te gustaría estudiar(en orden de importancia)",
        "value": aux2,
      }
    );
    aux.add(
      {
        "label": "Seleccioná la universidad dónde te gustaría estudiar (en orden de importancia)",
        "value": data.universidad!.nombre,
      }
    );
    String aux3 = "";
    for (int i = 0; i < data.recibirInformacion!.length; i++) {
      aux3 += data.recibirInformacion![i]["titulo"];
      if (i < data.recibirInformacion!.length - 1) {
        aux3 += ";";
      }
    }
    aux.add(
      {
        "label": "¿Sobre qué aspectos te gustaría recibir información?(seleccioná todas las que aplican)",
        "value": aux3,
      }
    );
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/historiales-de-preferencias/");
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer ${dotenv.get('accesToken')}"
          },
          body: json.encode(
            {
              "data":
                {
                  "campos": aux,
                  "usuario": id,
                }
              }
            )
          );
      if (response.statusCode != 200) {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en crearHistorialDePreferencias: $e');
      }
    } catch (e) {
      print('Error en crearHistorialDePreferencias: $e');
    }
  }
  //HISTORIAL DE PREFERENCIAS FIN

  //UNIVERSIDAD INICIO 
  Future<List<Universidad>> getUniversidadesPopulate() async {
    List<Universidad> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/universidades/?pagination[pageSize]=200');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = Universidad.armarUniversidadesPopulate(response.body);
        return res;
      } else {
        String e = jsonDecode(response.body)['error']['message'];
        print('Error en getUniversidadesPopulate: $e');
        return res;
      }
    } catch (e) {
      print('Error en getUniversidadesPopulate: $e');
      return res;
    }
  }
  //UNIVERSIDAD FIN

  //CAMPO PERSONALZIADO INICIO 
  Future<List<String>> getCampoPersonalziado(int id) async {
    List<String> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse('${dotenv.get('baseUrl')}/campos-personalizados/$id/?populate=*');
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${dotenv.get('accesToken')}"});
      if (response.statusCode == 200) {
        res = FuncionUpsa.armarOpciones(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getCampoPersonalziado: $error');
        return res;
      }
    } catch (e) {
      print('Error en getCampoPersonalziado: $e');
      return res;
    }
  }
  //CAMPO PERSONALZIADO FIN

  //AVATAR INICIO 
  Future<List<Avatar>> getAvataresPopulate(int id) async {
    List<Avatar> res = [];
    await dotenv.load(fileName: ".env");
    try {
      var url = Uri.parse("${dotenv.get('baseUrl')}/avatares/?populate=*");
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${dotenv.get('accesToken')}"
          }, 
      );
      if (response.statusCode == 200) {
        res = Avatar.armarAvataresPopulate(response.body);
        return res;
      } else {
        String error = jsonDecode(response.body)['error']['message'];
        print('Error en  getAvataresPopulate: $error');
        return res;
      }
    } catch (e) {
      print('Error en getAvataresPopulate: $e');
      return res;
    }
  }
  //AVATAR FIN

  //EXTRAS INICIO
  Future<List<Map<String, dynamic>>> getActividadesInscritosForUserNotPopulate(int idUser) async {
    List<Map<String, dynamic>> res = [];
    try {
      List<int> idInscripciones = await _getActividadesInscritosId(idUser);
      idInscripciones.forEach((idInscripcion) async {
        var inscripcion = await _getInscripcionForId(idInscripcion);
        if(inscripcion["evento"]["data"] !=  null){
           Map<String, dynamic> aux = {
            "id": inscripcion["evento"]["data"]["id"], 
            "titulo": inscripcion["evento"]["data"]["attributes"]["titulo"], 
            "actividad": "evento"
            };
            res.add(aux);
        }
        if(inscripcion["concurso"]["data"] !=  null){
           Map<String, dynamic> aux = {
            "id": inscripcion["concurso"]["data"]["id"], 
            "titulo": inscripcion["concurso"]["data"]["attributes"]["titulo"], 
            "actividad": "concurso"
            };
            res.add(aux);
        }
      });
      return res;
    } catch (e) {
      return res;
    }
  }
  Future<bool> reenviarToken(int userId, String email) async {
    String token = await pedirTokenUser(userId);
    return await enviarCorreo({"codigoDeVerificacion":token}, "Código de verificación", email);
  }
  Future<bool> verificarCuenta(int userId, String tokenIngresado) async {
    String token = await pedirTokenUser(userId);
    if(tokenIngresado == token){
      return await activarCuenta(true, userId);
    }else{
      return false;
    }
  }
  List<Map<String,dynamic>> _crearActividadesSeguidos(String dataString, String key) {
    List<Map<String,dynamic>> res = [];
    final jsonData = json.decode(dataString);
    List<dynamic> actividades = jsonData[key];
    for (var item in actividades) {
      if (item['id'] != null) {
        Map<String, dynamic> aux = {"id": item['id']};
        res.add(aux);
      }
    }
    return res;
  }
  List<int> _crearListaEnteros(String dataString, String key) {
    List<int> res = [];
    final jsonData = json.decode(dataString);
    List<dynamic> actividades = jsonData[key];

    for (var item in actividades) {
      if (item['id'] != null) {
        int id = item['id'];
        res.add(id);
      }
    }
  
    return res;
  }
  Future<Map<int, int>> getEventosInscritos(int userId) async {
    Map<int, int> res = {};
    try {
      List<int> inscripciones = await _getActividadesInscritosId(userId);
      inscripciones.forEach((inscripcion) async {
        int? idEvento = await _getEventoId(inscripcion);
        res[idEvento] = inscripcion;
            });
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }
  Future<List<Map<String, dynamic>>> getConcursosInscritos(int userId) async {
    List<Map<String, dynamic>> res = [];
    try {
      List<Map<String, dynamic>> inscripciones = await _getActividadesInscritosId2(userId);
      inscripciones.forEach((inscripcion) async {
        if (inscripcion["qr"].contains("Concurso-")) {
          int? idEvento = await _getActividadId(inscripcion["id"], "concurso");
          var aux = {
            "idInscripcion": inscripcion["id"],
            "qr": inscripcion["qr"],
            "id":idEvento
          };
          res.add(aux);
        }
      });
      return res;
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
  Future<List<Noticia>> getNoticiasRelacionadasConActividad(List<int> idsNoticias) async {
    List<Noticia> res = [];
    idsNoticias.forEach((idNoticia) async {
      Noticia noticia = await getNoticia(idNoticia);
      res.add(noticia);
    });
    return res;
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
  String capitalizeEachWord(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
  Future<List<Map<String,dynamic>>> getActividades() async {
    List<Map<String,dynamic>> res = [];
    List<Map<String,dynamic>> aux = [];
    String fechaActual = obtenerFechaActual();
    aux = await getEventosDesde(fechaActual);
    res.addAll(aux);
    aux = await getConcursosDesde(fechaActual);
    res.addAll(aux);
    aux = await getClubesDesde(fechaActual);
    res.addAll(aux);
    return res;
  }
  Future<List<Map<String,dynamic>>> getActividadesConInscripciones() async {
    List<Map<String,dynamic>> res = [];
    List<Map<String,dynamic>> aux = [];
    String fechaActual = obtenerFechaActual();
    String fechaActualMasUno = obtenerFechaActualMasUno();
    aux = await getEventosEnCurso(fechaActual, fechaActualMasUno);
    res.addAll(aux);
    aux = await getConcursosEnCurso(fechaActual, fechaActualMasUno);
    res.addAll(aux);
    aux = await getClubesEnCurso(fechaActual, fechaActualMasUno);
    res.addAll(aux);
    return res;
  }
  String obtenerFechaActual() {
    DateTime ahora = DateTime.now();
    DateFormat formato = DateFormat('yyyy-MM-dd');
    return formato.format(ahora);
  }
String obtenerFechaActualMasUno() {
  DateTime ahora = DateTime.now();
  DateTime fechaMasUno = ahora.add(Duration(days: 1));
  DateFormat formato = DateFormat('yyyy-MM-dd');
  return formato.format(fechaMasUno);
}
  Future<List<Concurso>> getConcursosPorIds(List<int> idsConcursos) async {
    List<Concurso> res = [];
    for (var item in idsConcursos) {
        Concurso concurso =await getConcurso(item);
        res.add(concurso);
    }
    return res;
  }
  Future<List<Map<String, dynamic>>> getContenido() async {
    List<Map<String, dynamic>> res = [];
    List<Map<String, dynamic>> aux = [];
    aux = await getEventosUltimas(5);
    res.addAll(aux);
    aux = await getConcursosUltimas(5);
    res.addAll(aux);
    aux = await getClubesUltimas(5);
    res.addAll(aux);
    aux = await getNoticiasUltimas(5);
    res.addAll(aux);
    return res;
  }
  Future<List<Map<String, dynamic>>> getClubesInscritos(int userId) async {
    List<Map<String, dynamic>> res = [];
    try {
      List<Map<String, dynamic>> inscripciones = await _getActividadesInscritosId2(userId);
      inscripciones.forEach((inscripcion) async {
        if (inscripcion["qr"].contains("Club-")) {
          int? idEvento = await _getActividadId(inscripcion["id"], "club");
          var aux = {
            "idInscripcion": inscripcion["id"],
            "qr": inscripcion["qr"],
            "id":idEvento
          };
          res.add(aux);
        }
      });
      return res;
    } catch (e) {
      print('Error en getClubesInscritos: $e');
      return res;
    }
  }
  //EXTRAS FIN
  
  /*
  Future<bool> setUserMetaFotoPerfil2(int userId, File foto) async {
    dio.FormData formData = dio.FormData();

    // Adjuntar el archivo al formulario
    formData.files.add(MapEntry(
      "files",
      await MultipartFile.fromFile(foto.path, filename: path.basename(foto.path)),
    ));

    // Realizar la solicitud con dio
    try {
      Response response = await Dio().post(
        'https://upsa.focoazul.com/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer 4ef15e28c1a0d4938ce4e52d0a4843399e4283410d8b12306e3134a6cfee6e4ca7bdb2c65694fd5c037e332e5683d60cfbe32c2850068682d3eaddab77de21e01ddc88c3ace56b9c48034ad61b29090d94c983fa2885c589b609de75bbe3fdf2c67faf39233468c53b6077220f7c2de14f4666b9b37e639e022b129190371ebe',
          },
        ),
      );

      // Manejar la respuesta
      print(response.data);
    } catch (e) {
      print('Error al enviar formulario: $e');
      return false;
    }
    return true;
  }
  Future<bool> setUserMetaFotoPerfil(int userId, File file) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('https://upsa.focoazul.com/api/user-metas/31'),
    );
    var stream = http.ByteStream(file.openRead());
    stream.cast();
    var length = await file.length();
    var multipartFileSign = http.MultipartFile(
      'files.fotoPerfil',
      stream,
      length,
      filename: file.path.split('/').last,
      //contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFileSign);
    var emptyData = jsonEncode({});
    request.fields['data'] = emptyData;
    String token = '4ef15e28c1a0d4938ce4e52d0a4843399e4283410d8b12306e3134a6cfee6e4ca7bdb2c65694fd5c037e332e5683d60cfbe32c2850068682d3eaddab77de21e01ddc88c3ace56b9c48034ad61b29090d94c983fa2885c589b609de75bbe3fdf2c67faf39233468c53b6077220f7c2de14f4666b9b37e639e022b129190371ebe'; // Reemplaza con tu token Bearer
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });
    var response = await request.send();
    if (response.statusCode == 200) {
       print(response.stream.bytesToString());
       return true;
    } else {
      throw Exception('Failed to upload media file');
    }
  }
  */
}