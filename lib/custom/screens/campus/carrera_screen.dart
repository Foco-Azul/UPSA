import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/carrera_upsa.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class CarreraScreen extends StatefulWidget {
  const CarreraScreen({Key? key,this.id=-1}) : super(key: key);
  final int id;
  @override
  _CarreraScreenState createState() => _CarreraScreenState();
}

class _CarreraScreenState extends State<CarreraScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  int _id = -1;
  CarreraUpsa _carreraUpsa = CarreraUpsa();
  String _backUrl = "";

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _id = widget.id;
    _cargarDatos();
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _carreraUpsa = await ApiService().getCarreraUpsa(_id);
    setState(() {
      controller.uiLoading = false;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading || _id == -1) {
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
        backgroundColor: AppColorStyles.verdeFondo,
        appBar: AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          centerTitle: true,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: RichText(
                text: TextSpan(
                  text:  _carreraUpsa.nombre!,
                  style: AppTitleStyles.principal(),
                ),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _facultadNombre(),
              _bannerCarrera(),
              _descripcionCarrera(),
              _crearLista(),
              _crearMasInformacion(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blancoFondo,
          selectedIndex: 2,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
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
  Widget _crearLista(){
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: List.generate(_carreraUpsa.masInformacion!.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _carreraUpsa.masInformacion![index]["titulo"],
                        style: TextStyle(
                          color: AppColorStyles.oscuro1,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // Permite el salto de línea automático
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        _carreraUpsa.masInformacion![index]["titulo"],
                        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                        softWrap: true, // Permite el salto de línea automático
                      ),
                    ),
                  ], 
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  Widget _crearMasInformacion(){
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: _carreraUpsa.pdf!.isNotEmpty,
            child: Container(
              margin: EdgeInsets.only(bottom: 30),
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  if(_carreraUpsa.pdf!.isNotEmpty){
                    await launchUrl(Uri.parse(_backUrl+_carreraUpsa.pdf!),mode: LaunchMode.externalApplication,);
                  }
                },
                style: AppDecorationStyle.botonContacto(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: AppColorStyles.blancoFondo,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Descargar PDF',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "Más información", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
          ),
          SizedBox(height: 15,),
          Text(
            "Visita nuestra página web para obtener mayor información sobre esta carrera.",
            style: AppTextStyles.parrafo(),
          ),
          SizedBox(height: 15,),
          Container(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () async {
                if (!await launchUrl(
                    Uri.parse("https://upsa.edu.bo/"),
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception('Could not launch ${"https://upsa.edu.bo/"}');
                  }
              },
              style: AppDecorationStyle.botonContacto(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_outlined,
                    color: AppColorStyles.blancoFondo,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Ir a la pagina web',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _descripcionCarrera() {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: AppDecorationStyle.tarjeta(),
      child: Text(
        _carreraUpsa.descripcion!,
        style: AppTextStyles.parrafo(),
      ),
    );
  }
  Widget _bannerCarrera() {
    return Container(
      margin: EdgeInsets.all(15), // Margen de 8.0 en todos los lados
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0), // Radio del borde
        child: Image.network(
          _backUrl+_carreraUpsa.imagen!,
          height: 240.0,
          fit: BoxFit.cover, // Ajuste de la imagen
        ),
      ),
    );
  }
  Widget _facultadNombre() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        _carreraUpsa.categoria!.nombre!,
        style: AppTextStyles.botonMenor(color: AppColorStyles.gris2),
        textAlign: TextAlign.center,
      ),
    );
  }
}