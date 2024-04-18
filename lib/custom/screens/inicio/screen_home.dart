import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:upsa/custom/screens/actividades/screen_actividades.dart';
import 'package:upsa/custom/screens/campus/screen_campus.dart';
import 'package:upsa/custom/screens/inicio/screen_inicio.dart';
import 'package:upsa/custom/screens/noticias/screen_noticias.dart';
import 'package:upsa/custom/screens/perfil/app_setting_screen.dart';
import 'package:upsa/custom/screens/perfil/profile_screen.dart';
import 'package:upsa/custom/widgets/appBar.dart';
import 'package:upsa/custom/widgets/bottomNavigationBar.dart';
import 'package:upsa/custom/widgets/select_language_dialog.dart';
import 'package:upsa/helpers/extensions/extensions.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/theme/theme_type.dart';
import 'package:upsa/helpers/widgets/my_container.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:upsa/images.dart';

class HomesScreen extends StatefulWidget {
  HomesScreen({Key? key}) : super(key: key);
  static const namedRoute = "home-screen";

  @override
  _HomesScreenState createState() => _HomesScreenState();
}


class _HomesScreenState extends State<HomesScreen> with SingleTickerProviderStateMixin {

  int selectedIndex = 0;
  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  late ThemeData theme;
  late CustomTheme customTheme;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();

    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
  }
  void changeTheme() {
    print(Provider.of<AppNotifier>(context, listen: false).count);
    Provider.of<AppNotifier>(context, listen: false).incrementCount();
    if (AppTheme.themeType == ThemeType.light) {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.dark);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.light);
    }
    setState(() {});
  }
  void changeDirection() {
    Provider.of<AppNotifier>(context, listen: false).limpiarValores();
    if (AppTheme.textDirection == TextDirection.ltr) {
      Provider.of<AppNotifier>(context, listen: false)
          .changeDirectionality(TextDirection.rtl);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .changeDirectionality(TextDirection.ltr);
    }
    setState(() {});
  }
  
  final List<Widget> bottomBarPages = [
    Inicio(),
    Actividades(),
    Campus(),
    Noticias(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    String contador = (Provider.of<AppNotifier>(context, listen: false).count).toString();
    String logueado = (Provider.of<AppNotifier>(context, listen: false).isLoggedIn).toString();
    bool isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    String nombre = (Provider.of<AppNotifier>(context, listen: false).user).toString();
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
            drawer: _buildDrawer(),
            appBar: CustomAppBar(
              isLoggedIn: isLoggedIn,
              pantalla: selectedIndex,
              onProfileTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              onSettingsTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppSettingScreen()));
              },
            ),
            body: bottomBarPages[selectedIndex],
            bottomNavigationBar: CustomBottomNavigationBar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                print(selectedIndex);
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          )
        );
      }
    );
  }
Widget _buildDrawer() {
    return MyContainer.none(
      margin:
          MySpacing.fromLTRB(16, MySpacing.safeAreaTop(context) + 16, 16, 16),
      borderRadiusAll: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: theme.scaffoldBackgroundColor,
      child: Drawer(
          child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: MySpacing.only(left: 20, bottom: 0, top: 24, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(Images.brandLogo),
                    height: 102,
                    width: 102,
                  ),
                  MySpacing.height(16),
                  MyContainer(
                    padding: MySpacing.fromLTRB(12, 4, 12, 4),
                    borderRadiusAll: 4,
                    color: theme.colorScheme.primary.withAlpha(40),
                    child: MyText.bodyLarge("v15",
                        color: theme.colorScheme.primary,
                        fontWeight: 700,
                        letterSpacing: 0.2),
                  ),
                  MySpacing.height(16),
                  MyText.bodyMedium("Flutter 3.13 (Latest)",
                      fontWeight: 600, letterSpacing: 0.2),
                ],
              ),
            ),
            MySpacing.height(32),
            Container(
              margin: MySpacing.x(20),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      changeTheme();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        MyContainer(
                          paddingAll: 12,
                          borderRadiusAll: 4,
                          color: CustomTheme.occur.withAlpha(20),
                          child: Image(
                            height: 20,
                            width: 20,
                            image: AssetImage(!isDark
                                ? Images.darkModeOutline
                                : Images.lightModeOutline),
                            color: CustomTheme.occur,
                          ),
                        ),
                        MySpacing.width(16),
                        Expanded(
                          child: MyText.bodyLarge(
                            !isDark ? 'dark_mode'.tr() : 'light_mode'.tr(),
                          ),
                        ),
                        MySpacing.width(16),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: theme.colorScheme.onBackground,
                        ).autoDirection(),
                      ],
                    ),
                  ),
                  MySpacing.height(20),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              SelectLanguageDialog());
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        MyContainer(
                          paddingAll: 12,
                          borderRadiusAll: 4,
                          color: CustomTheme.peach.withAlpha(20),
                          child: Image(
                            height: 20,
                            width: 20,
                            image: AssetImage(Images.languageOutline),
                            color: CustomTheme.peach,
                          ),
                        ),
                        MySpacing.width(16),
                        Expanded(
                          child: MyText.bodyLarge(
                            'language'.tr(),
                          ),
                        ),
                        MySpacing.width(16),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: theme.colorScheme.onBackground,
                        ).autoDirection(),
                      ],
                    ),
                  ),
                  MySpacing.height(20),
                  InkWell(
                    onTap: () {
                      changeDirection();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        MyContainer(
                          paddingAll: 12,
                          borderRadiusAll: 4,
                          color: CustomTheme.skyBlue.withAlpha(20),
                          child: Image(
                            height: 20,
                            width: 20,
                            image: AssetImage(
                                AppTheme.textDirection == TextDirection.ltr
                                    ? Images.paragraphRTLOutline
                                    : Images.paragraphLTROutline),
                            color: CustomTheme.skyBlue,
                          ),
                        ),
                        MySpacing.width(16),
                        Expanded(
                          child: MyText.bodyLarge(
                            AppTheme.textDirection == TextDirection.ltr
                                ? "${'right_to_left'.tr()} (RTL)"
                                : "${'left_to_right'.tr()} (LTR)",
                          ),
                        ),
                        MySpacing.width(16),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: theme.colorScheme.onBackground,
                        ).autoDirection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}