// ignore_for_file: avoid_print

import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ActividadesPasadasScreen extends StatefulWidget {
  const ActividadesPasadasScreen({Key? key}) : super(key: key);

  @override
  _ActividadesPasadasScreenState createState() => _ActividadesPasadasScreenState();
}

class _ActividadesPasadasScreenState extends State<ActividadesPasadasScreen> {
  late ThemeData theme;
  late ProfileController controller;
  bool _isLoggedIn = false;
  User _user = User();
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
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      if(_user.rolCustom! != "admin"){
        _user = await ApiService().getUserPopulateConActividadesPasadas(_user.id!);
      }
    }
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
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            "Todas mis actividades",
            style: AppTitleStyles.principal()
          ),
        ),
        body: ListView(
          children: [
            _misActividades(),
          ],
        )
      );
    }
  }
  Widget _misActividades() {
    if(_user.rolCustom != "admin" && (_user.actividadesSeguidas!.isNotEmpty || _user.actividadesInscritas!.isNotEmpty)){
      return Container(
        padding: MySpacing.fromLTRB(15, 15, 15, 15),
        margin: MySpacing.all(15),
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.trophy, // Cambia el icono según lo que necesites
                  size: 20,
                  color: AppColorStyles.verde1,
                ),
                SizedBox(width: 8),
                Text(
                  "MIS ACTIVIDADES",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
                ),
              ],
            ),
            _actividadesInscritas(),
          ],
        ),
      );  
    }else{
      return Container();
    }
  }
  /*
  Widget _actividadesSeguidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _user.actividadesSeguidas!.map((actividad) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                actividad["titulo"],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyles.oscuro1
                ),
              ),
              Text(
                "Siguiendo",
                style: AppTextStyles.parrafo(color: AppColorStyles.oscuro1),
              ),
              InkWell(
                onTap: () {
                  if(actividad["tipo"] == "evento"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: actividad["id"])));
                  }
                  if(actividad["tipo"] == "concurso"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: actividad["id"])));
                  }
                  if(actividad["tipo"] == "club"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: actividad["id"])));
                  }
                },
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.calendar, // Cambia el ícono según lo que necesites
                      size: 20,
                      color: AppColorStyles.gris2
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Ver actividad",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColorStyles.gris2
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          )
        );
      }).toList(),
    );
  }
  */
  Widget _actividadesInscritas() {
    int count = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _user.actividadesInscritas!.map((actividad) {
        count++;
        return Container(
          //padding: EdgeInsets.symmetric(vertical: 10),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  actividad["titulo"],
                  style: AppTitleStyles.tarjetaMenor()
                ),
              ), 
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if(actividad["tipo"] == "evento"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: actividad["id"])));
                      }
                      if(actividad["tipo"] == "concurso"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: actividad["id"])));
                      }
                      if(actividad["tipo"] == "club"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: actividad["id"])));
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.calendar, // Cambia el ícono según lo que necesites
                          size: 20,
                          color: AppColorStyles.gris2
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Ver actividad",
                          style: AppTextStyles.botonSinFondo(color: AppColorStyles.gris2)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: count < _user.actividadesInscritas!.length,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Divider(),
                )
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
