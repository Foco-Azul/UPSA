import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/cursillo.dart';
import 'package:flutkit/custom/screens/campus/cursillo_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';


class CursillosInicio extends StatefulWidget {
  const CursillosInicio({Key? key}) : super(key: key);
  @override
  _CursillosInicioState createState() => _CursillosInicioState();
}

class _CursillosInicioState extends State<CursillosInicio> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  List<Cursillo> _cursillos = [];
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
    _cursillos = await ApiService().getCursillosPopulate();
    _armarCategorias();
    
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _armarCategorias(){
    for (var item in _cursillos) {
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
          child: LoadingEffect.getSearchLoadingScreen(
            context,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColorStyles.altFondo1,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: AppColorStyles.altFondo1,
          centerTitle: true,
          title: MyText(
            "Cursillos",
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearParrafo(),
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
  Widget _crearParrafo() {
    return Container(
      padding: EdgeInsets.all(15.0), // Ajusta el valor de acuerdo a tus necesidades
      child: Text(
        'Estos cursos refuerzan conceptos clave y llenan vacíos de conocimiento, permitiendo una comprensión más profunda y sólida de las materias.',
        style: AppTextStyles.parrafo(),
      ),
    );
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
          _crearCursillos(categoria),
        ],
      ),
    );
  }
  Widget _crearCursillos(Categoria categoria) {
    List<Cursillo> cursillos = [];
    for (var item in _cursillos) {
      if(item.categoria!.nombre == categoria.nombre){
        cursillos.add(item);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(cursillos.length, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CursilloScreen(id: cursillos[index].id!)));
              },
              child:
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0), // Ajusta el margen aquí
                child: Row(
                  children: [
                    Icon(LucideIcons.dot, color: AppColorStyles.oscuro2),
                    Flexible(
                      child: Text(
                        cursillos[index].titulo!,
                        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                        softWrap: true,
                        overflow: TextOverflow.visible, // Puedes ajustar esto a TextOverflow.ellipsis si prefieres truncar el texto
                      ),
                    ),
                  ],
                ),
              )
            );
          }),
        ),
      ],
    );
  }
}
