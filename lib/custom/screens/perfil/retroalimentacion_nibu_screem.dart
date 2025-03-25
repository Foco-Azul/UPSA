import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class RetroalimentacionNibuScreen extends StatefulWidget {
  const RetroalimentacionNibuScreen({Key? key}) : super(key: key);
  @override
  _RetroalimentacionNibuScreenState createState() => _RetroalimentacionNibuScreenState();
}

class _RetroalimentacionNibuScreenState extends State<RetroalimentacionNibuScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  bool _isLoggedIn = false;
  User _user = User();
  final Map<String, dynamic> _formData = {
    "email": "",
    "mensaje": "",
    "imagenes": []
  };
  final Map<String, String> _formDataError = {
    "errorEmail": "",
    "errorMensaje": ""
  };
  Validacion validacion = Validacion();
  bool _bandera = false;
  late AnimacionCarga _animacionCarga;
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

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
      screenName: 'Retroalimentación_de_NIBU',
      screenClass: 'Retroalimentación_de_NIBU', // Clase o tipo de pantalla
    );
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _formData["email"] = _user.email!;
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCamposLogin(){
    setState(() {
      _formDataError["errorEmail"] = validacion.validarCorreo(_formData["email"], true);
      _formDataError["errorMensaje"] = _formData["mensaje"]!.isEmpty ? "Este campo es requerido" : "";
    });
    if(_formDataError["errorEmail"]!.isEmpty && _formDataError["errorMensaje"]!.isEmpty){
      _crearRegistroContacto();
    }
  }
  void _crearRegistroContacto() async{
    _animacionCarga.setMostrar(true);
    String respuesta = await ApiService().crearRetroalimentacionNibu(_formData);
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
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) return; // Evita seleccionar más de 3 imágenes

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      int fileSize = await imageFile.length(); // Tamaño en bytes

      // Definir el tamaño máximo permitido (5 MB o 10 MB en bytes)
      const int maxSize = 5 * 1024 * 1024; // 5 MB
      // const int maxSize = 10 * 1024 * 1024; // 10 MB

      if (fileSize > maxSize) {
        MensajeTemporalInferior().mostrarMensaje(context,"La imagen no debe superar los 5 MB.", "error");
        return;
      }

      setState(() {
        _selectedImages.add(imageFile);
        _formData["imagenes"] = _selectedImages.map((img) => img).toList();
      });
    }
  }


  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _formData["imagenes"] = _selectedImages.map((img) => img).toList();
    });
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
            "Retroalimentación de NIBU",
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearParrafo(),
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
                "formulario de retroalimentación nibu".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                "Gracias por tu retroalimentación de NIBU",
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
                "formulario de retroalimentación nibu".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
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
                          _formData["mensaje"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["mensaje"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "Tu mensaje", labelText: "Tu mensaje"),
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
                  margin: EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorStyles.altFondo2,
                              foregroundColor: AppColorStyles.oscuro1
                            ),
                            icon: Icon(Icons.attach_file, size: 20), // Ícono de adjuntar
                            label: Text(
                              "Adjuntar (opcional) (${_selectedImages.length}/3)",
                              style: AppTextStyles.menor(),
                            ),
                          ),
                          SizedBox(width: 10), // Espaciado entre el botón y el texto
                          Expanded(
                            child: Text(
                              "Adjuntar capturas que acompañen tu mensaje",
                              style: AppTextStyles.menor(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: _selectedImages.asMap().entries.map((entry) {
                          int index = entry.key;
                          File image = entry.value;
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(image, height: 100, width: 100, fit: BoxFit.cover),
                              GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColorsMensaje.errorTexto,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
  Widget _crearParrafo() {
    return Container(
      padding: EdgeInsets.all(15.0), // Ajusta el valor de acuerdo a tus necesidades
      child: Text(
        'Envianos tus comentarios sobre NIBU. Dejanos saber si encontras errores o nos queres comunicar mejoras que podríamos implementar en la app.',
        style: AppTextStyles.parrafo(),
      ),
    );
  }
}
