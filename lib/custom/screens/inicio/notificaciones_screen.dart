// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/notificacion.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/actividades/quiz_screen.dart';
import 'package:flutkit/custom/screens/campus/cursillo_screen.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late ThemeData theme;
  late ProfileController controller;
  final List<Notificacion> _notificaciones = [];
  late SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    controller = ProfileController();
    cargarDatos();
  }

  void cargarDatos() async{
    setState(() {
      controller.uiLoading = true;
    });
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Notificaciones',
      screenClass: 'Notificaciones', // Clase o tipo de pantalla
    );
    _prefs = await SharedPreferences.getInstance();
    //await _prefs.setStringList('notificaciones', []);
    List<String> notificacionesCadenas = _prefs.getStringList('notificaciones') ?? [];
    _armarListaNotificaciones(notificacionesCadenas);
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _armarListaNotificaciones(List<String> data){
    for (var item in data) {
      Map<String, dynamic> aux = json.decode(item);
      Notificacion notificacion = Notificacion(
        tipoNotificacion: aux["tipoNotificacion"],
        tipoContenido: aux["tipoContenido"],
        titulo: aux["titulo"],
        descripcion: aux["descripcion"],
        id: aux["id"],
        estadoNotificacion: aux["estadoNotificacion"],
      );
      _notificaciones.add(notificacion);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getCouponLoadingScreen(
            context,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColorStyles.altFondo1,
        appBar: AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            "Notificaciones",
            style: AppTitleStyles.principal()
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_sweep, size: 30),
              onPressed: () async{
                await _prefs.setStringList('notificaciones', []);
                _notificaciones.clear();
                MensajeTemporalInferior().mostrarMensaje(context,"Se eliminarón las notificaciones con éxito.", "exito");
                setState(() {});
              },
            ),
          ]
        ),
        body: ListView(
          children: [
            _crearListaTarjetas(), 
          ],
        )
      );
    }
  }
  Widget _crearListaTarjetas() {
    List<Widget> tarjetas = _notificaciones.map((item) => _crearTarjeta(item)).toList();
    if(tarjetas.isNotEmpty){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
        children: tarjetas,
      );
    }else{
      return Container(
        decoration: AppDecorationStyle.tarjeta(),
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        alignment: Alignment.center,
        child: Text(
          "No tienes notificaciones",
          style: AppTextStyles.menor(color: AppColorStyles.gris1),
        ),
      );
    }
  }
  Widget _navegacion(String tipo) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alinea los elementos del Row al centro
        children: [
          MyText(
            tipo.toUpperCase(),
            style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
          ),
        ],
      ),
    );
  }
  Widget _crearTarjeta(Notificacion item) {
    return GestureDetector(
      onTap: () {
        if(item.tipoNotificacion == "actividad"){
          if(item.tipoContenido == "evento"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: item.id!,)));
          }
          if(item.tipoContenido == "concurso"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: item.id!,)));
          }        
          if(item.tipoContenido == "club"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: item.id!,)));
          } 
          if(item.tipoContenido == "quiz"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(id: item.id!)));
          }       
        }else{
          if(item.tipoNotificacion == "contenidoApp"){
            if(item.tipoContenido == "noticia"){
              Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: item.id!,)));
            }
            if(item.tipoContenido == "cursillo"){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CursilloScreen(id: item.id!,)));
            }

          }else{
            if(item.tipoNotificacion == "personalizado"){
              if(item.tipoContenido == "nueva insignia"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)));
              }
              if(item.tipoContenido == "formulario de preferencias"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
              }
            }
          }
        }
      },
      child: Container(
        margin: EdgeInsets.all(15), // Añadir margen superior si es necesario
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColorStyles.blanco, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          children: [
            _navegacion(item.tipoContenido!),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item.titulo!,
                style: AppTitleStyles.tarjeta()
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item.descripcion!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.parrafo(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
