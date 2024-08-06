import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/carrera_upsa.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class CarreraScreen extends StatefulWidget {
  const CarreraScreen({Key? key,this.id=-1}) : super(key: key);
  final int id;
  @override
  _CarreraScreenState createState() => _CarreraScreenState();
}

class _CarreraScreenState extends State<CarreraScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  String text = "La Doble Titulación de Arquitectura con la Università degli Studi di Genova (UNIGE) beneficia a los estudiantes de la UPSA que han culminado el séptimo semestre, eso los habilita para estudiar en la mencionada universidad italiana durante un año, luego de lo cual deben elaborar un proyecto que les permite obtener el título italiano de Licenciatura. Al retornar a Bolivia concluyen con el proceso de graduación para la Licenciatura en Arquitectura en la UPSA. Como profesional licenciado en Arquitectura podrás participar en la estructuración del hábitat en forma científica, responsable y funcional. Dado que la formación en Arquitectura integra conocimientos y habilidades tecnológicas, sociales y artísticas, con un alto sentido crítico, podrás responder en forma adecuada a los desafíos urbanísticos y la complejidad de las tareas que te plantea la profesión. Estarás en condiciones de proponer proyectos que resuelvan el requerimiento en forma efectiva, factible y al mismo tiempo atractiva, ya sea como profesional independiente, como empresario de la construcción o en una empresa o institución. Podrás desarrollar avalúos, peritajes técnicos, investigación urbana, patrimonial, tecnológica, así como organizar y liderar actividades de impacto social y ambiental.";
  int _id = -1;
  CarreraUpsa _carreraUpsa = CarreraUpsa();
  String _backUrl = "";
  List<List<Map<String, dynamic>>> _dataParaDesplegable = [];

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _id = widget.id;
    _cargarDatos();
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _carreraUpsa = await ApiService().getCarreraUpsa(_id);
    _dataParaDesplegable = FuncionUpsa.armarListaParaDesplegablesPlanDeEstudios(_carreraUpsa.planEstudios!);
    setState(() {
      controller.uiLoading = false;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading || _id == -1) {
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
        backgroundColor: AppColorStyles.verdeFondo,
        appBar: AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          centerTitle: true,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: RichText(
                text: TextSpan(
                  text:  _carreraUpsa.nombre!,
                  style: AppTitleStyles.principal(),
                ),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _facultadNombre(),
              _bannerCarrera(),
              _descripcionCarrera(),
              _pestanias(), 
              _crearPlanDeEstudios(),
              _crearMasInformacion(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blancoFondo,
          selectedIndex: 2,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
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
  Widget _crearMasInformacion(){
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Más información", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
          ),
          SizedBox(height: 15,),
          Text(
            "Visita nuestra página web para obtener mayor información sobre esta carrera.",
            style: AppTextStyles.parrafo(),
          ),
          SizedBox(height: 15,),
          Container(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () async {
                if (!await launchUrl(
                    Uri.parse("https://upsa.edu.bo/"),
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception('Could not launch ${"https://upsa.edu.bo/"}');
                  }
              },
              style: AppDecorationStyle.botonContacto(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_outlined,
                    color: AppColorStyles.blancoFondo,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Ir a la pagina web',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _crearDesplegable(List<Map<String, dynamic>> data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      decoration: AppDecorationStyle.desplegable(),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            data[index]["isExpanded"] = isExpanded;
          });
        },
        children: data.map<ExpansionPanel>((dynamic item) {
          return ExpansionPanel(
            backgroundColor: AppColorStyles.blancoFondo,
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
  Widget _crearListaDesplegables() {
    return Column(
      children: List.generate(_dataParaDesplegable.length, (index) {
        return _crearDesplegable(_dataParaDesplegable[index]);
      }),
    );
  }
  Widget _crearPlanDeEstudios(){
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plan de estudios", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
          ),
          _crearListaDesplegables(),
        ],
      ),
    );
  }
  Widget getTabContent(String text) {
    switch (text) {
      case "Campo Laboral":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _carreraUpsa.campoLaboral!, 
            style: AppTextStyles.parrafo()
          ),
        );
      case "Perfil del postulante":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _carreraUpsa.perfilPostulante!, 
            style: AppTextStyles.parrafo()
          ),
        );
      case "Objetivos":
        return Container(
          padding: EdgeInsets.all(15),
          child : Text( 
            _carreraUpsa.objetivos!, 
            style: AppTextStyles.parrafo()
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.all(15),
          child : Text("", 
          style: AppTextStyles.parrafo()
          ),
        );
    }
  }
  Widget _pestanias(){
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                child: Text(
                  "Campo Laboral",
                  style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.verde1),
                ),
              ),
              Tab(
                child: Text(
                  "Perfil del postulante",
                  style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.verde1),
                ),
              ),
              Tab(
                child: Text(
                  "Objetivos",
                  style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.verde1),
                ),
              ),
            ],
            tabAlignment: TabAlignment.start,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColorStyles.verde1, width: 2.0),
            ),
          ),
          SizedBox( 
            height: MediaQuery.of(context).size.height * 0.3,
            child: TabBarView(
              children: <Widget>[
                getTabContent('Campo Laboral'),
                getTabContent('Perfil del postulante'),
                getTabContent('Objetivos'),
              ],
            ),
          )
        ]
      )
    );
  }
  Widget _descripcionCarrera() {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: AppDecorationStyle.tarjeta(),
      child: Text(
        text,
        style: AppTextStyles.parrafo(),
      ),
    );
  }
  Widget _bannerCarrera() {
    return Container(
      margin: EdgeInsets.all(15), // Margen de 8.0 en todos los lados
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0), // Radio del borde
        child: Image.network(
          _backUrl+_carreraUpsa.imagen!,
          height: 240.0,
          fit: BoxFit.cover, // Ajuste de la imagen
        ),
      ),
    );
  }
  Widget _facultadNombre() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        _carreraUpsa.categoria!.nombre!,
        style: AppTextStyles.botonMenor(color: AppColorStyles.gris2),
        textAlign: TextAlign.center,
      ),
    );
  }
}