import 'dart:convert';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:intl/intl.dart';

class FuncionUpsa {
  static List<String> armarGaleriaImagenes(List<dynamic>? datas, dynamic data){
    List<String> res = [];
    if(data != null){
      res.add(getImageUrl(data));
    }
    if(datas != null){
      for (var item in datas) {
        res.add(getImageUrl(item));
      }
    }
    return res;
  }

  static String getImageUrl(dynamic data) {
    String res = "/uploads/default_02263f0f89.png";

    if(data != null){
      if(data['attributes']['formats'] != null){
        final formats = data['attributes']['formats'];

        res = formats?['large']?['url'] ??
          formats?['small']?['url'] ??
          formats?['medium']?['url'] ??
          data['attributes']?['url'] ?? 
          "/uploads/default_02263f0f89.png";

      }else{
        res = data['attributes']['url'];
      }
    }
    return res;
  }

  static String obtenerImagenUrl(String url) {
    List<String> prefixes = ['thumbnail_', 'medium_', 'small_', 'large_'];
    for (String prefix in prefixes) {
      url = url.replaceAll(prefix, '');
    }
    return url;
  }

  static List<Map<String, dynamic>> _armarEntradasParaEscanear(dynamic data){
    List<Map<String, dynamic>> res = [];
    if(data != null){
      for (var item in data) {
        res.add(
          {
            "id": item["id"],
            "qr": item["attributes"]["qr"] ?? "",
            "asistencia": item["attributes"]["asistencia"] ?? false,
            "email": item["attributes"]["user"]["data"] != null ? item["attributes"]["user"]["data"]["attributes"]["email"] : "",
            "nombres": item["attributes"]["user"]["data"] != null ? (item["attributes"]["user"]["data"]["attributes"]["userMeta"]["data"] != null ? item["attributes"]["user"]["data"]["attributes"]["userMeta"]["data"]["attributes"]["nombres"] : "") : "",
            "apellidos": item["attributes"]["user"]["data"] != null ? (item["attributes"]["user"]["data"]["attributes"]["userMeta"]["data"] != null ? item["attributes"]["user"]["data"]["attributes"]["userMeta"]["data"]["attributes"]["apellidos"] : "") : "",
            "cedulaDeIdentidad": item["attributes"]["user"]["data"] != null ? (item["attributes"]["user"]["data"]["attributes"]["userMeta"]["data"] != null ? item["attributes"]["user"]["data"]["attributes"]["userMeta"]["data"]["attributes"]["cedulaDeIdentidad"] : "") : "",
            "entradasEscaneadas": _armarListaDeFechasHoras(item["attributes"]["entradasEscaneadas"]),
          }
        );
      }
    }
    return res;
  } 
  static Map<String, dynamic> armarEntradaParaVerificar(String str){
    Map<String, dynamic> res = {};
    final jsonData = json.decode(str);
    final Map<String, dynamic> data = jsonData['data'];
    res = {
      "id": data["id"],
      "qr": data["attributes"]["qr"] ?? "",
      "asistencia": data["attributes"]["asistencia"] ?? false,
      "entradasEscaneadas": _armarListaDeFechasHoras(data["attributes"]["entradasEscaneadas"]),
    };
    return res;
  } 
  static List<DateTime> _armarListaDeFechasHoras(List<dynamic> data) {
    List<DateTime> res = [];

    for (var item in data) {
      if (item.containsKey('fechaEntradaEscaneada')) {
        DateTime aux = DateTime.parse(item['fechaEntradaEscaneada']);
        // Restar 4 horas
        //DateTime auxRestado = aux.subtract(Duration(hours: 4));
        // Formatear la fecha en el formato deseado
        //String fechaFormateada = DateFormat('dd/MM/yyyy-HH:mm:ss').format(auxRestado);
        res.add(aux);
      }
    }

    // Ordenar de la más reciente a la más antigua
    res.sort((a, b) => b.compareTo(a));
    return res;
  }
  static List<String> armarListaFechasHorasParaStrapi(List<dynamic> data) {
    List<String> res = [];

    for (var item in data) {
      // Convertir DateTime a formato ISO 8601 con 'Z' al final
      String fechaFormateada = item.toUtc().toIso8601String(); // Convierte a UTC y luego a ISO 8601
      res.add(fechaFormateada); // Agregar la fecha formateada a la lista
    }

    return res;
  }

