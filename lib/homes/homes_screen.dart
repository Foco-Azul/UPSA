
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/configuracion.dart';
import 'package:flutkit/custom/models/resultado.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/actividades_inicio.dart';
import 'package:flutkit/custom/screens/actividades/calendario_screen.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/actividades/quiz_screen.dart';
import 'package:flutkit/custom/screens/bienvenida/bienvenida_screen.dart';
import 'package:flutkit/custom/screens/campus/campus_inicio.dart';
import 'package:flutkit/custom/screens/campus/carrera_screen.dart';
import 'package:flutkit/custom/screens/campus/cursillo_screen.dart';
import 'package:flutkit/custom/screens/campus/matriculate_screem.dart';
import 'package:flutkit/custom/screens/inicio/actualizacion_screen.dart';
import 'package:flutkit/custom/screens/inicio/inicio_screen.dart';
import 'package:flutkit/custom/screens/inicio/notificaciones_screen.dart';
import 'package:flutkit/custom/screens/inicio/sin_internet.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/screens/noticias/noticias_inicio.dart';
import 'package:flutkit/custom/screens/perfil/perfil_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomesScreen extends StatefulWidget {
  final int indice;
  HomesScreen({Key? key, this.indice = 0}) : super(key: key);
  
  @override
  _HomesScreenState createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  List<Widget> bottomBarPages = [
    InicioScreen(),
    ActividadesScreen(),
    CampusScreen(),
    NoticiasScreen(),
    PerfilScreen(),
  ];
  late ThemeData theme;
  late CustomTheme customTheme;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  final TextEditingController _searchController = TextEditingController();
  bool _showPopup = false;
  List<Resultado> _resultados = [];
  bool _buscando =  false;
  User _user = User();
  bool _isLoggedIn = false;
  late ProfileController controller;
  Configuracion _configuracion = Configuracion();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.indice;
    controller = ProfileController();
    _cargarDatos();
  }

  void _cargarDatos() async{
    setState(() {
      controller.uiLoading = true;
    });
    _configuracion = await ApiService().getConfiguracion();
    if(_configuracion.version! != "-1"){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String version = prefs.getString('version') ?? "";
      String versionIos = prefs.getString('versionIos') ?? "";
      AppInfoData info = await AppInfoData.get(); 
      if(info.platform.isAndroid){
        if (_configuracion.version!.isNotEmpty && _configuracion.version!.split('+')[0][0] != info.package.version.major.toString()) {
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => ActualizacionScreen(isAndroid: info.platform.isAndroid, android: _configuracion.android!, ios: _configuracion.ios!, novedades: _configuracion.novedades!)),(Route<dynamic> route) => false);
        }
        await prefs.setString('version', info.package.version.toString());
        if(version.isEmpty){
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => WelcomeScreen()),(Route<dynamic> route) => false);
        }else{
          if(version.split('+')[0][0] != info.package.version.major.toString()){
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => WelcomeScreen()),(Route<dynamic> route) => false);
          }
        }
      }else{
        if (_configuracion.versionIos!.isNotEmpty && _configuracion.versionIos!.split('+')[0][0] != info.package.version.major.toString()) {
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => ActualizacionScreen(isAndroid: info.platform.isAndroid, android: _configuracion.android!, ios: _configuracion.ios!, novedades: _configuracion.novedadesIos!)),(Route<dynamic> route) => false);
        }
        await prefs.setString('versionIos', info.package.version.toString());
        if(versionIos.isEmpty){
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => WelcomeScreen()),(Route<dynamic> route) => false);
        }else{
          if(versionIos.split('+')[0][0] != info.package.version.major.toString()){
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => WelcomeScreen()),(Route<dynamic> route) => false);
          }
        }
      }
      _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
      if (_isLoggedIn) {
        _user = Provider.of<AppNotifier>(context, listen: false).user;
        _user = await ApiService().getUser(_user.id!);
      }
    }else{
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SinInternetScreen()),(Route<dynamic> route) => false);
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _filtrarContenidos(int id){
    List<Resultado> aux = [];
    for (var item in _resultados) {
      if(item.usuariosPermitidos != ";-1;"){
        if(item.usuariosPermitidos!.contains(';$id;')){
          aux.add(item);
        }
      }else{
        aux.add(item);
      }
    }
    _resultados = aux;
  }  

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getOrderLoadingScreen(
            context,
          ),
        ),
      );
    } else {
      return Consumer<AppNotifier>(
        builder: (context, value, child) {
          isDark = AppTheme.themeType == ThemeType.dark;
          textDirection = AppTheme.textDirection;
          theme = AppTheme.theme;
          customTheme = AppTheme.customTheme;
          return Theme(
            data: theme,
            child: Scaffold(
              backgroundColor: AppColorStyles.altFondo1,
              key: _drawerKey,
              appBar: _buildAppBarContent(selectedIndex),
              body: Stack(
                children: [
                  bottomBarPages[selectedIndex],
                  _crearPopupBusquedas(),
                ],
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(_isLoggedIn && _user.rolCustom! != "admin" && _user.estado != "Completado")
                  GestureDetector(
                    onTap: () {
                      if(_user.estado == "Nuevo"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ValidarEmail()));
                      }
                      if(_user.estado == "Verificado"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroPerfil()));
                      }
                      if(_user.estado == "Perfil parte 1"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
                      }
                      if(_user.estado == "Perfil parte 2"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
                      } 
                    },
                    child: Container(
                      width: double.infinity,
                      color: AppColorStyles.altVerde2,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Completa tu perfil para inscribirte a actividades →'.toUpperCase(),
                        style: AppTextStyles.etiqueta(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  FlashyTabBar(
                    iconSize: 24,
                    backgroundColor: AppColorStyles.blanco,
                    selectedIndex: selectedIndex,
                    animationDuration: Duration(milliseconds: 500),
                    showElevation: true,
                    items: [
                      FlashyTabBarItem(
                        inactiveColor: AppColorStyles.altTexto1,
                        activeColor: AppColorStyles.altTexto1,
                        icon: Icon(Icons.home_sharp),
                        title: Text('Inicio', style: AppTextStyles.bottomMenu()),
                      ),
                      FlashyTabBarItem(
                        inactiveColor: AppColorStyles.altTexto1,
                        activeColor: AppColorStyles.altTexto1,
                        icon: Icon(Icons.emoji_events_sharp),
                        title: Text('Actividades', style: AppTextStyles.bottomMenu()),
                      ),
                      FlashyTabBarItem(
                        inactiveColor: AppColorStyles.altTexto1,
                        activeColor: AppColorStyles.altTexto1,
                        icon: Icon(Icons.local_library_sharp),
                        title: Text('Campus', style: AppTextStyles.bottomMenu()),
                      ),
                      FlashyTabBarItem(
                        inactiveColor: AppColorStyles.altTexto1,
                        activeColor: AppColorStyles.altTexto1,
                        icon: Icon(Icons.push_pin_sharp),
                        title: Text('Noticias', style: AppTextStyles.bottomMenu()),
                      ),
                      FlashyTabBarItem(
                        inactiveColor: AppColorStyles.altTexto1,
                        activeColor: AppColorStyles.altTexto1,
                        icon: Icon(Icons.account_circle_sharp),
                        title: Text('Mi perfil', style: AppTextStyles.bottomMenu()),
                      ),
                    ],
                    onItemSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                        _searchController.clear();
                        _showPopup = false;
                        _buscando = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
  Widget _crearPopupBusquedas(){
    return Visibility(
      visible: _showPopup,
      child: Dialog(
        insetPadding: EdgeInsets.zero, // Ocupa toda la pantalla
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColorStyles.altFondo1,
          child: ListView(
            children: [
              if (_buscando)
              Container(
                margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
                child: LoadingEffect.getSearchLoadingScreen(
                  context,
                ),
              ),
              _crearListaTarjetas(),
              Visibility(
                visible: _resultados.isEmpty,
                child: Container (
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  child: Text (
                    "Sin resultados",
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris2)
                  )
                )
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _crearListaTarjetas() {
    List<Widget> tarjetas = _resultados.map((item) => _crearTarjeta(item)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
      children: tarjetas,
    );
  }
  Widget _navegacion(String tipo) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alinea los elementos del Row al centro
        children: [
          MyText(
            tipo.toUpperCase(),
            style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
          ),
        ],
      ),
    );
  }
  Widget _crearTarjeta(Resultado item) {
    return GestureDetector(
      onTap: () {
        if(item.tipo == "evento"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: item.idContenido!,)));
        }
        if(item.tipo == "concurso"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: item.idContenido!,)));
        }        
        if(item.tipo == "club"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: item.idContenido!,)));
        }        
        if(item.tipo == "quiz"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(id: item.idContenido!,)));
        }
        if(item.tipo == "noticia"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: item.idContenido!,)));
        }
        if(item.tipo == "cursillo"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => CursilloScreen(id: item.idContenido!,)));
        }
        if(item.tipo == "carrera"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => CarreraScreen(id: item.idContenido!,)));
        }
        if(item.tipo == "matriculate"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => MatriculateScreen()));
        }

      },
      child: Container(
        margin: EdgeInsets.all(15), // Añadir margen superior si es necesario
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColorStyles.blanco, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          children: [
            _navegacion(item.palabrasClaves!),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item.titulo!,
                style: AppTitleStyles.tarjeta()
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item.descripcion!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.parrafo(),
              ),
            )
          ],
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBarContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          actions: [
            SizedBox(
              width: 40.0,
              child: Image.asset(
                'lib/custom/assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Container (
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: AppDecorationStyle.tarjeta(borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.search, size: 30, color: AppColorStyles.gris2),
                    SizedBox(width: 15,),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar',
                          border: InputBorder.none,
                          labelStyle: AppTitleStyles.subtitulo(color: AppColorStyles.gris2),
                        ),
                        onChanged: (query) async {
                          if(query.length > 2){
                            setState(() {
                              _buscando = true;
                            }); 
                            _resultados = await ApiService().getBusquedas(query);
                            _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
                            if (_isLoggedIn) {
                              _user = Provider.of<AppNotifier>(context, listen: false).user;
                              if(_user.rolCustom! == "estudiante"){
                                _filtrarContenidos(_user.id!);
                              }
                            }else{
                              _filtrarContenidos(-1);
                            }
                            setState(() {
                              _showPopup = true; // Alterna la visibilidad del popup
                              _buscando = false;
                            });
                          }
                        },
                      ),
                    ),
                    if (_showPopup)
                    IconButton(
                      icon: Icon(Icons.close, size: 30, color: AppColorStyles.gris2),
                      onPressed: () {
                        setState(() {
                          _showPopup = false;
                          _searchController.clear(); // Limpia el campo de búsqueda
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.today, size: 30, color: AppColorStyles.altTexto1,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarioScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_none_outlined, size: 30, color: AppColorStyles.altTexto1,),
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => NotificacionesScreen()),);
              },
            ),
          ],
        );
      case 1:
        return AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          title: Text('Actividades', style: AppTitleStyles.principal()),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.today, size: 30),
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => CalendarioScreen()),);
              },
            ),
          ],
        );
      case 2:
        return AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          title: Text('Campus', style: AppTitleStyles.principal()),
          centerTitle: true,
        );
      case 3:
        return AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          title: Text('Noticias', style: AppTitleStyles.principal()),
          centerTitle: true,
        );
      case 4:
        return AppBar(
          backgroundColor: AppColorStyles.altFondo1,
          title: Text('Mi perfil', style: AppTitleStyles.principal()),
          centerTitle: true,
        );
      default:
        return AppBar(
          title: Text('', style: AppTitleStyles.principal()),
          // Otros elementos de la AppBar por defecto
        );
    }
  }
}
