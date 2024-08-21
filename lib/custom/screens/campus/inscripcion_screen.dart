import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
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


class TestVocacionalScreen extends StatefulWidget {
  const TestVocacionalScreen({Key? key}) : super(key: key);
  @override
  _TestVocacionalScreenState createState() => _TestVocacionalScreenState();
}

class _TestVocacionalScreenState extends State<TestVocacionalScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  bool _isLoggedIn = false;
  User _user = User();
  final Map<String, dynamic> _formData = {
    "fechas": "",
    "telefono": "",
    "carreras": ""
  };
  final Map<String, String> _formDataError = {
    "errorFechas": "",
    "errorTelefono": "",
    "errorCarreras": ""
  };
  Validacion validacion = Validacion();
  bool _bandera = false;
  bool _permitido = false;
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
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user = await ApiService().getUserPopulateParaSolitudDeTestVocacional(_user.id!);
      if(_user.solicitudesDeTestVocacional!.length < 2){
        _permitido = true;
      }
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCamposLogin(){
    setState(() {
      _formDataError["errorFechas"] = _formData["fechas"]!.isEmpty ? "Este campo es requerido" : "";
      _formDataError["errorTelefono"] = validacion.validarCelular(_formData["telefono"], true);
      _formDataError["errorCarreras"] = _formData["carreras"]!.isEmpty ? "Este campo es requerido" : "";
    });
    if(_formDataError["errorFechas"]!.isEmpty && _formDataError["errorTelefono"]!.isEmpty && _formDataError["errorCarreras"]!.isEmpty){
      _crearSolicitudDeTestVocacional();
    }
  }
  void _crearSolicitudDeTestVocacional() async{
    String respuesta = await ApiService().crearSolicitudDeTestVocacional(_formData, _user.id!);
    if(respuesta == "exito"){
      _bandera = true;
      MensajeTemporalInferior().mostrarMensaje(context,"Solicitud enviado exitosamente.", "exito");
    }else{
      MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
    }
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
            "Solicitud de inscripción",
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
  Widget _crearTarjetaConFormulario(){
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
                Icons.assignment_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "test de orientación vocacional".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Text(
                  "Te ayudamos a identificar tus intereses, habilidades, y preferencias con el fin de guiarte en la elección de una carrera que se alinee con tus aspiraciones.",
                  style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                ),
              ]
            ),
          ),
          _crearFormulario(),
        ],
      ),
    );
  }
  Widget _crearFormulario(){
    if(!_isLoggedIn || (_isLoggedIn && _user.estado! != "Completado") || !_permitido || _bandera){
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_search_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "Solicitar test".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Visibility(
              visible: _bandera,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                child: Text(
                  "Gracias por contactarte con la UPSA.",
                  style: AppTextStyles.parrafo(),
                ),
              ),
            ),
            Visibility(
              visible: !_permitido,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                child: Text(
                  "LLegaste a la cantidad maxima de solicitudes del Test vocacional.",
                  style: AppTextStyles.parrafo(),
                ),
              ),
            ),
            Visibility(
              visible: !_isLoggedIn,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                    child: Text(
                      "Ingresá con tu cuenta para solicitar un Test vocacional.",
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
                      style: AppDecorationStyle.botonContacto(),
                      child: Text(
                        'Ingresar',
                        style: AppTextStyles.botonMenor(color: AppColorStyles.blanco), // Estilo del texto del botón
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
                    style: AppDecorationStyle.botonContacto(),
                    child: Text(
                      'Completar perfil',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blanco), // Estilo del texto del botón
                    ),
                  ),
                )
              ],
            )
          ]
        )
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
                  Icons.person_search_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "Solicitar test".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                "Solicitá tu test llenando el siguiente formulario.",
                style: AppTextStyles.parrafo(),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        width: 70,
                        decoration: AppDecorationStyle.campoContainerForm(),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: "+591",
                          onChanged: (value) {
                          },
                          decoration: AppDecorationStyle.campoContacto(hintText: "hintText", labelText: ""),  
                          style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                        ),
                      ),
                      SizedBox(width: 10), // Para agregar un espacio entre los campos
                      Expanded(
                        child: Container(
                          decoration: AppDecorationStyle.campoContainerForm(),
                          child: TextFormField(
                            onChanged: (value) {
                              _formData["telefono"] = value;
                              setState(() {});
                            },
                            decoration: AppDecorationStyle.campoContacto(hintText: "Teléfono de contacto", labelText: "Teléfono de contacto"),  
                            style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_formDataError["errorTelefono"]!.isNotEmpty)
                  Text(
                    _formDataError["errorTelefono"]!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        onChanged: (value) {
                          _formData["fechas"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["fechas"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "Fechas y horarios tentativas para el test", labelText: "Fechas y horarios tentativas para el test"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                        maxLines: null,
                        minLines: 3,
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      ),
                      if (_formDataError["errorFechas"]!.isNotEmpty)
                      Text(
                        _formDataError["errorFechas"]!,
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
                          _formData["carreras"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["carreras"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "Carreras de interés", labelText: "Carreras de interés"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                        maxLines: null,
                        minLines: 3,
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      ),
                      if (_formDataError["errorCarreras"]!.isNotEmpty)
                      Text(
                        _formDataError["errorCarreras"]!,
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
                    style: AppDecorationStyle.botonContacto(),
                    child: Text(
                      'Enviar',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blanco), // Estilo del texto del botón
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }
}