  static List<Map<String,dynamic>> armarActividadesPopulateParaEscanearEntradas(String str, String tipo) {
    List<Map<String,dynamic>> res = [];
    final jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'];
    for (var item in data) {
      Map<String,dynamic> aux = {
        "id": item["id"],
        "titulo": item['attributes']["titulo"],
        "tipo": tipo,
        "fechaDeInicio": item['attributes']["fechaDeInicio"],
        "fechaDeFin": item['attributes']["fechaDeFin"],
        "cantidadEscaneosMaximo": item['attributes']["cantidadEscaneosMaximo"] ?? 1,
        "entradas": _armarEntradasParaEscanear(item['attributes']["inscripciones"]["data"])
      };
      res.add(aux);
    }
    return res;
  }
  static String armarFechaPublicacion(String? data) {
    String res = "";
    if(data != null){
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
        res = "Hace $dias días";
      }
    }else{
      res = "Actividad finalizada";
    }
    return res;
  }
  static String armarFechaDeInicioFinConHora(String data) {
    DateTime dateTime = DateTime.parse(data).toLocal();
    DateFormat dateFormatDate = DateFormat('dd MMMM', 'es_ES');
    DateFormat dateFormatTime = DateFormat('HH:mm', 'es_ES');
    
    String formattedDate = dateFormatDate.format(dateTime);
    String formattedTime = dateFormatTime.format(dateTime);
    
    return '$formattedDate - $formattedTime';
  }
  static String armarFechaDeInicioFin(String data) {
    // Parse the input data to a DateTime object and convert to local time
    DateTime dateTime = DateTime.parse(data).toLocal();
    
    // Create a DateFormat object for the desired format
    DateFormat dateFormatDate = DateFormat('dd MMMM', 'es_ES');
    
    // Format the DateTime object to a string
    String formattedDate = dateFormatDate.format(dateTime);
    
    // Return the formatted date string
    return formattedDate;
  }
  static List<int> armarSeguidores(List<dynamic>? data){
    List<int> res = [];
    if(data !=  null){
      for (var item in data) {
        res.add(item["id"]);
      }
    }
    return res;
  }
  static String _armarFechaLiteral(String? fecha) {
    if(fecha != null){
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
      return '${int.parse(partes[2])} de ${meses[mes]}';
    }else{
      return "";
    }
  }
  static List<Map<String, dynamic>> armarFechaCalendarioConHora(List<dynamic> data) {
    List<Map<String, dynamic>> res = [];
    for (var item in data) {
      Map<String, dynamic> aux = {
        "titulo":item['titulo'],
        "descripcion": item["descripcion"] ?? "",
        "fechaDeInicio": _armarFechaLiteral(item['fechaDeInicio']),
        "horaDeInicio": item['horaDeInicio'] != null ? DateFormat('HH:mm').format(DateFormat('HH:mm:ss.SSS').parseUTC(item["horaDeInicio"]).toLocal()) : "",
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
          "usuariosPermitidos": armarListaDeEnteros(item['attributes']["colegios"]['data']),
        };
        res.add(aux);
      }
    }
    return res;
  }
  static List<int> armarListaDeEnteros(dynamic data){
    List<int> res = [];
    if(data != null){
      for (var item in data) {
        if(item["attributes"]["usersMeta"]["data"] !=  null){
          for (var item2 in item["attributes"]["usersMeta"]["data"]) {
            int aux = item2["attributes"]["user"]["data"] != null ? item2["attributes"]["user"]["data"]["id"] : -1;
            if(aux != -1){
              res.add(aux);
            }
          }
        }
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
  static List<String> armarOpciones(String str){
    List<String> res = [];
    final jsonData = json.decode(str);
    if(jsonData['data'] != null){
      final Map<String, dynamic> data = jsonData['data'];
      for (var item in data["attributes"]["opciones"]) {
        res.add(item["opcion"]);
      }
    }
    return res;
  }
  static Map<String, dynamic> armarOpcionesJson(String str){
    Map<String, dynamic> res = {};
    final jsonData = json.decode(str);
    if(jsonData['data'] != null){
      final Map<String, dynamic> data = jsonData['data'];
      res = data;
    }
    return res;
  }
  static List<int> armarListaEnterosDesdeJsonString(String tipo, String str){
    List<int> res = [];
    if(tipo == "cursillosVistos"){
      final jsonData = json.decode(str);
      if(jsonData["cursillos"] != null){
        for (var item in jsonData["cursillos"]) {
          res.add(item["id"]);
        }
      }
    }
    return res;
  }
  static List<String> armarGaleriaDeImagenes(String tipo, dynamic data){
    List<String> res = [];
    if(tipo == "imagenesColegio"){
      if(data != null){
        for (var item in data) {
          res.add(item["url"]);
        }
      }
    }
    return res;
  }
  static int diferenciaDeFechas(String data, String data2, String caso) {
    int res = 0;
    if (caso == 'fechaActual') {
      DateTime fecha1 = DateTime.parse(data);
      DateTime fechaActual = DateTime.now();
      DateTime fechaActualSinHora = DateTime(fechaActual.year, fechaActual.month, fechaActual.day);
      res = fecha1.difference(fechaActualSinHora).inDays;
    }
    return res;
  }
  static String limpiarYReemplazar(String texto) {
    // Reemplaza espacios con guiones bajos
    String res = texto.replaceAll(' ', '_');
    // Elimina cualquier carácter que no sea letra, número o guion bajo
    res = res.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    return res;
  }
  static String eliminarEspaciosInicioFin(String? data) {
    return data?.trim() ?? "";
  }
}