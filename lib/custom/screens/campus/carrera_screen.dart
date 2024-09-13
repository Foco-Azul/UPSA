import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/carrera_upsa.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/foto_full_screen.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Carreras_${FuncionUpsa.limpiarYReemplazar(_carreraUpsa.nombre!)}',
      screenClass: 'Carreras_${FuncionUpsa.limpiarYReemplazar(_carreraUpsa.nombre!)}', // Clase o tipo de pantalla
    );
    setState(() {
      controller.uiLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getDatingHomeScreen(
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
  Widget _crearLista(){
    return Visibility(
      visible: _carreraUpsa.masInformacion!.isNotEmpty,
      child: Container(
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
                          _carreraUpsa.masInformacion![index]["descripcion"],
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
      )
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
                      color: AppColorStyles.blanco,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Descargar PDF',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blanco),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "Más información", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1),
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
                    Uri.parse(_carreraUpsa.enlaceExterno!),
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception('Could not launch ${_carreraUpsa.enlaceExterno!}');
                  }
              },
              style: AppDecorationStyle.botonContacto(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_outlined,
                    color: AppColorStyles.blanco,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Ir a la pagina web',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blanco),
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
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(15),
          width: double.infinity, // Asegura que el contenedor ocupe todo el ancho disponible
          decoration: AppDecorationStyle.tarjeta(),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image.network(
              _backUrl+_carreraUpsa.imagen!,
              height: 240.0,
              width: double.infinity, // Asegura que la imagen ocupe todo el ancho disponible
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 16, // Ajusta la posición del ícono según tu preferencia
          right: 16,
          child: GestureDetector(
            onTap: () {
              // Acción al pulsar el ícono
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imageUrl: _backUrl+_carreraUpsa.imagen!,),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColorStyles.altTexto1, // Color de fondo del contenedor
                borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
              ),
              child: Icon(
                Icons.fullscreen_outlined, // Cambia al ícono que prefieras
                color: AppColorStyles.blanco, // Color del ícono
                size: 24.0, // Tamaño del ícono
              ),
            )
          ),
        ),
      ],
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