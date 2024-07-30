import 'package:flutkit/custom/auth/register_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class Login2Screen extends StatefulWidget {
  static const namedRoute = "login2-screen";
  @override
  _Login2ScreenState createState() => _Login2ScreenState();
}

class _Login2ScreenState extends State<Login2Screen> {
  bool? _passwordVisible = true;
  late CustomTheme customTheme;
  late ThemeData theme;
  String _email = "";
  String _password = "";
  String _error = "";
  String _errorEmail = "";
  String _errorPassword = "";
  Validacion validacion = Validacion();

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }
  void _validarCamposLogin(){
    setState(() {
      _errorEmail = validacion.validarCorreo(_email, true);
      _errorPassword = validacion.validarContrasenia(_password, true);
    });
    if(_errorEmail.isEmpty && _errorPassword.isEmpty){
      _login();
    }
  }
  void _login() async {
    User user = await ApiService().login(_email, _password);
    if (user.id == -1) {
      setState(() {
        _error = "Email o contraseña incorrecta";
      });
    } else {
      Provider.of<AppNotifier>(context, listen: false).login();
      Provider.of<AppNotifier>(context, listen: false).setUser(user);
      MensajeTemporalInferior().mostrarMensaje(context,"Ingreso exitoso.", "exito");
      switch (user.estado) {
        case "Nuevo":
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context,MaterialPageRoute(builder: (context) => ValidarEmail()));
          break;
        case "Verificado":
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroPerfil()));
          break;
        case "Perfil parte 1":
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
          break;
        case "Perfil parte 2":
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
          break;
        case "Completado":
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
          break;
        default:
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
          break;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
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
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _crearTituloConError(),
              _crearCampoConError(_errorEmail, "Email", "Email", "email"),
              _crearCampoPassConError(),
              _crearBoton(),
              _crearTextoInferior(),
            ],
          ),
        )
      ),
    );
  }
  Widget _crearTextoInferior(){
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register2Screen()));
      },
      child: Container(
        margin: EdgeInsets.only(top: 16, bottom: 100),
        child: Center(
          child: RichText(
            text: TextSpan(children: const <TextSpan>[
              TextSpan(
                  text: "¿No tienes una cuenta? ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColorStyles.gris1)),
              TextSpan(
                  text: " Registrarse",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColorStyles.verde2)),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _crearTituloConError(){
    return Column(
      children: <Widget>[ // Espacio entre el icono y el texto
        Container(
          alignment: Alignment.centerLeft, 
          child: Text(
            "Ingresa con tu email",
            style: AppTitleStyles.onboarding(color: AppColorStyles.verde1),
            textAlign: TextAlign.start,
          ),
        ),
        if (_error.isNotEmpty)
        Container(
          alignment: Alignment.centerLeft, 
          margin: EdgeInsets.only(top: 10),
          child: Text(
            _error,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: () {
          _validarCamposLogin();
        },
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Ingresar',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
        ),
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
                if(campo == "email"){
                  _email = value;
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
                _password = value;
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
                  icon: Icon(_passwordVisible! ? LucideIcons.eyeOff : LucideIcons.eye),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible!;
                    });
                  },
                ),
              ),
              obscureText: _passwordVisible!,
              style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
            ),
          ),
          if (_errorPassword.isNotEmpty)
          Text(
            _errorPassword,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}