//import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';


class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late LoginController loginController;
  bool _isLoggedIn = false;
  User _user = User();
  UserMeta _userMeta = UserMeta();
  late ProfileController controller;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _numPages = 2;
  String _backUrl = "";
  final MensajeTemporalInferior _mensajeTemporalInferior = MensajeTemporalInferior();
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    loginController = LoginController();
    controller = ProfileController();
    _cargarDatos();
  }
  void _cargarDatos() async{
    await dotenv.load(fileName: ".env");
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user.eventosInscritos2 = await ApiService().getEventosInscritosForUserNotPopulate(_user.id!);
      _user.eventosSeguidos2 = await ApiService().getEventosSeguidosForUserNotPopulate(_user.id!);
      if(_user.estado != "Nuevo" && _user.estado != "Verificado"){
        _userMeta = await ApiService().getUserMeta(_user.id!);
      }
      _backUrl = dotenv.get('backUrl');
    }
    controller.uiLoading = false;
    setState(() {});
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
      return GetBuilder<LoginController>(
        init: loginController,
        tag: 'profile_controller',
        builder: (controller) {
          return _buildBody();
        });
    }
  }
  Widget _buildBody() {
    if(_isLoggedIn){
      return Scaffold(
        body: ListView(
          padding: MySpacing.fromLTRB(20, 10, 20, 20),
          children: [
            if((_user.estado != "Nuevo" && _user.estado != "Verificado"))
            _cabeceraPerfil(),
            if((_user.estado != "Nuevo" && _user.estado != "Verificado") && _userMeta.carreraSugerida!.isNotEmpty)
            _carreraSugerida(),
            Divider(),
            if(_user.eventosInscritos2!.isNotEmpty || _user.eventosSeguidos2!.isNotEmpty)
            _misActividades(),
            if(_user.eventosInscritos2!.isNotEmpty || _user.eventosSeguidos2!.isNotEmpty)
            Divider(),
            _miPromo(),
            Divider(),
            _ajustes(),
          ],
        ),
      );
    }else{
      return Scaffold(
        body: ListView(
          padding: MySpacing.fromLTRB(20, 10, 20, 20),
          children: [
            Container(
              margin: EdgeInsets.only(top: 26), // Ajusta el valor según sea necesario
              child: CupertinoButton(
                color: Color.fromRGBO(32, 104, 14, 1),
                onPressed: () {
                  loginController.logIn();
                },
                borderRadius: BorderRadius.all(Radius.circular(14)),
                padding: MySpacing.xy(100, 16),
                pressedOpacity: 0.5,
                child: MyText.bodyMedium(
                  "Ingresar",
                  color: theme.colorScheme.onSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ]
        )
      );
    }
  }
  Widget _miPromo() {
    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 22), // Aplica margen a toda la columna
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con ícono y título
          Row(
            children: [
              Icon(
                LucideIcons.camera, // Cambia el icono según lo que necesites
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "MI PROMO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(133, 133, 133, 1)
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
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
        ],
      ),
    );
  }
  List<Widget> _crearGaleria() {
    return ["https://upsa.focoazul.com/uploads/welcome_ae39f62406.png", "https://upsa.focoazul.com/uploads/welcome_ae39f62406.png"].map((url) {
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
            url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        ),
      );
    }).toList();
  }
  Widget _ajustes() {
    return Container(
      margin: EdgeInsets.only(top: 16.0), // Aplica margen a toda la columna
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con ícono y título
          Row(
            children: const [
              Icon(
                LucideIcons.settings, // Cambia el icono según lo que necesites
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "AJUSTES",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(133, 133, 133, 1)
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              
            },
            child: Text(
              "Desactivar notificaciones",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              
            },
            child: Text(
              "Eliminar mi cuenta",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              
            },
            child: Text(
              "Editar mis datos",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
          if(_user.estado != "Completado")
          SizedBox(height: 8),
          if(_user.estado != "Completado" && _user.estado != "Nuevo")
          GestureDetector(
            onTap: () {
              if(_user.estado == "Verificado"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroPerfil()));
              }else{
                if(_user.estado == "Perfil parte 1"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
                }else{
                  if(_user.estado == "Perfil parte 2"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
                  }
                }
              } 
            },
            child: Text(
              "Retomar formulario de admisión",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
              ),
            ), 
          ),
          if(_user.estado == "Nuevo")
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ValidarEmail(theme: theme)));
            },
            child: Text(
              "Verificar cuenta",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400
              ),
            ), 
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _mensajeTemporalInferior.mostrarMensaje(context,"Se cerró tu cuenta con exito.",Color.fromRGBO(32, 104, 14, 1), Color.fromRGBO(255, 255, 255, 1));
              loginController.logout(context);
            },
            child: Text(
              "Cerrar sesión",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _misActividades() {
    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 16), // Aplica margen a toda la columna
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con ícono y título
          Row(
            children: const [
              Icon(
                LucideIcons.trophy, // Cambia el icono según lo que necesites
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "MIS ACTIVIDADES",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(133, 133, 133, 1)
                ),
              ),
            ],
          ),
          if(_user.eventosInscritos2!.isNotEmpty)
          SizedBox(height: 8),
          if(_user.eventosInscritos2!.isNotEmpty)
          _actividadesInscritas(),
          if(_user.eventosSeguidos2!.isNotEmpty)
          SizedBox(height: 8),
          if(_user.eventosSeguidos2!.isNotEmpty)
          _actividadesSeguidas(),
        ],
      ),
    );  
  }
  Widget _actividadesSeguidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _user.eventosSeguidos2!.map((actividad) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                actividad["titulo"],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              // Subtítulo
              Text(
                "Siguiendo",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              // Texto adicional con ícono a la derecha
              InkWell(
                onTap: () {
                  if(actividad["actividad"] == "evento"){
                    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 1,)),(Route<dynamic> route) => false);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(idEvento: actividad["id"])));
                  }
                },
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.arrowRightCircle, // Cambia el ícono según lo que necesites
                      size: 20,
                      color: Color.fromRGBO(133, 133, 133, 1),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Ver actividad",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(133, 133, 133, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        );
      }).toList(),
    );
  }
  Widget _actividadesInscritas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _user.eventosInscritos2!.map((actividad) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                actividad["titulo"],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              // Subtítulo
              Text(
                "Inscrito",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              // Texto adicional con ícono a la derecha
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if(actividad["actividad"] == "evento"){
                        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 1,)),(Route<dynamic> route) => false);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(idEvento: actividad["id"])));
                      }
                    },
                    child: Row(
                      children: const [
                        Icon(
                          LucideIcons.logIn, // Cambia el ícono según lo que necesites
                          size: 20,
                          color: Color.fromRGBO(133, 133, 133, 1),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Ver ingreso",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(133, 133, 133, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }
  Widget _carreraSugerida() {
    return Container(
      margin: EdgeInsets.only(top: 32.0, bottom: 16), // Aplica margen a toda la columna
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con ícono y título
          Row(
            children: const [
              Icon(
                LucideIcons.bookMarked, // Cambia el icono según lo que necesites
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "CARRERA SUGERIDA",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(133, 133, 133, 1)
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Subtítulo
          Text(
            _userMeta.carreraSugerida!["carrera"]!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if(_userMeta.carreraSugerida!["facultad"]!.isNotEmpty)
          SizedBox(height: 8),
          if(_userMeta.carreraSugerida!["facultad"]!.isNotEmpty)
          Text(
            _userMeta.carreraSugerida!["facultad"]!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: const [
              Expanded(
                child: Text(
                  "¿Cómo te sugerimos esta carrera?",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(133, 133, 133, 1),
                  ),
                ),
              ),
              Icon(
                LucideIcons.helpCircle, // Cambia el ícono según lo que necesites
                size: 20,
                color: Color.fromRGBO(133, 133, 133, 1),
              ),
            ],
          ),
        ],
      ),
    );  
  }
  Widget _cabeceraPerfil() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(_backUrl+_userMeta.fotoPerfil!),
              fit: BoxFit.cover,
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.width * 0.25, // 25% del ancho de la pantalla
        ),
        // Espaciador
        SizedBox(width: 16),
        // Columna con el texto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyLarge(
                _userMeta.nombres! + _userMeta.apellidos!,
                fontSize: 18,
                fontWeight: 600, // Corregido de 600 a FontWeight.w600
              ),
              SizedBox(height: 8), // Espacio de 8 de alto entre los textos
              Text(
                _userMeta.promocion!["nombre"],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
