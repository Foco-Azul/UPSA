import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/contacto.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
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
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactoScreen extends StatefulWidget {
  const ContactoScreen({Key? key}) : super(key: key);
  @override
  _ContactoScreenState createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  Contacto _contacto = Contacto();
  bool _isLoggedIn = false;
  User _user = User();
  final Map<String, dynamic> _formData = {
    "email": "",
    "asunto": "",
    "mensaje": ""
  };
  final Map<String, String> _formDataError = {
    "errorEmail": "",
    "errorAsunto": "",
    "errorMensaje": ""
  };
  Validacion validacion = Validacion();
  bool _bandera = false;
  late AnimacionCarga _animacionCarga;

  @override
  void initState() {
    super.initState();
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
      screenName: 'Contacto',
      screenClass: 'Contacto', // Clase o tipo de pantalla
    );
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _formData["email"] = _user.email!;
    }
    _contacto = await ApiService().getContacto();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCamposLogin(){
    setState(() {
      _formDataError["errorEmail"] = validacion.validarCorreo(_formData["email"], true);
      _formDataError["errorAsunto"] = _formData["asunto"]!.isEmpty ? "Este campo es requerido" : "";
      _formDataError["errorMensaje"] = _formData["mensaje"]!.isEmpty ? "Este campo es requerido" : "";
    });
    if(_formDataError["errorEmail"]!.isEmpty && _formDataError["errorAsunto"]!.isEmpty && _formDataError["errorMensaje"]!.isEmpty){
      _crearRegistroContacto();
    }
  }
  void _crearRegistroContacto() async{
    _animacionCarga.setMostrar(true);
    String respuesta = await ApiService().crearContacto(_formData);
    if(respuesta == "exito"){
      _bandera = true;
      MensajeTemporalInferior().mostrarMensaje(context,"Mensaje enviado exitosamente.", "exito");
    }else{
      MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
    }
    setState(() {
    });
    _animacionCarga.setMostrar(false);
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
          title: MyText(
            _contacto.titulo!,
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearParrafo(),
              _crearEnlaces("enlaces"),
              _crearEnlaces("redesSociales"),
              _crearFormulario(),
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
  Widget _crearFormulario(){
    if(_bandera){
      return Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.all(15.0),
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 15.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                "Formulario de contacto".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                "Gracias por contactarte con la UPSA",
                style: AppTextStyles.parrafo(),
              ),
            ),
          ]
        )
      );
    }else{
      return Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.all(15.0),
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 15.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                "Formulario de contacto".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ),
            if(_contacto.descripcionFormularioContacto!.isNotEmpty && _contacto.descripcionFormularioContacto! != " ")
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                _contacto.descripcionFormularioContacto!,
                style: AppTextStyles.parrafo(),
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
                          _formData["email"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["email"],
                        readOnly: _isLoggedIn,
                        decoration: AppDecorationStyle.campoContacto(hintText: "Email", labelText: "Email"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
                      ),
                      if (_formDataError["errorEmail"]!.isNotEmpty)
                      Text(
                        _formDataError["errorEmail"]!,
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
                          _formData["asunto"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["asunto"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "Asunto", labelText: "Asunto"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
                      ),
                      if (_formDataError["errorAsunto"]!.isNotEmpty)
                      Text(
                        _formDataError["errorAsunto"]!,
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
                          _formData["mensaje"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["mensaje"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "¿Cómo te podemos ayudar?", labelText: "¿Cómo te podemos ayudar?"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                        maxLines: null,
                        minLines: 3,
                        maxLength: 300,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      ),
                      if (_formDataError["errorMensaje"]!.isNotEmpty)
                      Text(
                        _formDataError["errorMensaje"]!,
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
          ],
        ),
      );
    }
  }
  Widget _crearEnlaces(String tipo){
    List<Map<String, dynamic>> aux = [];
    String titulo = "";
    if(tipo == "enlaces"){
      titulo = "Enlaces";
      aux = _contacto.enlacesContacto!;
    }
    if(tipo == "redesSociales"){
      titulo = "Seguinos";
      aux = _contacto.redesSociales!;
    }
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(), // Primer texto
            style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
          ),
          //SizedBox(height: 10),
          Column(
            children: List.generate(aux.length, (index) {
              return GestureDetector(
                onTap: () async {
                  if (!await launchUrl(
                    Uri.parse(aux[index]["enlace"]),
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception('Could not launch ${aux[index]["enlace"]}');
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
                  child: Row(
                    children: [
                      Icon(
                        AppIconStyles.icono(nombre: aux[index]["icono"]), // Reemplaza con el icono que desees
                        color: AppColorStyles.oscuro2, // Ajusta el color si es necesario
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        aux[index]["nombre"],
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
  Widget _crearParrafo() {
    return Container(
      padding: EdgeInsets.all(15.0), // Ajusta el valor de acuerdo a tus necesidades
      child: Text(
        'Envianos un mensaje, estamos aquí para ayudarte en tu próxima vida universitaria.',
        style: AppTextStyles.parrafo(),
      ),
    );
  }
}
