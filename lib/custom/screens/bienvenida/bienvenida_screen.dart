import 'package:flutkit/custom/screens/bienvenida/postbienvenida_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key? key}) : super(key: key);
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPages = 3;

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
      decoration: BoxDecoration(color: isActive ? AppColorStyles.altVerde1 : AppColorStyles.gris2,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.altFondo1,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _crearCarrusel(),
          _crearBotonesNav(),
          _crearBoton(),
        ],
      ),
    );
  }

  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () {
          Provider.of<AppNotifier>(context, listen: false).setEsNuevo(false);
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => PostBienvenidaScreen()),(Route<dynamic> route) => false);
        },
        style: AppDecorationStyle.botonBienvenida(colorFondo: AppColorStyles.altVerde1),
        child: Text(
          'Comencemos',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColorStyles.oscuro1), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearBotonesNav(){
    return 
      Container(
        margin: EdgeInsets.only(left: 15, right: 15, bottom: 30,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicatorStatic(),
        ),
      );
  }
  Widget _crearCarrusel() {
    return SizedBox(
      height: (MediaQuery.of(context).size.height) * 0.63, // Ajusta la altura según sea necesario
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          _crearContenido(
            'lib/custom/assets/images/bienvenida_1.png',
            'Conectate con tu nueva vida universitaria',
            'Enterate de las novedades de la Universidad y participá de eventos para bachilleres como vos.'
          ),
          _crearContenido(
            'lib/custom/assets/images/bienvenida_2.png',
            'Participá junto a tu promo',
            'Accedé a las memorias fotográficas de tu Promo en la UPSA desde tu perfil.'
          ),
          _crearContenido(
            'lib/custom/assets/images/bienvenida_3.png',
            'Preparate para tu futuro',
            'Accedé a nuestros cursillos en línea, quizzes especiales e info de carreras, para estar mejor preparado para tu formación académica.'
          ),
        ],
      ),
    );
  }
  Widget _crearContenido(String imagen, String titulo, String descripcion){
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: (MediaQuery.of(context).size.height) * 0.1,),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: (MediaQuery.of(context).size.height) * 0.3,
                child: Image.asset(
                  imagen,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20,),
              Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColorStyles.altTexto1, height: 1,), textAlign: TextAlign.center,),
              SizedBox(height: 8,),
              Text(descripcion, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColorStyles.gris1, height: 1.5), textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}