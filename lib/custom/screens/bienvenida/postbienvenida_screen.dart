import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/register_screen.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostBienvenidaScreen extends StatefulWidget {
  PostBienvenidaScreen({Key? key}) : super(key: key);

  @override
  _PostBienvenidaScreenState createState() => _PostBienvenidaScreenState();
}

class _PostBienvenidaScreenState extends State<PostBienvenidaScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late ThemeData theme;
  late CustomTheme customTheme;
  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;


  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, value, child) {
        isDark = AppTheme.themeType == ThemeType.dark;
        textDirection = AppTheme.textDirection;
        theme = AppTheme.theme;
        customTheme = AppTheme.customTheme;
        return Theme(
          data: theme,
          child: Scaffold(
            backgroundColor: Color.fromRGBO(244, 251, 249, 1),
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 40, // Altura mínima deseada
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
                  },
                  child: Container(
                    padding: MySpacing.x(20),
                    child: MyText(
                      'Saltar',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Opacity(
                  opacity: 0.5, // Establece el nivel de opacidad (0.0 a 1.0)
                  child: Image.network(
                    'https://upsa.focoazul.com/uploads/bienvenida_1_6b71364bfe.png',
                  ),
                ),
                Spacer(), // Empuja el siguiente Container hacia abajo
                Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(11, 88, 66, 1), // Establece el color de fondo
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      padding: EdgeInsets.all(16.0), // Añade padding para dar espacio alrededor del contenido
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Hace que el Column se adapte al tamaño de su contenido
                        children: [
                          Container(
                            padding: MySpacing.only(top: 10),
                            child: Icon(
                              Icons.rocket, // Icono que deseas mostrar
                              color: Colors.white, // Color del icono
                              size: 50, // Tamaño del icono
                            ),
                          ),
                          Container(
                            padding: MySpacing.fromLTRB(16, 0, 16, 0),
                            margin: MySpacing.only(top: 16),
                            child: MyText.titleLarge(
                              'Despegando',
                              fontWeight: 700,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: MySpacing.fromLTRB(16, 0, 16, 20),
                            margin: MySpacing.top(16),
                            child: MyText.bodyMedium(
                              'Inicia tu carrera universitaria junto a la UPSA.',
                              fontWeight: 500,
                              height: 1.2,
                              textAlign: TextAlign.center,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 26), // Ajusta el valor según sea necesario
                            child: CupertinoButton(
                              color: Color.fromRGBO(5, 50, 10, 1),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Register2Screen()));
                              },
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              padding: MySpacing.xy(75, 16),
                              pressedOpacity: 0.5,
                              child: MyText.bodyMedium(
                                "Registrar mi cuenta",
                                color: theme.colorScheme.onSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 26), // Ajusta el valor según sea necesario
                            decoration: BoxDecoration(
                              border: Border.all(color: Color.fromRGBO(32, 104, 14, 1)), // Color del borde
                              borderRadius: BorderRadius.circular(14), // Radio de borde
                            ),
                            child: CupertinoButton(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Login2Screen()));
                              },
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              padding: MySpacing.xy(100, 16),
                              pressedOpacity: 0.5,
                              child: MyText.bodyMedium(
                                "Iniciar Sesión",
                                color: Color.fromRGBO(5, 50, 10, 1),
                                fontSize: 16,
                                fontWeight: 600,
                              ),
                            ),
                          ),
                          Container(
                            padding: MySpacing.fromLTRB(16, 26, 16, 0),
                            margin: MySpacing.top(16),
                            child: MyText.bodyMedium(
                              'Al registrar tu cuenta, aceptas nuestros \nTérminos de uso y Políticas de privacidad.',
                              fontWeight: 400,
                              height: 1.2,
                              textAlign: TextAlign.center,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
