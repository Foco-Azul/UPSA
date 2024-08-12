import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/matriculate.dart';
import 'package:flutkit/custom/screens/campus/contacto_screem.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';


class MatriculateScreen extends StatefulWidget {
  const MatriculateScreen({Key? key}) : super(key: key);
  @override
  _MatriculateScreenState createState() => _MatriculateScreenState();
}

class _MatriculateScreenState extends State<MatriculateScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  Matriculate _matriculate = Matriculate();
  String _backUrl= "";
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
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _matriculate = await ApiService().getMatriculate();
    _modificarListaMasInformacion();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _modificarListaMasInformacion(){
    List<List<dynamic>> nuevoMasInformacion = [];
    for (var item in _matriculate.masInformacion!) {
      List<dynamic> aux = [];
      var aux2 = {
        "headerValue": item["titulo"],
        "expandedValue": item["descripcion"],
        "isExpanded": false
      };
      aux.add(aux2);
      nuevoMasInformacion.add(aux);
    }
    _matriculate.masInformacion = nuevoMasInformacion;
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
        backgroundColor: AppColorStyles.verdeFondo,
        appBar: AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
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
          title: Text(
            _matriculate.titulo!,
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearLista(),
              _crearComoMatricularse(),
              _crearAyuda(),
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
  Widget _crearListaDesplegables() {
    return Column(
      children: List.generate( _matriculate.masInformacion!.length, (index) {
        return _crearDesplegable( _matriculate.masInformacion![index]);
      }),
    );
  }
  Widget _crearDesplegable(List<dynamic> data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      decoration: AppDecorationStyle.desplegable(),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            data[index]["isExpanded"] = isExpanded;
          });
        },
        children: data.map<ExpansionPanel>((dynamic item) {
          return ExpansionPanel(
            backgroundColor: AppColorStyles.blancoFondo,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item["headerValue"], style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.gris2)),
              );
            },
            body: Container(
              padding: EdgeInsets.all(15.0),
              alignment: Alignment.centerLeft,
              child: Text(
                item["expandedValue"],
                style: AppTextStyles.parrafo(),
              ),
            ),
            isExpanded: item["isExpanded"],
          );
        }).toList(),
      ),
    );
  }
  Widget _crearMasInformacion(){
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Más información", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
          ),
          _crearListaDesplegables(),
        ],
      ),
    );
  }
  Widget _crearAyuda(){
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
                Icons.save_as_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Ayuda".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Text(
                  _matriculate.ayuda!,
                  style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                ),
              ]
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactoScreen()));
              },
              style: AppDecorationStyle.botonContacto(),
              child: Text(
                'Contacto',
                style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _crearComoMatricularse(){
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
                Icons.save_as_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "¿Cómo inscribirte?".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Text(
                  _matriculate.comoMatricularse!,
                  style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                ),
              ]
            ),
          ),
           Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    if(_matriculate.instructivo!.isNotEmpty){
                      await launchUrl(Uri.parse(_backUrl+_matriculate.instructivo!),mode: LaunchMode.externalApplication,);
                    }
                  },
                  style: AppDecorationStyle.botonContacto(),
                  child: Text(
                    'Instructivo',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
                  ),
                ),
              ),
              /*
              SizedBox(width: 8.0),
              Container(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    if(_matriculate.enlaceFormulario!.isNotEmpty){
                      await launchUrl(Uri.parse(_matriculate.enlaceFormulario!),mode: LaunchMode.externalApplication);
                    }
                  },
                  style: AppDecorationStyle.botonContacto(),
                  child: Text(
                    'Llenar formulario',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
                  ),
                ),
              )
              */
            ]
          )
        ],
      ),
    );
  }
  Widget _crearLista(){
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
                Icons.rocket_launch_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Llegá lejos".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
              ),
            ]
          ),
          Column(
            children: List.generate(_matriculate.beneficios!.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
                child: Row(
                  children: [
                    Icon(
                      Icons.check, // Reemplaza con el icono que desees
                      color: AppColorStyles.verde1, // Ajusta el color si es necesario
                    ),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        _matriculate.beneficios![index]["descripcion"],
                        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                        softWrap: true, // Permite el salto de línea automático
                      ),
                    )
                  ]
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}