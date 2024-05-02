import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/generadores.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/custom/widgets/verification_acount_noti.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';


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
  String _username = "", _password ="", _email = "", _primerNombre = "", _token = "", _apellidoPaterno = "";
  String _error = "", _errorPassword ="", _errorEmail = "", _errorPrimerNombre = "", _errorApellidoPaterno = "";
  int _isInProgress = -1;
  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }
  void _validarCamposRegister(){
    setState(() {
      _errorPrimerNombre = validacion.validarNombres(_primerNombre, true);
      _errorApellidoPaterno = validacion.validarNombres(_apellidoPaterno, true);
      _errorEmail = validacion.validarCorreo(_email, true);
      _errorPassword = validacion.validarContrasenia(_password, true);
    });
    if(_errorPrimerNombre.isEmpty && _errorApellidoPaterno.isEmpty && _errorEmail.isEmpty && _errorPassword.isEmpty){
      _signup();
    }
  }
  void _signup() async {
    try {
      setState(() {
        _isInProgress = 0;
      });
      _username = _email;
      _token = generador.generarToken();
      User? createduser = await ApiService().addUser(context, _email, _username, _password, _primerNombre, _apellidoPaterno, _token);
      if (createduser != null) {
        // navigate to the dashboard.
        Provider.of<AppNotifier>(context, listen: false).login();
        Provider.of<AppNotifier>(context, listen: false).setUser(createduser);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4)),(Route<dynamic> route) => false);
        Navigator.push(context,MaterialPageRoute(builder: (context) => ValidarEmail(theme: theme, estado: 1)));
      }else{
        _error = "Ya existe una cuenta con el mismo correo electronico.";
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().substring(11);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: _MyCustomClipper(context),
            child: Container(
              alignment: Alignment.center,
              color: theme.colorScheme.background,
            )
          ),
          Positioned(
            left: 30,
            right: 30,
            top: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              children: <Widget>[
                MyContainer.bordered(
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        child: MyText.titleLarge("REGISTRARSE", fontWeight: 600),
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
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    _primerNombre = value;
                                  });
                                },
                                style: MyTextStyle.bodyLarge(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Primer nombre",
                                  hintStyle: MyTextStyle.bodyLarge(
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 500),
                                  prefixIcon: Icon(LucideIcons.user),
                                  error: _errorPrimerNombre.isNotEmpty
                                  ? Text(
                                      _errorPrimerNombre,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : null,
                                ),
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    _apellidoPaterno = value;
                                  });
                                },
                                style: MyTextStyle.bodyLarge(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Apellido paterno",
                                  hintStyle: MyTextStyle.bodyLarge(
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 500),
                                  prefixIcon: Icon(LucideIcons.user),
                                  error: _errorApellidoPaterno.isNotEmpty
                                  ? Text(
                                      _errorApellidoPaterno,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : null,
                                ),
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    _email = value;
                                  });
                                },
                                style: MyTextStyle.bodyLarge(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Correo electronico",
                                  hintStyle: MyTextStyle.bodyLarge(
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 500),
                                  prefixIcon: Icon(LucideIcons.mail),
                                  error: _errorEmail.isNotEmpty
                                  ? Text(
                                      _errorEmail,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : null,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    _password = value;
                                  });
                                },
                                style: MyTextStyle.bodyLarge(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500),
                                decoration: InputDecoration(
                                  hintText: "Contraseña",
                                  hintStyle: MyTextStyle.bodyLarge(
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 500),
                                  prefixIcon: Icon(LucideIcons.lock),
                                  error: _errorPassword.isNotEmpty
                                  ? Text(
                                      _errorPassword,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : null,
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
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: MyButton.block(
                                elevation: 0,
                                borderRadiusAll: 4,
                                onPressed: () => _validarCamposRegister(),
                                padding: MySpacing.y(20),
                                child: MyText.labelMedium(
                                  "REGISTRARME",
                                  fontSize: 12,
                                  fontWeight: 600,
                                  color: theme.colorScheme.onPrimary,
                                  letterSpacing: 0.5,
                                ),
                              )
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
                )
              ],
            ),
          ),
          Positioned(
            top: MySpacing.safeAreaTop(context) + 12,
            left: 16,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                LucideIcons.chevronLeft,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          if (_isInProgress == 0)
          ProgressEspera(
            theme: theme, // Pasar el tema como argumento
          ),
          if (_isInProgress == 1)
          VerificationDialog(
            theme: theme,
            estado: 1 // Pasar el tema como argumento
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
