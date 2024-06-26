import 'dart:async';

import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/campus.dart';
import 'package:flutkit/custom/screens/campus/cursillos_clase_screen.dart';
import 'package:flutkit/custom/screens/campus/sobre_nosotros_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CampusScreen extends StatefulWidget {
  const CampusScreen({Key? key}) : super(key: key);

  @override
  _CampusScreenState createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  late ThemeData theme;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late CustomTheme customTheme;
  int _numPages = 2;
  Campus _campus = Campus();
  String _backUrl= "";
  late ProfileController controller;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
    */
  }
  void _cargarDatos() async{
    _campus = await ApiService().getDatosCampus();
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    controller.uiLoading = false;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getSearchLoadingScreen(
            context,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: MySpacing.only(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: PageView(
                      pageSnapping: true,
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: _crearGaleria().map((widget) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: widget,
                        );
                      }).toList(),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10, // Añade esta línea para alinear a la izquierda
                    child: _buildPageIndicatorStatic(),
                  ),
                ],
              ),
              Container(
                margin: MySpacing.symmetric(horizontal: 16, vertical: 16),
                child: MyText(
                  "Formamos talentos humanos competitivos, con visión globalizada, espíritu emprendedor y sentido ético; preparados para crear, gestionar y liderar actividades productivas e innovadoras.",
                  fontSize: 14,
                  fontWeight: 400,
                ),
              ),
              Column(
                children: [
                  _buildPulsableContainer(context,
                    'Carreras',
                    Icons.library_books_outlined,
                    () {

                    },
                  ),
                  _buildPulsableContainer(
                    context,
                    'Cursillos',
                    LucideIcons.playCircle,
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CursillosClaseScreen()));
                    },
                  ),
                  _buildPulsableContainer(context,
                    'Convenios',
                    LucideIcons.heartHandshake,
                    () {

                    },
                  ),
                  _buildPulsableContainer(
                    context,
                    'Tour',
                    Icons.nordic_walking_outlined,
                    () async {
                      if (!await launchUrl(
                        Uri.parse("https://maps.upsa.edu.bo/"),
                        mode: LaunchMode.inAppWebView,
                      )) {
                        throw Exception('Could not launch');
                      }
                    },
                  ),
                  _buildPulsableContainer(context,
                    'Matriculate',
                    Icons.assignment_turned_in_outlined,
                    () {

                    },
                  ),
                  _buildPulsableContainer(
                    context,
                    'Contacto',
                    LucideIcons.mail,
                    () {
                      
                    },
                  ),
                  _buildPulsableContainer(context,
                    'Sobre nosotros',
                    Icons.school_outlined,
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SobreNosotrosScreen()));
                    },
                  ),
                ],
              ),
            ]
          )
        )
      );
    }
  }
  Widget _buildPulsableContainer(BuildContext context, String texto, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 2.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // Puedes cambiar a FontWeight.normal, FontWeight.w500, etc.
              ),
            ),
            Icon(icono, size: 30.0, color: Color.fromRGBO(0, 0, 0, 1),)
          ],
        ),
      ),
    );
  }
  Widget _buildPageIndicatorStatic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4), // Padding interno del contenedor
          decoration: BoxDecoration(
            color: Color.fromRGBO(133, 133, 133, 1), // Color de fondo del contenedor
            borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
          ),
          child: Text(
            '${_currentPage+1}/$_numPages',
            style: TextStyle(
              color: Colors.white, // Color del texto
              fontSize: 10,
              fontWeight: FontWeight.w700
            ),
          ),
        ),
      ],
    );
  }
  List<Widget> _crearGaleria() {
    return _campus.imagenes!.map((url) {
      return Container(
        decoration: BoxDecoration(
          color: customTheme.card,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: customTheme.shadowColor.withAlpha(120),
                blurRadius: 24,
                spreadRadius: 4)
          ]),
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Image.network(
            _backUrl+url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        ),
      );
    }).toList();
  }
}
