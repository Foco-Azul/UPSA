import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/screens/actividades/actividades_inicio.dart';
import 'package:flutkit/custom/screens/campus/campus_inicio.dart';
import 'package:flutkit/custom/screens/inicio/inicio_screen.dart';
import 'package:flutkit/custom/screens/noticias/noticias_inicio.dart';
import 'package:flutkit/custom/screens/perfil/perfil_screen.dart';
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

  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.indice;
  }
  void changeDirection() {
    if (AppTheme.textDirection == TextDirection.ltr) {
      Provider.of<AppNotifier>(context, listen: false)
          .changeDirectionality(TextDirection.rtl);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .changeDirectionality(TextDirection.ltr);
    }
    setState(() {});
  }

  void changeTheme() {
    if (AppTheme.themeType == ThemeType.light) {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.dark);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.light);
    }
    setState(() {});
  }

  void launchCodecanyonURL() async {
    String url = "https://codecanyon.net/item/flutkit-flutter-ui-kit/27510289";
    await launchUrl(Uri.parse(url));
  }

  void launchDocumentation() async {
    String url = "https://flutkit.coderthemes.com/index.html";
    await launchUrl(Uri.parse(url));
  }

  void launchChangeLog() async {
    String url = "https://flutkit.coderthemes.com/changelogs.html";
    await launchUrl(Uri.parse(url));
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
                  icon: Icon(LucideIcons.home),
                  title: Text(
                    'Inicio',
                  ),
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary,
                ),
                FlashyTabBarItem(
                  icon: Icon(LucideIcons.trophy),
                  title: Text(
                    'Actividades',
                    style: TextStyle(
                      fontSize: 11.1,
                    )
                  ),
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary,
                ),
                FlashyTabBarItem(
                  icon: Icon(LucideIcons.bookOpen),
                  title: Text(
                    'Campus',
                  ),
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary,
                ),
                FlashyTabBarItem(
                  icon: Icon(LucideIcons.pin),
                  title: Text(
                    'Noticias',
                  ),
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary,
                ),
                FlashyTabBarItem(
                  icon: Icon(LucideIcons.user),
                  title: Text(
                    'Mi perfil',
                  ),
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary,
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
        title: Text('Inicio'),
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
    case 1:
      return AppBar(
        title: Text('Actividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
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
        title: Text('Perfil'),
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
    default:
      return AppBar(
        title: Text('Otro título'),
        // Otros elementos de la AppBar por defecto
      );
    }
  }
}
