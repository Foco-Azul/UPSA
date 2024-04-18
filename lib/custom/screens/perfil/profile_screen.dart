import 'package:provider/provider.dart';
import 'package:upsa/custom/controllers/login_controller.dart';
import 'package:upsa/custom/controllers/profile_controller.dart';
import 'package:upsa/custom/screens/perfil/account_setting_screen.dart';
import 'package:upsa/custom/screens/perfil/app_setting_screen.dart';
import 'package:upsa/custom/screens/perfil/configurar_contrase%C3%B1a.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/widgets/my_button.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;

  late LoginController loginController;
  
  String _botonText = "INICIAR SESIÓN";
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    loginController = LoginController();
    if(Provider.of<AppNotifier>(context, listen: false).isLoggedIn){
      setState(() {
        _botonText = "CERRAR SESIÓN";
        _isLoggedIn = true;
      });
    }
  }

  Widget _buildSingleRow(String name, IconData icon) {
    return Padding(
      padding: MySpacing.y(6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onBackground,
          ),
          MySpacing.width(20),
          Expanded(
              child: MyText.bodyMedium(
            name,
          )),
          MySpacing.width(20),
          Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: theme.colorScheme.onBackground,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
        init: loginController,
        tag: 'profile_controller',
        builder: (controller) {
          return _buildBody();
        });
  }

  Widget _buildBody() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: MyText.titleMedium("Mi perfil", fontWeight: 600),
      ),
      body: ListView(
        padding: MySpacing.fromLTRB(20, 10, 20, 20),
        children: [
          if(_isLoggedIn)
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingScreen()));
            },
            child: _buildSingleRow('Editar cuenta', LucideIcons.user),
          ),
          if(_isLoggedIn)
          Divider(),
          if(_isLoggedIn)
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordSettingScreen()));
            },
            child: _buildSingleRow('Actualizar contraseña', LucideIcons.lock),
          ),
          if(_isLoggedIn)
          Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppSettingScreen()));
            },
            child: _buildSingleRow('Configuración de la App', LucideIcons.lock),
          ),
          Divider(),
          MySpacing.height(20),
          MyButton.block(
            onPressed: () {
              if(_isLoggedIn){
                print("cerrar sesión");
                loginController.logout();
              }else{
                print("inciar sesión");
                loginController.logIn();
              }
            },
            elevation: 0,
            borderRadiusAll: 4,
            padding: MySpacing.y(20),
            backgroundColor: customTheme.muviPrimary,
            splashColor: customTheme.muviOnPrimary.withAlpha(30),
            child: MyText.labelMedium(
              _botonText,
              fontWeight: 600,
              color: customTheme.muviOnPrimary,
            ),
          ),
          MySpacing.height(20),
          Divider(),
          MySpacing.height(20),
          MyText.labelMedium(
            "© 2024 UPSA, Diseñado por FocoAzul",
            textAlign: TextAlign.center,
            letterSpacing: 0.2,
            color: customTheme.muviPrimary,
          ),
        ],
      ),
    );
  }
}
