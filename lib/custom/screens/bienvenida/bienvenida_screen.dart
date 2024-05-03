import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/screens/bienvenida/postbienvenida_screen.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                        children: const <Widget>[
                          _SingleNewsPage(
                            title: "App para bachilleres",
                            description: "Encuentra las últimas novedades, becas y eventos para bachilleres como vos",
                            imagen: 'https://upsa.focoazul.com/uploads/welcome_ae39f62406.png',
                          ),
                          _SingleNewsPage(
                            title: "App para bachilleres",
                            description: "Encuentra las últimas novedades, becas y eventos para bachilleres como vos",
                            imagen: 'https://upsa.focoazul.com/uploads/welcome_ae39f62406.png',
                          ),
                          _SingleNewsPage(
                            title: "App para bachilleres",
                            description: "Encuentra las últimas novedades, becas y eventos para bachilleres como vos",
                            imagen: 'https://upsa.focoazul.com/uploads/welcome_ae39f62406.png',
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
                    color: Color.fromRGBO(32, 104, 14, 1),
                    onPressed: () {
                      Provider.of<AppNotifier>(context, listen: false).setEsNuevo(false);
                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => PostBienvenidaScreen()),(Route<dynamic> route) => false);
                    },
                    borderRadius: BorderRadius.all(Radius.circular(14)),
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
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: MySpacing.fromLTRB(0, 24, 0, 24),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.50, // 60% de la altura de la pantalla
                      width: MediaQuery.of(context).size.height * 1,
                      child: Image.network(
                        imagen,
                        fit: BoxFit.cover, // Ajusta la imagen para cubrir todo el espacio
                      ),
                    ),
                    Container(
                      padding: MySpacing.fromLTRB(0, 24, 0, 0),
                      margin: MySpacing.only(top: 16),
                      child: MyText.titleLarge(title, fontWeight: 700, fontSize: 24,),
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
      ),
    );
  }
}