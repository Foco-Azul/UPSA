import 'package:flutkit/custom/auth/register_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
//import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
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
     // Redirigir a AccountSettingScreen
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
    try {
      User user = (await ApiService().login(_email, _password))!;
      if (user.id == null) {
        setState(() {
          _error = "Email o contraseña incorrecta";
        });
      } else {
        Provider.of<AppNotifier>(context, listen: false).login();
        Provider.of<AppNotifier>(context, listen: false).setUser(user);
        MensajeTemporalInferior().mostrarMensaje(context,"Ingreso exitoso.",Color.fromRGBO(32, 104, 14, 1), Color.fromRGBO(255, 255, 255, 1));
        switch (user.estado) {
          case "Nuevo":
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
            Navigator.push(context,MaterialPageRoute(builder: (context) => ValidarEmail(theme: theme)));
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
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().substring(11);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 251, 249, 1),
      appBar: AppBar(
        toolbarHeight: 40, // Altura del AppBar
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: theme.colorScheme.onBackground,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
              color: Color.fromRGBO(244, 251, 249, 1),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[ // Espacio entre el icono y el texto
                      MyText.titleLarge(
                        "Ingresa con tu email",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_error.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 16, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                      spreadRadius: 2, // Radio de propagación
                                      blurRadius: 5, // Radio de desenfoque
                                      offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      _email = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                    border: InputBorder.none,
                                    labelText: 'Email',
                                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(5, 50, 12, 1),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                              if (_errorEmail.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  _errorEmail,
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                      spreadRadius: 2, // Radio de propagación
                                      blurRadius: 5, // Radio de desenfoque
                                      offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                    border: InputBorder.none,
                                    labelText: 'Contraseña',
                                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(5, 50, 12, 1),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(_passwordVisible!
                                          ? LucideIcons.eyeOff
                                          : LucideIcons.eye),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible!;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _passwordVisible!,
                                ),
                              ),
                              if (_errorPassword.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    _errorPassword,
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        /*
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          alignment: Alignment.centerRight,
                          child: MyText.bodyMedium("¿Olvidaste tu contraseña?",
                              fontWeight: 500),
                        ),*/
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 26),
                          child: CupertinoButton(
                            color: Color.fromRGBO(5, 50, 12, 1),
                            onPressed: () {
                              _validarCamposLogin();
                            },
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            padding: MySpacing.xy(100, 16),
                            pressedOpacity: 0.5,
                            child: MyText.bodyMedium(
                              "Ingresar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register2Screen()));
              },
              child: Container(
                margin: EdgeInsets.only(top: 16),
                child: Center(
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: "¿No tienes una cuenta? ",
                          style: MyTextStyle.bodyMedium(fontWeight: 500)),
                      TextSpan(
                          text: " Registrarse",
                          style: MyTextStyle.bodyMedium(
                              fontWeight: 600,
                              color: theme.colorScheme.primary)),
                    ]),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MyCustomClipper extends CustomClipper<Path> {
  final BuildContext _context;

  _MyCustomClipper(this._context);

  @override
  Path getClip(Size size) {
    final path = Path();
    Size size = MediaQuery.of(_context).size;
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(0, size.height * 0.6);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
