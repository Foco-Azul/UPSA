import 'package:flutkit/custom/auth/register_screen.dart';
import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
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
        showSnackBarWithFloating("Ingreso exitoso", Color.fromRGBO(32, 104, 14, 1));
        if(!user.confirmed!){
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context,MaterialPageRoute(builder: (context) => ValidarEmail(theme: theme)));
        }else{
          if(!user.completada!){
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
            Navigator.push(context,MaterialPageRoute(builder: (context) => RegistroEstudiante()));
          }else{
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
          }
        }
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().substring(11);
      });
    }
  }
  void showSnackBarWithFloating(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(message, color: theme.colorScheme.onPrimary),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Stack(
        children: <Widget>[
          ClipPath(
              clipper: _MyCustomClipper(context),
              child: Container(
                alignment: Alignment.center,
                color: theme.colorScheme.background,
              )),
          Positioned(
            left: 30,
            right: 30,
            top: MediaQuery.of(context).size.height * 0.13,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                MyContainer.bordered(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: const <Widget>[
                            Icon(LucideIcons.atSign, size: 40, color: Color.fromRGBO(215, 215, 215, 1),), // Icono a la izquierda
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(LucideIcons.mail, size: 24), // Icono a la izquierda
                          SizedBox(width: 8), // Espacio entre el icono y el texto
                          MyText.titleLarge(
                            "Ingresa con tu email",
                            style: TextStyle(
                              fontSize: 20.0,
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
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                            color: Color.fromRGBO(32, 104, 14, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
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
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                            color: Color.fromRGBO(32, 104, 14, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
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
                                color: Color.fromRGBO(32, 104, 14, 1),
                                onPressed: () {
                                  _validarCamposLogin();
                                },
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                padding: MySpacing.xy(100, 16),
                                pressedOpacity: 0.5,
                                child: MyText.bodyMedium(
                                  "Ingresar",
                                  color: theme.colorScheme.onSecondary,
                                  fontSize: 16,
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
        ],
      )
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
