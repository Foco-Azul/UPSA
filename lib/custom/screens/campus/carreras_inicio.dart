import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/carrera_upsa.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/screens/campus/carrera_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';


class CarrerasInicio extends StatefulWidget {
  const CarrerasInicio({Key? key}) : super(key: key);
  @override
  _CarrerasInicioState createState() => _CarrerasInicioState();
}

class _CarrerasInicioState extends State<CarrerasInicio> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  List<CarreraUpsa> _carrerasUpsa = [];
  final List<Categoria> _categorias = [];
  
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
  }
  
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Carreras',
      screenClass: 'Carreras', // Clase o tipo de pantalla
    );
    _carrerasUpsa = await ApiService().getCarrerasUpsaPopulate();
    _armarCategorias();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _armarCategorias(){
    for (var item in _carrerasUpsa) {
      bool existe = false;
      for (var item2 in _categorias) {
        if(item2.nombre == item.categoria!.nombre){
          existe = true;
          break;
        }
      }
      if(!existe){
        _categorias.add(item.categoria!);
      }
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
            icon: Icon(
              LucideIcons.chevronLeft,
              color: AppColorStyles.oscuro1
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: MyText(
            "Carreras",
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearContenido()
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 2,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.account_circle_sharp),
              title: Text(
                'Mi perfil',
                style: AppTextStyles.bottomMenu()
              ),
            ),
          ],
          onItemSelected: (index) {
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: index,)),(Route<dynamic> route) => false);
          },
        ),
      );
    }
  } 
  Widget _crearContenido() {
    List<Widget> tarjetas = _categorias.map((item) => _crearCategoria(item)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
      children: tarjetas,
    );
  }
  Widget _crearCategoria(Categoria categoria){
     return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIconStyles.icono(nombre: categoria.icono!), // Reemplaza con el icono que desees
                color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
              ),
              SizedBox(width: 10.0), // Espaciado entre el icono y el texto
              Flexible(
                child: Text(
                  categoria.nombre!.toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _crearCarreras(categoria),
        ],
      ),
    );
  }
  Widget _crearCarreras(Categoria categoria) {
    List<CarreraUpsa> carreras = [];
    for (var item in _carrerasUpsa) {
      if(item.categoria!.nombre == categoria.nombre){
        carreras.add(item);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(carreras.length, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CarreraScreen(id: carreras[index].id!,)));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0), // Ajusta el margen aquí
                child: Row(
                  children: [
                    Icon(LucideIcons.dot, color: AppColorStyles.oscuro2),
                    Flexible(
                      child: Text(
                        carreras[index].nombre!,
                        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                        softWrap: true,
                        overflow: TextOverflow.visible, // Puedes ajustar a TextOverflow.ellipsis si prefieres truncar el texto
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
