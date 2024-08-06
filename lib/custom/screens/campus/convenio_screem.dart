import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/enlace.dart';
import 'package:flutkit/custom/models/convenio.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ConvenioScreen extends StatefulWidget {
  const ConvenioScreen({Key? key}) : super(key: key);
  @override
  _ConvenioScreenState createState() => _ConvenioScreenState();
}

class _ConvenioScreenState extends State<ConvenioScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  Convenio _convenio = Convenio();
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
    _convenio = await ApiService().getConvenioPopulateConEnlacesDePaises();
    _modificarListaPaises();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _modificarListaPaises(){
    List<List<Map<String, dynamic>>> nuevoPaises = [];
    for (var item in _convenio.paises!) {
      List<Map<String, dynamic>> aux = [];
      var aux2 = {
        "headerValue": item["nombre"],
        "expandedValue": item["enlaces"],
        "bandera": item["bandera"],
        "isExpanded": false
      };
      aux.add(aux2);
      nuevoPaises.add(aux);
    }
    _convenio.paises = nuevoPaises;
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
          leading: IconButton(
            icon: Icon(
              LucideIcons.chevronLeft,
              color: AppColorStyles.oscuro1
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: AppColorStyles.verdeFondo,
          centerTitle: true,
          title: Text(
            _convenio.titulo!,
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearTarjeta("INTERNACIONALIZACIÓN", _convenio.internacionalizacion!, "earthAmericas"),
              _crearEnlaces("contactos", _convenio.enlaces!),
              _crearConvenio(),
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
  
  Widget _crearEnlaces(String tipo, List<Enlace> enlaces){
    String titulo = "";
    String icono = "";
    if(tipo == "contactos"){
      titulo = "Solicitar información";
      icono = "contact_support_outlined";
    }
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
                AppIconStyles.icono(nombre: icono), // Reemplaza con el icono que desees
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                titulo.toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
              ),
            ]
          ),
          Column(
            children: List.generate(enlaces.length, (index) {
              return GestureDetector(
                onTap: () async {
                  if(enlaces[index].enlace!.isNotEmpty){
                    if (!await launchUrl(
                      Uri.parse(enlaces[index].enlace!),
                      mode: LaunchMode.externalApplication,
                    )){}
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
                  child: Row(
                    children: [
                      if(enlaces[index].icono != "sin icono")
                      Icon(
                        AppIconStyles.icono(nombre: enlaces[index].icono!), // Reemplaza con el icono que desees
                        color: AppColorStyles.verde1, // Ajusta el color si es necesario
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        enlaces[index].nombre!,
                        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  Widget _crearEnlacesPaises(List<dynamic>? enlaces){
    if(enlaces != null){
      return Container(
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: List.generate(enlaces.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    if(enlaces[index]["enlace"]!.isNotEmpty){
                      if (!await launchUrl(
                        Uri.parse(enlaces[index]["enlace"]!),
                        mode: LaunchMode.externalApplication,
                      )){}
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
                    child: Row(
                      children: [
                        if (enlaces[index]["icono"] != "sin icono")
                          Icon(
                            AppIconStyles.icono(nombre: enlaces[index]["icono"]!), // Reemplaza con el icono que desees
                            color: AppColorStyles.verde1, // Ajusta el color si es necesario
                          ),
                        SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            enlaces[index]["nombre"]!,
                            style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                            textAlign: TextAlign.left, // O TextAlign.justify para justificar el texto
                            overflow: TextOverflow.visible, // O TextOverflow.clip / TextOverflow.ellipsis según tus necesidades
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }else{
      return Container();
    }
  }
  Widget _crearConvenio(){
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Países con convenios", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
          ),
          Text(
            _convenio.paisesConvenio!,
            style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
          ),
          _crearListaDesplegables(),
        ],
      ),
    );
  }
  Widget _crearListaDesplegables() {
    return Column(
      children: List.generate(_convenio.paises!.length, (index) {
        return _crearDesplegable(_convenio.paises![index]);
      }),
    );
  }
  Widget _crearDesplegable(List<Map<String, dynamic>> data) {
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
                title: Text(AppBanderaStyles.bandera(pais: item["bandera"])+item["headerValue"], style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.gris2)),
              );
            },
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              alignment: Alignment.centerLeft,
              child: _crearEnlacesPaises(item["expandedValue"]),
            ),
            isExpanded: item["isExpanded"],
          );
        }).toList(),
      ),
    );
  }
  Widget _crearTarjeta(String titulo, String descripcion, String icono){
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
                AppIconStyles.icono(nombre: icono), // Reemplaza con el icono que desees
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                titulo.toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Text(
                  descripcion,
                  style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}