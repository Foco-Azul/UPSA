import 'dart:async';
import 'dart:ui';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/generadores.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Register2Screen extends StatefulWidget {
  @override
  _Register2ScreenState createState() => _Register2ScreenState();
}

class _Register2ScreenState extends State<Register2Screen> {
  bool _passwordVisible = true;
  late CustomTheme customTheme;
  late ThemeData theme;
  Validacion validacion = Validacion();
  Generador generador = Generador();
  final Map<String,String> _data = {
    "username": "",
    "password": "",
    "email": "",
    "nombres": "",
    "apellidos": "",
    "token": "",
    "tokenDispositivo": "",
  };
  final Map<String,String> _error = {
    "error": "",
    "password": "",
    "email": "",
    "nombres": "",
    "apellidos": "",
  };
  late SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    _cargarDatos();
  }
  void _cargarDatos() async{
    Timer(Duration(seconds: 1), () {
      Provider.of<AppNotifier>(context, listen: false).iniciar();
    });
    _prefs = await SharedPreferences.getInstance();
  }
  void _validarCamposRegister(){
    setState(() {
      _error["email"] = validacion.validarCorreo(_data["email"], true);
      _error["password"] = validacion.validarContrasenia(_data["password"], true);
      _error["nombres"] = validacion.validarNombres(_data["nombres"], true);
      _error["apellidos"] = validacion.validarNombres(_data["apellidos"], true);
    });
    if(_error["email"]!.isEmpty && _error["password"]!.isEmpty && _error["nombres"]!.isEmpty && _error["apellidos"]!.isEmpty){
      _signup();
    }
  }
  void _signup() async {
    try {
      showPopup(context);
      _data["username"] = _data["email"]!;
      _data["codigoDeVerificacion"] = generador.generarCodigoDeVerificacion();
      _data["tokenDispositivo"] = _prefs.getString('tokenDispositivo') ?? "";
      User? createduser = await ApiService().addUser(_data);
      if (createduser != null) {
        // navigate to the dashboard.
        Provider.of<AppNotifier>(context, listen: false).login();
        Provider.of<AppNotifier>(context, listen: false).setUser(createduser);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4)),(Route<dynamic> route) => false);
        Navigator.push(context,MaterialPageRoute(builder: (context) => ValidarEmail()));
      }else{
        _error["error"] = "Ya existe una cuenta con el mismo correo electronico.";
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      setState(() {
        if(e.toString().substring(11) == "Exception: Email already taken"){
          _error["error"] = "Ya existe una cuenta con el mismo correo electronico.";
        }else{
          _error["error"] = "Algo salio mal";
        }
      });
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
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
      ),
      body: SingleChildScrollView(
        child: Container( 
          margin: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              _crearTituloConError(),
              _crearCampoConError(_error["nombres"]!, "Nombre(s)", "Nombre(s)", "nombres"),
              _crearCampoConError(_error["apellidos"]!, "Apellidos", "Apellidos", "apellidos"),
              _crearCampoConError(_error["email"]!, "Email", "Email", "email"),
              _crearCampoPassConError(),
              _crearBoton(),
              _crearTextoInferior(),
            ],
          ),
        ),
      )
    );
  }
  Widget _crearTextoInferior(){
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login2Screen()));
      },
      child: Container(
        margin: EdgeInsets.only(top: 16, bottom: 100),
        child: Center(
          child: RichText(
            text: TextSpan(children: const <TextSpan>[
              TextSpan(
                  text: "¿Ya tienes una cuenta? ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColorStyles.gris1)),
              TextSpan(
                  text: " Ingresar",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColorStyles.verde2)),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: () {
         _validarCamposRegister();
        },
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Continuar',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearCampoPassConError(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: AppDecorationStyle.campoContainer(),
            child: TextField(
              onChanged: (value) {
                _data["password"] = value;
                setState(() {});
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Contraseña",
                labelText:  "Contraseña",
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: AppColorStyles.verde2, // Color del borde cuando está enfocado
                    width: 2.0, // Ancho del borde cuando está enfocado
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: _passwordVisible,
              style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
            ),
          ),
          if (_error["password"]!.isNotEmpty)
          Text(
            _error["password"]!,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
  Widget _crearCampoConError(String error, String labelText, String hintText, String campo){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: AppDecorationStyle.campoContainer(),
            child: TextField(
              onChanged: (value) {
                if(campo == "nombres"){
                  _data["nombres"] = value;
                }
                if(campo == "apellidos"){
                  _data["apellidos"] = value;
                }
                if(campo == "email"){
                  _data["email"] = value;
                }
                setState(() {});
              },
              decoration: AppDecorationStyle.campoTexto(hintText: hintText, labelText: labelText),
              style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
            ),
          ),
          if (error.isNotEmpty)
          Text(
            error,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
  Widget _crearTituloConError(){
    return Column(
      children: <Widget>[ // Espacio entre el icono y el texto
        Container(
          alignment: Alignment.centerLeft, 
          child: Text(
            "Registremos tu cuenta",
            style: AppTitleStyles.onboarding(color: AppColorStyles.verde1),
            textAlign: TextAlign.start,
          ),
        ),
        Text(
          'Posterior a tu registro, llenarás tu perfil para recibir recomendaciones vocacionales de carreras a estudiar.',
          style: TextStyle(
            color: AppColorStyles.oscuro1,
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
        ),
        if (_error["error"]!.isNotEmpty)
        Container(
          alignment: Alignment.centerLeft, 
          //margin: EdgeInsets.only(top: 10),
          child: Text(
            _error["error"]!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
  void showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  MySpacing.width(20),
                  MyText.bodyMedium("Espera por favor...",
                      fontWeight: 600, letterSpacing: 0.3)
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}