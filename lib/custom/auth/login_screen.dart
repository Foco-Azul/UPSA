import 'package:flutkit/custom/auth/register_screen.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';
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
          _error = "Correo o contraseña incorrecta";
        });
      } else {
        Provider.of<AppNotifier>(context, listen: false).login();
        Provider.of<AppNotifier>(context, listen: false).setUser(user);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
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
            top: MediaQuery.of(context).size.height * 0.2,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                MyContainer.bordered(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 24, top: 8),
                        child: MyText.titleLarge("ACCEDER", fontWeight: 600),
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
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _email = value;
                                });
                              },
                              style: MyTextStyle.bodyLarge(
                                  letterSpacing: 0.1,
                                  color: theme.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Correo electronico",
                                hintStyle: MyTextStyle.titleSmall(
                                    letterSpacing: 0.1,
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
                            ),
                            TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _password = value;
                                });
                              },
                              style: MyTextStyle.bodyLarge(
                                  letterSpacing: 0.1,
                                  color: theme.colorScheme.onBackground,
                                  fontWeight: 500),
                              decoration: InputDecoration(
                                hintText: "Contraseña",
                                hintStyle: MyTextStyle.titleSmall(
                                    letterSpacing: 0.1,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500),
                                prefixIcon: Icon(LucideIcons.lock),
                                //errorText: "Ingresa una contraseña",
                                error: _errorPassword.isNotEmpty
                                  ? Text(
                                      _errorPassword,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : null,
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
                            /*
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              alignment: Alignment.centerRight,
                              child: MyText.bodyMedium("¿Olvidaste tu contraseña?",
                                  fontWeight: 500),
                            ),*/
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: MyButton.block(
                                  elevation: 0,
                                  borderRadiusAll: 4,
                                  padding: MySpacing.y(20),
                                  onPressed: () => _validarCamposLogin(),
                                  child: MyText.labelMedium(
                                      "INGRESAR",
                                      fontSize: 12,
                                      fontWeight: 600,
                                      color: theme.colorScheme.onPrimary,
                                      letterSpacing: 0.5)),
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
          )
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
