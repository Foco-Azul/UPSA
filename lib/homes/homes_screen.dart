import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/actividades_inicio.dart';
import 'package:flutkit/custom/screens/actividades/calenadrio_screen.dart';
import 'package:flutkit/custom/screens/bienvenida/bienvenida_screen.dart';
import 'package:flutkit/custom/screens/bienvenida/postbienvenida_screen.dart';
import 'package:flutkit/custom/screens/campus/campus_inicio.dart';
import 'package:flutkit/custom/screens/inicio/inicio_screen.dart';
import 'package:flutkit/custom/screens/noticias/noticias_inicio.dart';
import 'package:flutkit/custom/screens/perfil/perfil_screen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/homes/app_setting_screen.dart';
import 'package:flutkit/images.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomesScreen extends StatefulWidget {
  final int indice;
  HomesScreen({Key? key, this.indice = 0}) : super(key: key);
  
  @override
  _HomesScreenState createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  final List<Widget> bottomBarPages = [
    InicioScreen(),
    ActividadesScreen(),
    CampusScreen(),
    NoticiasScreen(),
    PerfilScreen(),
  ];

  late ThemeData theme;
  late CustomTheme customTheme;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool _isLoggedIn = false;
  User? _user = User();

  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.indice;
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
  }
  void _actualizarDatosUser() async{
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user = await ApiService().getUserForId(_user!.id!);
      Provider.of<AppNotifier>(context, listen: false).setUser(_user!);
      MensajeTemporalInferior().mostrarMensaje(context,"Se sincronizó tus datos con exito.",Color.fromRGBO(32, 104, 14, 1), Color.fromRGBO(255, 255, 255, 1));
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
    }else{
      MensajeTemporalInferior().mostrarMensaje(context,"Inicia sesión para sincronizar tus datos.",Color.fromRGBO(255, 0, 0, 1), Color.fromRGBO(255, 255, 255, 1));
    }
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
            backgroundColor: Color.fromRGBO(244, 251, 249, 1),
            key: _drawerKey,
            //drawer: _buildDrawer(),
            // backgroundColor: Colors.black,
            appBar: _buildAppBarContent(selectedIndex, theme),
            body: bottomBarPages[selectedIndex],
            bottomNavigationBar: FlashyTabBar(
              iconSize: 20,
              backgroundColor: theme.colorScheme.background,
              selectedIndex: selectedIndex,
              animationDuration: Duration(milliseconds: 500),
              showElevation: true,
              items: [
                FlashyTabBarItem(
                  inactiveColor: Color.fromRGBO(5, 50, 12, 1),
                  activeColor: Color.fromRGBO(5, 50, 12, 1),
                  icon: Icon(LucideIcons.home),
                  title: Text(
                    'Inicio',
                  ),
                ),
                FlashyTabBarItem(
                  inactiveColor: Color.fromRGBO(5, 50, 12, 1),
                  activeColor: Color.fromRGBO(5, 50, 12, 1),
                  icon: Icon(LucideIcons.trophy),
                  title: Text(
                    'Actividades',
                    style: TextStyle(
                      fontSize: 11.1,
                    )
                  ),
                ),
                FlashyTabBarItem(
                  inactiveColor: Color.fromRGBO(5, 50, 12, 1),
                  activeColor: Color.fromRGBO(5, 50, 12, 1),
                  icon: Icon(LucideIcons.bookOpen),
                  title: Text(
                    'Campus',
                  ),
                ),
                FlashyTabBarItem(
                  inactiveColor: Color.fromRGBO(5, 50, 12, 1),
                  activeColor: Color.fromRGBO(5, 50, 12, 1),
                  icon: Icon(LucideIcons.pin),
                  title: Text(
                    'Noticias',
                  ),
                ),
                FlashyTabBarItem(
                  inactiveColor: Color.fromRGBO(5, 50, 12, 1),
                  activeColor: Color.fromRGBO(5, 50, 12, 1),
                  icon: Icon(LucideIcons.user),
                  title: Text(
                    'Mi perfil',
                  ),
                ),
              ],
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
  PreferredSizeWidget? _buildAppBarContent(int selectedIndex, ThemeData theme) {
  switch (selectedIndex) {
    case 0:
      return AppBar(
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => CalendarioScreen()),);
            },
            child: Container(
              padding: MySpacing.x(20),
              child: Image(
                image: AssetImage(Images.calendarIcon),
                color: theme.colorScheme.onBackground,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      );
    case 1:
      return AppBar(
        title: Text('Actividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => CalendarioScreen()),);
            },
            child: Container(
              padding: MySpacing.x(20),
              child: Image(
                image: AssetImage(Images.calendarIcon),
                color: theme.colorScheme.onBackground,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      );
    case 2:
      return AppBar(
        title: Text('Campus'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppSettingScreen()),
              );
            },
            child: Container(
              padding: MySpacing.x(20),
              child: Image(
                image: AssetImage(Images.settingIcon),
                color: theme.colorScheme.onBackground,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      );
    case 3:
      return AppBar(
        title: Text('Noticias'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppSettingScreen()),
              );
            },
            child: Container(
              padding: MySpacing.x(20),
              child: Image(
                image: AssetImage(Images.settingIcon),
                color: theme.colorScheme.onBackground,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      );
    case 4:
      return AppBar(
        title: Text('Mi perfil'),
        centerTitle: true,
        actions: [
            IconButton(
              icon: Icon(LucideIcons.refreshCcw),
              onPressed: () {
                _actualizarDatosUser();
              },
            ),
        ],
      );
    default:
      return AppBar(
        title: Text('Otro título'),
        // Otros elementos de la AppBar por defecto
      );
    }
  }
}
