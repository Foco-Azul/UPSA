import 'dart:convert';

import 'package:flutkit/custom/models/categoria.dart';
import 'package:intl/intl.dart';

class FuncionUpsa {
  static List<String> armarGaleriaImagenes(List<dynamic>? datas, dynamic data){
    List<String> res = [];
    if(data != null){
      res.add(data["attributes"]["url"]);
    }
    if(datas != null){
      for (var item in datas) {
        res.add(item["attributes"]["url"]);
      }
    }
    return res;
  }
  static String armarFechaPublicacion(String data) {
    DateTime fechaPublicacion = DateTime.parse(data);
    DateTime ahora = DateTime.now();
    Duration diferencia = ahora.difference(fechaPublicacion);

    if (diferencia.inHours < 24) {
      return "Hace ${diferencia.inHours} horas";
    } else {
      int dias = diferencia.inDays;
      if (diferencia.inHours % 24 != 0) {
        dias++; // Añadir un día si hay horas extras
      }
      return "Hace $dias días";
    }
  }
  static String armarfechaDeInicioFinConHora(String data) {
    DateTime dateTime = DateTime.parse(data).toLocal();
    DateFormat dateFormatDate = DateFormat('dd MMMM', 'es_ES');
    DateFormat dateFormatTime = DateFormat('HH:mm', 'es_ES');
    
    String formattedDate = dateFormatDate.format(dateTime);
    String formattedTime = dateFormatTime.format(dateTime);
    
    return '$formattedDate - $formattedTime';
  }
  static List<int> armarSeguidores(List<dynamic> data){
    List<int> res = [];
    for (var item in data) {
      res.add(item["id"]);
    }
    return res;
  }
  static String _armarFechaLiteral(String fecha) {
    // Dividir la cadena en año, mes y día
    List<String> partes = fecha.split('-');
    if (partes.length != 3) {
      throw ArgumentError('La fecha debe estar en formato YYYY-MM-DD');
    }

    // Convertir el mes a nombre
    List<String> meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    int mes = int.tryParse(partes[1]) ?? 0;
    if (mes < 1 || mes > 12) {
      throw ArgumentError('El mes debe estar entre 1 y 12');
    }

    // Crear la fecha en el formato deseado
    return '${int.parse(partes[2])} de ${meses[mes]} del ${partes[0]}';
  }
  static List<Map<String, dynamic>> armarFechaCalendarioConHora(List<dynamic> data) {
    List<Map<String, dynamic>> res = [];
    for (var item in data) {
      Map<String, dynamic> aux = {
        "titulo":item['titulo'],
        "fechaDeInicio":_armarFechaLiteral(item['fechaDeInicio']),
        "fechaDeFin": item['fechaDeFin'] != null ? _armarFechaLiteral(item['fechaDeFin']) : "",
        "horaDeInicio": item['horaDeInicio'] != null ? DateFormat('HH:mm').format(DateFormat('HH:mm:ss.SSS').parseUTC(item["horaDeInicio"]).toLocal()) : "",
        "horaDeFin": item['horaDeFin'] != null ? DateFormat('HH:mm').format(DateFormat('HH:mm:ss.SSS').parseUTC(item["horaDeFin"]).toLocal()) : "",
      };
      res.add(aux);
    }
    return res;
  }
  static List<Map<String, dynamic>> armarContenidoPorEtiquetas(String str) {
    List<Map<String, dynamic>> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      for (var item in item["attributes"]["eventos"]["data"]) {
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item['attributes']["titulo"],
          "descripcion": item['attributes']["descripcion"],
          "categoria": Categoria.armarCategoria(item['attributes']["categoria"]["data"]), 
          "tipo": "eventos",
        };
        res.add(aux);
      }
      for (var item in item["attributes"]["concursos"]["data"]) {
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item['attributes']["titulo"],
          "descripcion": item['attributes']["descripcion"],
          "categoria": Categoria.armarCategoria(item['attributes']["categoria"]["data"]), 
          "tipo": "concursos",
        };
        res.add(aux);
      }
      for (var item in item["attributes"]["clubes"]["data"]) {
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item['attributes']["titulo"],
          "descripcion": item['attributes']["descripcion"],
          "categoria": Categoria.armarCategoria(item['attributes']["categoria"]["data"]), 
          "tipo": "clubes",
        };
        res.add(aux);
      }
      for (var item in item["attributes"]["noticias"]["data"]) {
        Map<String, dynamic> aux = {
          "id": item["id"],
          "titulo": item['attributes']["titulo"],
          "descripcion": item['attributes']["descripcion"],
          "categoria": Categoria.armarCategoria(item['attributes']["categoria"]["data"]), 
          "tipo": "noticias",
        };
        res.add(aux);
      }
    }
    return res;
  }
  static List<List<Map<String, dynamic>>> armarListaParaDesplegablesPlanDeEstudios(List<Map<String, dynamic>> data){
    List<List<Map<String, dynamic>>> res = [];
    for (var item in data) {
      List<Map<String, dynamic>> aux = [];
      Map<String, dynamic> aux2 = {
        "headerValue": item["semestre"],
        "expandedValue": item["descripcion"],
        "isExpanded": false
      };
      aux.add(aux2);
      res.add(aux);
    }
    return res;
  }
}