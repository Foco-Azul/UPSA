// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/avatar.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/admin/lector_qr.dart';
import 'package:flutkit/custom/screens/campus/carrera_screen.dart';
import 'package:flutkit/custom/screens/perfil/actividades_pasadas_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
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
  final int _numPages = 2;
  String _backUrl = "";
  final MensajeTemporalInferior _mensajeTemporalInferior = MensajeTemporalInferior();
  List<Avatar> _avatares = [];
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
    _backUrl = dotenv.get('backUrl');
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      if(_user.rolCustom! != "admin"){
        _user = await ApiService().getUserPopulateConMetasActividades(_user.id!);
        _userMeta = _user.userMeta!;
        _avatares = await ApiService().getAvataresPopulate(_user.id!);
      }
    }

    setState(() {
      controller.uiLoading = false;
    });
  }
  Widget _buildPageIndicatorStatic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4), // Padding interno del contenedor
          decoration: BoxDecoration(
            color: AppColorStyles.verde2, // Color de fondo del contenedor
            borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
          ),
          child: Text(
            '${_currentPage + 1}/$_numPages',
            style: AppTextStyles.etiqueta(color: AppColorStyles.blancoFondo)
          ),
        ),
      ],
    );
  }
  void _actualizarAvatar(int id, String imagen) async{
    bool bandera = await ApiService().setUserMetaAvatar(_userMeta.id!, id);
    _userMeta.avatar = imagen;
    if(bandera){
      setState(() {
        MensajeTemporalInferior().mostrarMensaje(context,"Se cambio tu avatar con exito.", "exito");
      });
    }else{
      setState(() {
        MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
      });
    }
    Navigator.pop(context);
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
  
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Cambia tu imagen de perfil por:',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 400, // Ajusta la altura según tus necesidades
                child: SingleChildScrollView(
                  child: _armarAvatares(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _armarAvatares(){
    List<Widget> avatares = _avatares.map((item) => _crearAvatar(item)).toList();
    return Wrap(
      children: avatares,
    );
  }
  Widget _crearAvatar(Avatar avatar){
     return Container(
      width: 150,
      height: 150,
      margin: EdgeInsets.all(15.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          _actualizarAvatar(avatar.id!, avatar.imagen!);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.network(
            _backUrl + avatar.imagen!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Widget _buildBody() {
    if(_isLoggedIn){
      return Scaffold(
        backgroundColor: AppColorStyles.verdeFondo,
        body: ListView(
          padding: MySpacing.fromLTRB(15, 10, 15, 15),
          children: [
            _cabeceraPerfil(),
            _carreraSugerida(),
            _misActividades(),
            //_miPromo(),
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
      padding: MySpacing.fromLTRB(15, 15, 15, 15),
      margin: MySpacing.symmetric(vertical: 15),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con ícono y título
          Row(
            children: [
              Icon(
                LucideIcons.camera, // Cambia el icono según lo que necesites
                size: 20,
                color: AppColorStyles.verde1
              ),
              SizedBox(width: 8),
              Text(
                "MI PROMO",
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
              ),
            ],
          ),
          SizedBox(height: 15),
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
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.network(
            url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        )
      );
    }).toList();
  }
  Widget _ajustes() {
    return Container(
      padding: MySpacing.fromLTRB(15, 15, 15, 15),
      margin: MySpacing.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColorStyles.blancoFondo, // Fondo blanco
        borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
        boxShadow: [
          AppSombra.tarjeta(),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con ícono y título
          Row(
            children: [
              Icon(
                LucideIcons.settings, // Cambia el icono según lo que necesites
                size: 20,
                color: AppColorStyles.verde1
              ),
              SizedBox(width: 8),
              Text(
                "AJUSTES",
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
              ),
            ],
          ),
          if(_user.rolCustom == "admin")
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child:  GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LectorQRScreen()));
              },
              child: Text(
                "Escanear QR",
                style: AppTextStyles.parrafo()
              ),
            ),
          ),
          /*
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () {
                //_user = await ApiService().setUserParaDesactivarNotificaciones(_user.id!);
              },
              child: Text(
                "Desactivar notificaciones",
                style: AppTextStyles.parrafo()
              ),
            ),
          ),
          */
          /*
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () {
                
              },
              child: Text(
                "Eliminar mi cuenta",
                style: AppTextStyles.parrafo()
              ),
            ), 
          ),
          */
          /*
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () {
                
              },
              child: Text(
                "Editar mis datos",
                style: AppTextStyles.parrafo()
              ),
            ),
          ),*/
          Visibility(
            visible: _isLoggedIn,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                onTap: () async{
                    _user = await ApiService().getUserPopulateConMetasActividades(_user.id!);
                    Provider.of<AppNotifier>(context, listen: false).setUser(_user);
                    MensajeTemporalInferior().mostrarMensaje(context,"Se sincronizó tus datos con exito.", "exito");
                    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
                },
                child: Text(
                  "Sincronizar datos",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () {
                _mensajeTemporalInferior.mostrarMensaje(context,"Se cerró tu cuenta con exito.", "exito");
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
          ),
        ],
      ),
    );
  }
  Widget _misActividades() {
    if(_user.rolCustom != "admin" && (_user.actividadesSeguidas!.isNotEmpty || _user.actividadesInscritas!.isNotEmpty)){
      return Container(
        padding: MySpacing.fromLTRB(15, 15, 15, 15),
        margin: MySpacing.symmetric(vertical: 15),
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.trophy, // Cambia el icono según lo que necesites
                  size: 20,
                  color: AppColorStyles.verde1,
                ),
                SizedBox(width: 8),
                Text(
                  "MIS ACTIVIDADES",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
                ),
              ],
            ),
            _actividadesInscritas(),
            Divider(),
            _actividadesSeguidas(),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ActividadesPasadasScreen()));
              },  
              child: Row(
                children: [
                  Icon(
                    Icons.swap_horiz_outlined, // Cambia el ícono según lo que necesites
                    size: 20,
                    color: AppColorStyles.gris2
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Ver actividades pasadas",
                    style: AppTextStyles.botonSinFondo(color: AppColorStyles.gris2)
                  ),
                ],
              )
            ),
          ],
        ),
      );  
    }else{
      return Container();
    }
  }
  Widget _actividadesSeguidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _user.actividadesSeguidas!.map((actividad) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                actividad["titulo"],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyles.oscuro1
                ),
              ),
              Text(
                "Siguiendo",
                style: AppTextStyles.parrafo(color: AppColorStyles.oscuro1),
              ),
              InkWell(
                onTap: () {
                  if(actividad["tipo"] == "evento"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: actividad["id"])));
                  }
                  if(actividad["tipo"] == "concurso"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: actividad["id"])));
                  }
                  if(actividad["tipo"] == "club"){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: actividad["id"])));
                  }
                },
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.calendar, // Cambia el ícono según lo que necesites
                      size: 20,
                      color: AppColorStyles.gris2
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Ver actividad",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColorStyles.gris2
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
      children: _user.actividadesInscritas!.map((actividad) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                actividad["titulo"],
                style: AppTitleStyles.tarjetaMenor()
              ),
              Text(
                "Inscrito",
                style: AppTextStyles.parrafo(),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if(actividad["tipo"] == "evento"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: actividad["id"])));
                      }
                      if(actividad["tipo"] == "concurso"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: actividad["id"])));
                      }
                      if(actividad["tipo"] == "club"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: actividad["id"])));
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.qrCode, // Cambia el ícono según lo que necesites
                          size: 20,
                          color: AppColorStyles.gris2
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Ver ingreso",
                          style: AppTextStyles.botonSinFondo(color: AppColorStyles.gris2)
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
    if(_user.rolCustom != "admin"){
      return Container(
        padding: MySpacing.fromLTRB(15, 15, 15, 15),
        margin: MySpacing.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColorStyles.blancoFondo, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila con ícono y título
            Row(
              children: [
                Icon(
                  LucideIcons.bookMarked, // Cambia el icono según lo que necesites
                  size: 20,
                  color: AppColorStyles.verde1,
                ),
                SizedBox(width: 8),
                Text(
                  "CARRERA SUGERIDA",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: GestureDetector(
                onTap: () {
                  if(_userMeta.carreraSugerida!["idCarreraUpsa"] > 0){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CarreraScreen(id: _userMeta.carreraSugerida!["idCarreraUpsa"]),));
                  }
                },
                child: Text(
                  _userMeta.carreraSugerida!["nombre"],
                  style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                _userMeta.carreraSugerida!["facultad"],
                style: AppTextStyles.menor()
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Divider(),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "¿Cómo te sugerimos esta carrera?",
                    style: AppTextStyles.menor()
                  ),
                ),
                Icon(
                  LucideIcons.helpCircle, // Cambia el ícono según lo que necesites
                  size: 20,
                  color: AppColorStyles.oscuro1,
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "De acuerdo a lo seleccionado en las preferencias del formulario de registro. Si aún estás indeciso/a sobre cuál estudiar, contáctanos para agendar un test vocacional en la UPSA.",
              style: AppTextStyles.menor(color: AppColorStyles.gris2)
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Divider(),
            ),
            InkWell(
              onTap: () {
                print("dasdas");
              },
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined, // Cambia el ícono según lo que necesites
                    size: 20,
                    color: AppColorStyles.gris2,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Agendar test vocacional",
                    style: AppTextStyles.botonSinFondo(color: AppColorStyles.gris2)
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                if(_user.estado == "Nuevo"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ValidarEmail()));
                }
                if(_user.estado == "Verificado"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroPerfil()));
                }
                if(_user.estado == "Perfil parte 1" || _user.estado == "Completado"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
                }
                if(_user.estado == "Perfil parte 2"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
                } 
              },
              child: Row(
                children: [
                  Icon(
                    Icons.feed_outlined, // Cambia el ícono según lo que necesites
                    size: 20,
                    color: AppColorStyles.gris2,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Retomar formulario de preferencias",
                    style: AppTextStyles.botonSinFondo(color: AppColorStyles.gris2)
                  ),
                ],
              ),
            ),
          ],
        ),
      );  
    }else{
      return Container();
    }
  }
  Widget _cabeceraPerfil() {
    if(_user.rolCustom != "admin"){
      return Row(
        children: [
        Stack(
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                      _backUrl + _userMeta.avatar!,
                      fit: BoxFit.cover,
                    ),
                ),
              ),
              // Icono de lápiz para cambiar la imagen
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _showImagePicker(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColorStyles.blancoFondo,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColorStyles.verde1,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_userMeta.nombres!} ${_userMeta.apellidos!}', 
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorStyles.oscuro1
                  ),
                ),
                if(_userMeta.colegio!.nombre != null)
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    'Colegio ${_userMeta.colegio!.nombre}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColorStyles.gris1
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }else{
      return Container();
    }
  }
}