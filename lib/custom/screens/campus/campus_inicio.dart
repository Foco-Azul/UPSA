import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/campus.dart';
import 'package:flutkit/custom/screens/campus/carreras_inicio.dart';
import 'package:flutkit/custom/screens/campus/contacto_screem.dart';
import 'package:flutkit/custom/screens/campus/convenio_screem.dart';
import 'package:flutkit/custom/screens/campus/cursillos_inicio.dart';
import 'package:flutkit/custom/screens/campus/matriculate_screem.dart';
import 'package:flutkit/custom/screens/campus/sobre_nosotros_escreen.dart';
import 'package:flutkit/custom/screens/campus/test_vocacional_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      return Scaffold(
        backgroundColor: AppColorStyles.altFondo1,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _crearGaleriaImagenes(),
              _crearDescripcion(),
              _buildPulsableContainer(context,
                'Carreras',
                Icons.library_books_outlined,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CarrerasInicio()));
                },
              ),
              _buildPulsableContainer(
                context,
                'Cursillos',
                LucideIcons.playCircle,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CursillosInicio()));
                },
              ),
              _buildPulsableContainer(context,
                'Internacionalización',
                LucideIcons.heartHandshake,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConvenioScreen()));
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
                'Inscribite',
                Icons.assignment_turned_in_outlined,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MatriculateScreen()));
                },
              ),
              _buildPulsableContainer(
                context,
                'Test vocacional',
                Icons.person_search_outlined,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TestVocacionalScreen()));
                },
              ),
              _buildPulsableContainer(
                context,
                'Contacto',
                LucideIcons.mail,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ContactoScreen()));
                },
              ),
              _buildPulsableContainer(context,
                'Sobre nosotros',
                Icons.school_outlined,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SobreNosotrosScreen()));
                },
              ),
            ]
          )
        )
      );
    }
  }

  Widget _crearDescripcion(){
    return Container(
      margin: MySpacing.symmetric(horizontal: 16, vertical: 16),
      child: MyText(
        _campus.descripcion!,
        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2)
      ),
    );
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
            bottom: 10,
            left: 10, // Añade esta línea para alinear a la izquierda
            child: _buildPageIndicatorStatic(),
          ),
        ],
      )
    );
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
            '${_currentPage + 1}/${_campus.imagenes!.length}',
            style: AppTextStyles.etiqueta(color: AppColorStyles.blanco)
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
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.network(
            _backUrl + url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        )
      );
    }).toList();
  }
  Widget _buildPulsableContainer(BuildContext context, String texto, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        decoration: AppDecorationStyle.tarjeta(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texto,
              style: AppTitleStyles.tarjeta()
            ),
            Icon(icono, size: 30.0, color: AppColorStyles.altTexto1,)
          ],
        ),
      ),
    );
  }
}