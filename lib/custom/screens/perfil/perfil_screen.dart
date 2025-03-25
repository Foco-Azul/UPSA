// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/register_screen.dart';
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
import 'package:flutkit/custom/screens/campus/sobre_nosotros_escreen.dart';
import 'package:flutkit/custom/screens/campus/test_vocacional_screen.dart';
import 'package:flutkit/custom/screens/perfil/actividades_pasadas_screen.dart';
import 'package:flutkit/custom/screens/perfil/retroalimentacion_nibu_screem.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/foto_full_screen.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


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
  String _backUrl = "";
  final MensajeTemporalInferior _mensajeTemporalInferior = MensajeTemporalInferior();
  List<Avatar> _avatares = [];
  late SharedPreferences _prefs;
  late AnimacionCarga _animacionCarga;
  
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    loginController = LoginController();
    controller = ProfileController();
    _animacionCarga = AnimacionCarga(context: context);
    _cargarDatos();
  }

  void _cargarDatos() async{
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Perfil',
      screenClass: 'Perfil', // Clase o tipo de pantalla
    );
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user = await ApiService().getUserPopulateConMetasActividades(_user.id!);
      _userMeta = _user.userMeta!;
      _avatares = await ApiService().getAvataresPopulate(_user.id!);
    }

    setState(() {
      controller.uiLoading = false;
    });
  }
  Widget _buildPageIndicatorStatic() {
    int numPages = _userMeta.colegio!.imagenes!.length;
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
            '${_currentPage + 1}/$numPages',
            style: AppTextStyles.etiqueta(color: AppColorStyles.blanco)
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
        MensajeTemporalInferior().mostrarMensaje(context,"Se cambio tu avatar con éxito.", "exito");
      });
    }else{
      setState(() {
        MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
      });
    }
    Navigator.pop(context);
  }
  void _cerrarSesion(String mensaje) async{
    _animacionCarga.setMostrar(true);
    _prefs = await SharedPreferences.getInstance();
    String tokenDispositivo = _prefs.getString('tokenDispositivo') ?? "";
    if(_user.dispositivos!.contains(tokenDispositivo)){
      _user.dispositivos!.remove(tokenDispositivo);
      await ApiService().actualizarUsuarioTokens(_user.id!, _user.dispositivos!);
    }
    await _prefs.setStringList('notificaciones', []);
    _mensajeTemporalInferior.mostrarMensaje(context, mensaje, "exito");
    loginController.logout(context);
    _animacionCarga.setMostrar(false);
  }
  void _eliminarCuenta() async{
    _animacionCarga.setMostrar(true);
    bool aux = await ApiService().eliminarCuenta(_user.email!, _user.id!);
    _animacionCarga.setMostrar(false);
    if(aux){
      _cerrarSesion('Se eliminó tu cuenta con éxito.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getCouponLoadingScreen(
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
        backgroundColor: AppColorStyles.altFondo1,
        body: ListView(
          padding: MySpacing.fromLTRB(15, 10, 15, 15),
          children: [
            _cabeceraPerfil(),
            _carreraSugerida(),
            _crearInsignias(),
            _misActividades(),
            _miPromo(),
            _ajustes(),
          ],
        ),
      );
    }else{
      return Scaffold(
        body: Stack(
          children: <Widget>[
            _crearImagen(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _crearContenedorPostBienvenida(),
              ],
            ),
          ],
        ),
      );

    }
  }

  Widget _crearContenedorPostBienvenida(){
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          //height: 200,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColorStyles.altTexto1, // Establece el color de fondo
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Hace que el Column se adapte al tamaño de su contenido
            children: [
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                child: Icon(
                  Icons.rocket, // Icono que deseas mostrar
                  color: AppColorStyles.blanco, // Color del icono
                  size: 50 // Tamaño del icono
                ),
              ),
              Text(
                'Despegando',
                style: AppTitleStyles.onboarding(color: AppColorStyles.blanco),
              ),
              SizedBox(height: 15,),
              Text(
                'Iniciá tu vida universitaria junto a la UPSA.',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColorStyles.blanco),
                textAlign: TextAlign.center,
              ),
              _crearBoton("Registrar mi cuenta", "signup", AppColorStyles.oscuro1, AppColorStyles.altVerde1),
              _crearBoton("Iniciar sesión", "login",AppColorStyles.oscuro1, AppColorStyles.altFondo1),
              Container(
                margin: MySpacing.only(top: (MediaQuery.of(context).size.height) * 0.03, bottom: 15, left: 60, right: 60),
                child: Text.rich(
                  TextSpan(
                    text: 'Al registrar tu cuenta, aceptás nuestros ',
                    style: TextStyle(fontWeight: FontWeight.normal, height: 1.3, fontSize: 10, color: AppColorStyles.blanco),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Términos de uso',
                        style: TextStyle(decoration: TextDecoration.underline, decorationColor: AppColorStyles.blanco,  decorationThickness: 2),
                        recognizer: TapGestureRecognizer()
                        ..onTap = () async{
                          if (!await launchUrl(
                            Uri.parse("https://www.upsa.edu.bo/es/nibu-terminos-y-condiciones"),
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw Exception('Could not launch https://www.upsa.edu.bo/es/nibu-terminos-y-condiciones');
                          }
                        },
                      ),
                      TextSpan( 
                        text: ' y ',
                      ),
                      TextSpan(
                        text: 'Políticas de privacidad',
                        style: TextStyle(decoration: TextDecoration.underline, decorationColor: AppColorStyles.blanco, decorationThickness: 2),
                        recognizer: TapGestureRecognizer()
                        ..onTap = () async{
                          if (!await launchUrl(
                            Uri.parse("https://www.upsa.edu.bo/es/politica-de-privacidad"),
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw Exception('Could not launch https://www.upsa.edu.bo/es/politica-de-privacidad');
                          }
                        },
                      ),
                      TextSpan(
                        text: '.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _crearBoton(String texto, String tipo, Color colorTexto, Color colorFondo){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 15),
      child: ElevatedButton(
        onPressed: () {
          if(tipo == "login"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Login2Screen()));
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => Register2Screen()));
          }
        },
        style: AppDecorationStyle.botonBienvenida(colorFondo: colorFondo),
        child: Text(
          texto,
          style: AppTextStyles.botonMayor(color: colorTexto), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearImagen(){
    return Positioned.fill(
      child: Opacity(
        opacity: 0.5, // Nivel de opacidad
        child: Image.asset(
          'lib/custom/assets/images/bienvenida_1.png',
          fit: BoxFit.cover, // La imagen cubrirá todo el espacio
        ),
      ),
    );
  }
  Widget _crearInsignias(){
    if(_user.rolCustom == "estudiante" && _userMeta.insignias!.isNotEmpty){
      /*
      for(int i = 0; i<10; i++){
        _userMeta.insignias!.add(_userMeta.insignias![0]);
      }
      */
      return Container(
        padding: MySpacing.fromLTRB(15, 15, 15, 15),
        margin: MySpacing.symmetric(vertical: 15),
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
            Row(
              children: [
                Icon(
                  Icons.badge_outlined, // Cambia el icono según lo que necesites
                  size: 20,
                  color: AppColorStyles.altTexto1
                ),
                SizedBox(width: 8),
                Text(
                  "MIS INSIGNIAS",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _userMeta.insignias!.map((insignia) {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 4.0, left: 4, top: 15, bottom: 5),
                        child: SizedBox(
                          width: 75,
                          height: 75,
                          child: InkWell(
                            onTap: () {
                              _mostrarInsignia(insignia);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                _backUrl + insignia["imagen"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        insignia["nombreCorto"],
                        style: AppTextStyles.etiqueta(color: AppColorStyles.gris2),
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
          ]
        )
      );
    }else{
      return Container();
    }
  }
  void _mostrarInsignia(Map<String, dynamic> data) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColorCustom.color(nombre: data["colorFondo"]),
          insetPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Quita el borderRadius
          child: Container(
            padding: EdgeInsets.all(15),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      _backUrl + data["imagen"]!,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20), // Espacio entre la imagen y el primer texto
                    Text(
                      data["nombre"]!, // Asumiendo que hay un campo "titulo" en los datos
                      style: AppTitleStyles.tarjeta(color: AppColorStyles.blanco)
                    ),
                    SizedBox(height: 10), // Espacio entre el primer y segundo texto
                    Text(
                      data["mensaje"]!, // Asumiendo que hay un campo "descripcion" en los datos
                      style: AppTextStyles.parrafo(color: AppColorStyles.blanco),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Positioned(
                  top: 40.0,
                  right: 20.0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: AppColorStyles.blanco, size: 30),
                    onPressed: () {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              Expanded(
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
  Widget _miPromo() {
    if(_user.rolCustom == "estudiante" && _userMeta.colegio!.imagenes != null && _userMeta.colegio!.imagenes!.isNotEmpty){
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
                  color: AppColorStyles.altTexto1
                ),
                SizedBox(width: 8),
                Text(
                  "MI PROMO",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
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
                  bottom: 24,
                  left: 8, // Añade esta línea para alinear a la izquierda
                  child: _buildPageIndicatorStatic(),
                ),
              ],
            ),
          ],
        ),
      );
    }else{
      return Container();
    }
  }
  List<Widget> _crearGaleria() {
    return _userMeta.colegio!.imagenes!.map((url) {
      return Stack(
        children: [
          Container(
            width: double.infinity, // Asegura que el contenedor ocupe todo el ancho disponible
            decoration: AppDecorationStyle.tarjeta(),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                _backUrl+url,
                height: 240.0,
                width: double.infinity, // Asegura que la imagen ocupe todo el ancho disponible
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 24, // Ajusta la posición del ícono según tu preferencia
            right: 8,
            child: GestureDetector(
              onTap: () {
                // Acción al pulsar el ícono
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(imageUrl: _backUrl+url,),
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
  Widget _ajustes() {
    return Container(
      padding: MySpacing.fromLTRB(15, 15, 15, 15),
      margin: MySpacing.symmetric(vertical: 15),
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
          // Fila con ícono y título
          Row(
            children: [
              Icon(
                LucideIcons.settings, // Cambia el icono según lo que necesites
                size: 20,
                color: AppColorStyles.altTexto1
              ),
              SizedBox(width: 8),
              Text(
                "AJUSTES",
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
              ),
            ],
          ),
          SizedBox(height: 10,),
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child:  GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RetroalimentacionNibuScreen()));
              },
              child: Text(
                "Retroalimentación de NIBU",
                style: AppTextStyles.parrafo()
              ),
            ),
          ),
          /*
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () async {
                if(_user.notificacionesHabilitadas!){
                  await ApiService().setUserParaDesactivarNotificaciones(_user.id!, false);
                  MensajeTemporalInferior().mostrarMensaje(context,"Se desactivo las notificaciones con exito.", "exito");
                  setState(() {
                    _user.notificacionesHabilitadas = false;
                  });
                }else{
                  await ApiService().setUserParaDesactivarNotificaciones(_user.id!, true);
                  MensajeTemporalInferior().mostrarMensaje(context,"Se activo las notificaciones con exito.", "exito");
                  setState(() {
                    _user.notificacionesHabilitadas = true;
                  });
                }
              },
              child: Text(
                _user.notificacionesHabilitadas! ? "Desactivar notificaciones" : "Activar notificaciones",
                style: AppTextStyles.parrafo()
              ),
            ),
          ),
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
          ),
          Visibility(
            visible: _isLoggedIn,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                onTap: () async{
                  _animacionCarga.setMostrar(true);
                  _user = await ApiService().getUserPopulateConMetasActividades(_user.id!);
                  Provider.of<AppNotifier>(context, listen: false).setUser(_user);
                  MensajeTemporalInferior().mostrarMensaje(context,"Se sincronizó tus datos con éxito.", "exito");
                  Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
                  _animacionCarga.setMostrar(false);
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
          ),*/
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () {
                _popupEliminarCuenta();
              },
              child: Text(
                "Eliminar cuenta",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: (){
                _cerrarSesion('Se cerró tu cuenta con éxito.');
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
  _popupEliminarCuenta(){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Estás seguro?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Al eliminar tu cuenta, sucederá lo siguiente:'),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text('Perderás todos tus datos'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text('No podrás recuperar tus datos'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text('Al crear otra cuenta con el mismo correo, esta sera una cuenta nueva'),
              ),
              // Puedes agregar más ítems a la lista si es necesario
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            ElevatedButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _eliminarCuenta();
              },
            ),
          ],
        );
      },
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
                  color: AppColorStyles.altTexto1,
                ),
                SizedBox(width: 8),
                Text(
                  "MIS ACTIVIDADES",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
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
                    "Ver todas mis actividades",
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
          color: AppColorStyles.blanco, // Fondo blanco
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
                  color: AppColorStyles.altTexto1,
                ),
                SizedBox(width: 8),
                Text(
                  "CARRERA SUGERIDA",
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
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
                  style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1),
                ),
              ),
            ),
            if((_user.estado == "Perfil parte 2" || _user.estado == "Completado") && _userMeta.carreraSugerida!["nombre"] == "Ninguna")
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                "Estamos analizando tus respuestas para sugerirte una carrera.",
                style: AppTextStyles.menor(color: AppColorStyles.gris2)
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
              "Lo hacemos a partir de los datos ingresados en tu formulario de registro. Si aún estás indeciso/a sobre cuál estudiar, contactanos para agendar un test vocacional en la UPSA.",
              style: AppTextStyles.menor(color: AppColorStyles.gris2)
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Divider(),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TestVocacionalScreen()));
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
                      color: AppColorStyles.blanco,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColorStyles.altTexto1,
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