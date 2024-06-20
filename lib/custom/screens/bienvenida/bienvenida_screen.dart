import 'dart:async';

import 'package:flutkit/custom/screens/bienvenida/postbienvenida_screen.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {

  int selectedIndex = 0;

  late ThemeData theme;
  late CustomTheme customTheme;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPages = 3;
  bool isDark = false;
  String _backUrl = "";
  List<Widget> _buildPageIndicatorStatic() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: MySpacing.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Color.fromRGBO(32, 104, 14, 1)
            : theme.colorScheme.primary.withAlpha(120),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }

  TextDirection textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }
  void cargarDatos() async{
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    setState(() {});
  }
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
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Imagen en la parte superior
                
                // Contenedor con botón de continuar
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Obtener la altura máxima basada en el contenido
                    double maxHeight = constraints.maxHeight;
                    // Definir la altura máxima permitida
                    double maxAllowedHeight = 700;
                    // Calcular la altura final para el PageView
                    double height = maxHeight > maxAllowedHeight ? maxAllowedHeight : maxHeight;
                    return SizedBox(
                      height: height,
                      child: PageView(
                        pageSnapping: true,
                        physics: ClampingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: <Widget>[
                          _SingleNewsPage(
                            title: "Conéctate con tu nueva vida universitaria",
                            description: "Encuentra las últimas novedades, becas y eventos para bachilleres como vos.",
                            imagen: '$_backUrl/uploads/bienvenida_1_6b71364bfe.png',
                          ),
                          _SingleNewsPage(
                            title: "Participa junto a tu promo",
                            description: "Sus memorias aparecerán en tu perfil, junto a tus actividades a participar.",
                            imagen: '$_backUrl/uploads/bienvenida_2_5c423ed23b.png',
                          ),
                          _SingleNewsPage(
                            title: "Prepárate para tu futuro",
                            description: "Junto a nuestros cursillos, quizzes e info de carreras, podrás estar mejor preparado en tu formación académica.",
                            imagen: '$_backUrl/uploads/bienvenida_3_74cd77fbda.png',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  padding: MySpacing.bottom(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicatorStatic(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 26), // Ajusta el valor según sea necesario
                  child: CupertinoButton(
                    color: Color.fromRGBO(0, 51, 5, 1),
                    onPressed: () {
                      Provider.of<AppNotifier>(context, listen: false).setEsNuevo(false);
                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => PostBienvenidaScreen()),(Route<dynamic> route) => false);
                    },
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    padding: MySpacing.xy(100, 16),
                    pressedOpacity: 0.5,
                    child: MyText.bodyMedium(
                      "Comencemos",
                      color: theme.colorScheme.onSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SingleNewsPage extends StatelessWidget {
  final String title, description, imagen;

  const _SingleNewsPage(
      {Key? key,
      required this.title,
      required this.description,
      required this.imagen,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: MySpacing.fromLTRB(0, 100, 0, 24),
          child: Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.height * 1,
                    child: Image.network(
                      imagen,
                      fit: BoxFit.cover, // Ajusta la imagen para cubrir todo el espacio
                    ),
                  ),
                  Container(
                    padding: MySpacing.fromLTRB(0, 24, 0, 0),
                    margin: MySpacing.only(top: 16, left: 16, right: 16),
                    child: MyText(title, fontWeight: 700, fontSize: 24, textAlign: TextAlign.center,),
                  ),
                  Container(
                    margin: MySpacing.top(16),
                    child: MyText.bodyMedium(description, fontWeight: 500, height: 1.2, textAlign: TextAlign.center, fontSize: 15,),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}