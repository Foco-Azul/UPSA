import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class RetroalimentacionScreen extends StatefulWidget {
  const RetroalimentacionScreen({Key? key, this.id=-1, this.titulo="", this.tipo=""}) : super(key: key);
  final int id;
  final String titulo;
  final String tipo;
  @override
  _RetroalimentacionScreenState createState() => _RetroalimentacionScreenState();
}

class _RetroalimentacionScreenState extends State<RetroalimentacionScreen> {
  int _id = -1;
  String _titulo = "";
  String _tipo = "";
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  bool _isLoggedIn = false;
  User _user = User();
  final Map<String, dynamic> _formData = {
    "relevancia": -1,
    "calidad": -1,
    "organizacion": -1,
    "queTeGustoMas": "",
    "queTeGustoMenos": "",
    "comoPodriamosMejorar": "",
    "comentario": "",
  };
  final Map<String, String> _formDataError = {
    "errorRelevancia": "",
    "errorCalidad": "",
    "errorOrganizacion": "",
    "errorQueTeGustoMas": "",
    "errorQueTeGustoMenos": "",
    "errorComoPodriamosMejorar": "",
    "errorComentario": "",
  };
  Validacion validacion = Validacion();
  bool _bandera = false;
  bool _llenado = false;
  late AnimacionCarga _animacionCarga;

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    _titulo = widget.titulo;
    _tipo = widget.tipo;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _animacionCarga = AnimacionCarga(context: context);
    _cargarDatos();
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Retroalimentaciones_${FuncionUpsa.limpiarYReemplazar(_titulo)}',
      screenClass: 'Retroalimentaciones_${FuncionUpsa.limpiarYReemplazar(_titulo)}', // Clase o tipo de pantalla
    );
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user = await ApiService().getUserPopulateParaRetroalimentacion(_user.id!);
      _verExistenciaFormulario();
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _verExistenciaFormulario(){
    for (var item in _user.retroalimentaciones!) {
      if(_tipo == item["tipo"] && _id == item["id"]){
        _llenado = true;
      }
    }
  }
  void _validarCamposLogin(){
    setState(() {
      _formDataError["errorRelevancia"] = _formData["relevancia"]! == -1 ? "Este campo es requerido" : "";
      _formDataError["errorCalidad"] = _formData["calidad"]! == -1 ? "Este campo es requerido" : "";
      _formDataError["errorOrganizacion"] = _formData["organizacion"]! == -1 ? "Este campo es requerido" : "";
      //_formDataError["errorQueTeGustoMas"] = _formData["queTeGustoMas"]!.isEmpty ? "Este campo es requerido" : "";
      //_formDataError["errorQueTeGustoMenos"] = _formData["queTeGustoMenos"]!.isEmpty ? "Este campo es requerido" : "";
      //_formDataError["errorComoPodriamosMejorar"] = _formData["comoPodriamosMejorar"]!.isEmpty ? "Este campo es requerido" : "";
      //_formDataError["errorComentario"] = _formData["comentario"]!.isEmpty ? "Este campo es requerido" : "";
    });
    if(_formDataError["errorRelevancia"]!.isEmpty && _formDataError["errorCalidad"]!.isEmpty && _formDataError["errorOrganizacion"]!.isEmpty && _formDataError["errorQueTeGustoMas"]!.isEmpty && _formDataError["errorQueTeGustoMenos"]!.isEmpty && _formDataError["errorComoPodriamosMejorar"]!.isEmpty && _formDataError["errorComentario"]!.isEmpty){
      _crearRetroalimentacion();
    }
  }
  void _crearRetroalimentacion() async{
    _animacionCarga.setMostrar(true);
    String respuesta = await ApiService().crearRetroalimentacion(_formData, _user.id!, _id, _tipo);
    if(respuesta == "exito"){
      _bandera = true;
      MensajeTemporalInferior().mostrarMensaje(context,"Solicitud enviado exitosamente.", "exito");
    }else{
      MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
    }
    _animacionCarga.setMostrar(false);
    setState(() {
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
          title: Text(
            "Retroalimentación",
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearTarjetaConFormulario(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 1,
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
  
  Widget _crearTarjetaConFormulario(){
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
            child: Text(
              "Ayudanos a mejorar brindándonos tu opinión sobre tu experiencia en la actividad: $_titulo.",
              style: AppTextStyles.parrafo(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Divider(),
          ),
          _crearFormulario(),
        ],
      ),
    );
  }
  Widget _crearFormulario(){
    if(!_isLoggedIn || _bandera || _llenado){
      return Column(
        children: [
          Visibility(
            visible: _bandera || _llenado,
            child: Text(
              "Gracias por tu retroalimentación",
              style: AppTextStyles.parrafo(),
            ) 
          ),
          Visibility(
            visible: !_isLoggedIn,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ingresa con tu cuenta para enviar tu reseña.",
                    style: AppTextStyles.parrafo(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login2Screen()));
                    },
                    style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                    child: Text(
                      'Ingresar',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                    ),
                  ),
                )
              ],
            )
          ),
          if(_isLoggedIn && _user.estado! != "Completado")
          Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                child: Text(
                  "Completá tu perfil para solicitar un Test vocacional.",
                  style: AppTextStyles.parrafo(),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    if(_user.estado == "Nuevo"){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ValidarEmail()));
                    }
                    if(_user.estado == "Verificado"){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroPerfil()));
                    }
                    if(_user.estado == "Perfil parte 1"){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
                    }
                    if(_user.estado == "Perfil parte 2"){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
                    } 
                  },
                  style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                  child: Text(
                    'Completar perfil',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                  ),
                ),
              )
            ],
          )
        ],
      );
    }else{
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "Calificación".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Relevancia del contenido",
                      style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "1",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 1,
                          visualDensity: VisualDensity.compact,
                          groupValue: int.tryParse(_formData["relevancia"].toString()),
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["relevancia"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "2",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 2,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["relevancia"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["relevancia"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "3",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 3,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["relevancia"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["relevancia"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "4",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 4,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["relevancia"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["relevancia"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "5",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 5,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["relevancia"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["relevancia"] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_formDataError["errorRelevancia"]!.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      width: double.infinity,
                      child: Text(
                        _formDataError["errorRelevancia"]!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Calidad del presentador",
                      style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "1",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 1,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["calidad"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["calidad"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "2",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 2,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["calidad"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["calidad"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "3",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 3,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["calidad"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["calidad"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "4",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 4,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["calidad"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["calidad"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "5",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 5,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["calidad"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["calidad"] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                   if (_formDataError["errorCalidad"]!.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      width: double.infinity,
                      child: Text(
                        _formDataError["errorCalidad"]!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Organización y logística",
                      style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "1",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 1,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["organizacion"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["organizacion"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "2",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 2,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["organizacion"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["organizacion"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "3",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 3,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["organizacion"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["organizacion"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "4",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 4,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["organizacion"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["organizacion"] = value!;
                            });
                          },
                        ),
                      ),
                      Text(
                        "5",
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      Container(
                        margin: MySpacing.right(8),
                        child: Radio(
                          value: 5,
                          visualDensity: VisualDensity.compact,
                          fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                          groupValue: int.tryParse(_formData["organizacion"].toString()),
                          onChanged: (int? value) {
                            setState(() {
                              _formData["organizacion"] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                   if (_formDataError["errorOrganizacion"]!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                        _formDataError["errorOrganizacion"]!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.live_help_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "Preguntas".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      _formData["queTeGustoMas"] = value;
                      setState(() {});
                    },
                    initialValue: _formData["queTeGustoMas"],
                    decoration: AppDecorationStyle.campoContacto(hintText: "¿Qué te gustó más?", labelText: "¿Qué te gustó más?"),
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    maxLines: null,
                    minLines: 3,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),
                  if (_formDataError["errorQueTeGustoMas"]!.isNotEmpty)
                  Text(
                    _formDataError["errorQueTeGustoMas"]!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.start,
                  ),
                ]
              )
            ),  
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      _formData["queTeGustoMenos"] = value;
                      setState(() {});
                    },
                    initialValue: _formData["queTeGustoMenos"],
                    decoration: AppDecorationStyle.campoContacto(hintText: "¿Qué te gustó menos?", labelText: "¿Qué te gustó menos?"),
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    maxLines: null,
                    minLines: 3,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),
                  if (_formDataError["errorQueTeGustoMenos"]!.isNotEmpty)
                  Text(
                    _formDataError["errorQueTeGustoMenos"]!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.start,
                  ),
                ]
              )
            ),  
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      _formData["comoPodriamosMejorar"] = value;
                      setState(() {});
                    },
                    initialValue: _formData["comoPodriamosMejorar"],
                    decoration: AppDecorationStyle.campoContacto(hintText: "¿Cómo podríamos mejorar?", labelText: "¿Cómo podríamos mejorar?"),
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    maxLines: null,
                    minLines: 3,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),
                  if (_formDataError["errorComoPodriamosMejorar"]!.isNotEmpty)
                  Text(
                    _formDataError["errorComoPodriamosMejorar"]!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.start,
                  ),
                ]
              )
            ),  
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      _formData["comentario"] = value;
                      setState(() {});
                    },
                    initialValue: _formData["comentario"],
                    decoration: AppDecorationStyle.campoContacto(hintText: "Abierto para cualquier comentario o sugerencia adicional", labelText: "Abierto para cualquier comentario o sugerencia adicional"),
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                    maxLines: null,
                    minLines: 3,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),
                  if (_formDataError["errorComentario"]!.isNotEmpty)
                  Text(
                    _formDataError["errorComentario"]!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.start,
                  ),
                ]
              )
            ),  
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  _validarCamposLogin();
                },
                style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                child: Text(
                  'Enviar',
                  style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
