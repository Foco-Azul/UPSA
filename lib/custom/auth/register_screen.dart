import 'dart:ui';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/generadores.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';
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
  String _username = "", _password ="", _email = "", _token = "";
  String _error = "", _errorPassword ="", _errorEmail = "";
  late SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    Provider.of<AppNotifier>(context, listen: false).iniciar();
    _cargarDatos();
  }
  void _cargarDatos() async{
    _prefs = await SharedPreferences.getInstance();
  }
  void _validarCamposRegister(){
    setState(() {
      _errorEmail = validacion.validarCorreo(_email, true);
      _errorPassword = validacion.validarContrasenia(_password, true);
    });
    if(_errorEmail.isEmpty && _errorPassword.isEmpty){
      _signup();
    }
  }
  void _signup() async {
    try {
      showPopup(context);
      _username = _email;
      _token = generador.generarToken();
      String tokenDispositivo = _prefs.getString('tokenDispositivo')!;
      User? createduser = await ApiService().addUser(_email, _username, _password, _token, tokenDispositivo);
      if (createduser != null) {
        // navigate to the dashboard.
        Provider.of<AppNotifier>(context, listen: false).login();
        Provider.of<AppNotifier>(context, listen: false).setUser(createduser);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4)),(Route<dynamic> route) => false);
        Navigator.push(context,MaterialPageRoute(builder: (context) => ValidarEmail(theme: theme, estado: 1)));
      }else{
        _error = "Ya existe una cuenta con el mismo correo electronico.";
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      setState(() {
        if(e.toString().substring(11) == "Exception: Email already taken"){
          _error = "Ya existe una cuenta con el mismo correo electronico.";
        }else{
          _error = "Algo salio mal";
        }
      });
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            MyContainer.bordered( 
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
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(LucideIcons.mail, size: 24), // Icono a la izquierda
                            SizedBox(width: 8), // Espacio entre el icono y el texto
                            MyText.titleLarge(
                              "Registrate con tu email",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8), // Espacio entre el título y el texto
                        MyText.bodyMedium(
                          'Posterior a tu registro podrás iniciar el llenado de tu perfil',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error.isNotEmpty)
                  Column(
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
                  Container(
                    padding: EdgeInsets.only(top: 8),
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
                                      icon: Icon(_passwordVisible
                                          ? LucideIcons.eyeOff
                                          : LucideIcons.eye),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _passwordVisible,
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
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 26),
                          child: CupertinoButton(
                            color: Color.fromRGBO(32, 104, 14, 1),
                            onPressed: () {
                              _validarCamposRegister();
                            },
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            padding: MySpacing.xy(100, 16),
                            pressedOpacity: 0.5,
                            child: MyText.bodyMedium(
                              "Continuar",
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Login2Screen()));
              },
              child: Container(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "¿Ya tienes una cuenta? ",
                        style: MyTextStyle.bodyMedium(fontWeight: 500)),
                    TextSpan(
                        text: " Ingresar",
                        style: MyTextStyle.bodyMedium(
                            fontWeight: 600,
                            color: theme.colorScheme.primary)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      )
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
