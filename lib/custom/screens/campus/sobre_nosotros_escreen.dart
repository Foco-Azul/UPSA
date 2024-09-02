import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/sobre_nosotros.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/foto_full_screen.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SobreNosotrosScreen extends StatefulWidget {
  const SobreNosotrosScreen({Key? key}) : super(key: key);
  @override
  _SobreNosotrosScreenState createState() => _SobreNosotrosScreenState();
}

class _SobreNosotrosScreenState extends State<SobreNosotrosScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  String _backUrl = "";
  SobreNosotros _sobreNosotros = SobreNosotros();
  final List<List<dynamic>> _desplegables = [];
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Sobre_nosotros',
      screenClass: 'Sobre_nosotros', // Clase o tipo de pantalla
    );
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _sobreNosotros = await ApiService().getSobreNosotros();
    _modificarListaDesplegables();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _modificarListaDesplegables(){
    List<dynamic> aux = [];
    Map<String, Object> aux2;
    aux2 = {
      "headerValue": "Objetivos",
      "expandedValue": _sobreNosotros.objetivo!,
      "isExpanded": false
    };
    aux.add(aux2);
    _desplegables.add(aux);
    aux = [];
    aux2 = {
      "headerValue": "Respaldo legal",
      "expandedValue": _sobreNosotros.respaldoLegal!,
      "isExpanded": false
    };
    aux.add(aux2);
    _desplegables.add(aux);
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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            _sobreNosotros.titulo!,
            style: AppTitleStyles.principal()
          ),
        ),
        backgroundColor: AppColorStyles.altFondo1,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _crearGaleriaImagenes(),
              _contenedorDescripcion(),
              _pestanias(), 
              _crearListaDesplegables(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 2,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.account_circle_sharp),
              title: Text(
                'Mi perfil',
                style: AppTextStyles.bottomMenu()
              ),
            ),
          ],
          onItemSelected: (index) {
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: index,)),(Route<dynamic> route) => false);
          },
        ),
      );
    }
  }
  Widget _crearGaleriaImagenes(){
    return Container(
      margin: EdgeInsets.all(15), 
      child: Stack(
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
                return Container(
                  child: widget,
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8, // Añade esta línea para alinear a la izquierda
            child: _buildPageIndicatorStatic(),
          ),
        ],
      )
    );
  }
  Widget _crearListaDesplegables() {
    return Container( 
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        children: List.generate(_desplegables.length, (index) {
          return _crearDesplegable(_desplegables[index]);
        }),
      )
    );
  }
  Widget _crearDesplegable(List<dynamic> data) {
    return Container(
      margin: EdgeInsets.all(15),
      decoration: AppDecorationStyle.desplegable(),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            data[index]["isExpanded"] = isExpanded;
          });
        },
        children: data.map<ExpansionPanel>((dynamic item) {
          return ExpansionPanel(
            backgroundColor: AppColorStyles.blanco,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item["headerValue"], style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.gris2)),
              );
            },
            body: Container(
              padding: EdgeInsets.all(15.0),
              alignment: Alignment.centerLeft,
              child: Text(
                item["expandedValue"],
                style: AppTextStyles.parrafo(),
              ),
            ),
            isExpanded: item["isExpanded"],
          );
        }).toList(),
      ),
    );
  }
  Widget _pestanias(){
    return
      DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  child: Text(
                    "Misión",
                    style: AppTextStyles.botonMayor(color: AppColorStyles.altTexto1)
                  ),
                ),
                Tab(
                  child: Text(
                    "Visión",
                    style: AppTextStyles.botonMayor(color: AppColorStyles.altTexto1)
                  ),
                ),
                Tab(
                  child: Text(
                    "Valores",
                    style: AppTextStyles.botonMayor(color: AppColorStyles.altTexto1)
                  ),
                ),
                Tab(
                  child: Text(
                    "Comunidad",
                    style: AppTextStyles.botonMayor(color: AppColorStyles.altTexto1)
                  ),
                ),
              ],
              tabAlignment: TabAlignment.start,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: AppColorStyles.altTexto1, width: 2.0),
              ),
            ),
            SizedBox( 
              height: MediaQuery.of(context).size.height * 0.3,
              child: TabBarView(
                children: <Widget>[
                  getTabContent('Misión'),
                  getTabContent('Visión'),
                  getTabContent('Valores'),
                  getTabContent('Comunidad'),
                ],
              ),
            )
          ]
        )
      );
  }
  Widget getTabContent(String text) {
    switch (text) {
      case "Misión":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _sobreNosotros.mision!,
            style: AppTextStyles.parrafo()),
        );
      case "Visión":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _sobreNosotros.vision!,
            style: AppTextStyles.parrafo()),
        );
      case "Valores":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _sobreNosotros.valores!,
            style: AppTextStyles.parrafo()),
        );
      case "Comunidad":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _sobreNosotros.comunidad!,
            style: AppTextStyles.parrafo()),
        );
      default:
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            "",
            style: AppTextStyles.parrafo()),
        );
    }
  }
  Widget _contenedorDescripcion(){
    return
      Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColorStyles.blanco, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sobreNosotros.descripcion!,
              style: AppTextStyles.parrafo()
            ),
          ],
        ),
      );
  }
  List<Widget> _crearGaleria() {
    return _sobreNosotros.imagenes!.map((url) {
      return Stack(
        children: [
          Container(
            width: double.infinity, // Asegura que el contenedor ocupe todo el ancho disponible
            height: double.infinity,
            decoration: AppDecorationStyle.tarjeta(),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                _backUrl + url,
                height: 240.0,
                width: double.infinity, // Asegura que la imagen ocupe todo el ancho disponible
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 8, // Ajusta la posición del ícono según tu preferencia
            right: 8,
            child: GestureDetector(
              onTap: () {
                // Acción al pulsar el ícono
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(imageUrl: _backUrl + url),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColorStyles.altTexto1, // Color de fondo del contenedor
                  borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
                ),
                child: Icon(
                  Icons.fullscreen_outlined, // Cambia al ícono que prefieras
                  color: AppColorStyles.blanco, // Color del ícono
                  size: 24.0, // Tamaño del ícono
                ),
              )
            ),
          ),
        ],
      );
    }).toList();
  }
  Widget _buildPageIndicatorStatic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4), // Padding interno del contenedor
          decoration: BoxDecoration(
            color: AppColorStyles.altTexto1, // Color de fondo del contenedor
            borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
          ),
          child: Text(
            '${_currentPage + 1}/${_sobreNosotros.imagenes!.length}',
            style: AppTextStyles.etiqueta(color: AppColorStyles.blanco)
          ),
        ),
      ],
    );
  }
}
