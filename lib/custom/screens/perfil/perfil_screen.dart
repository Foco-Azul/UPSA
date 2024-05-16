import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/admin/lector_qr.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/custom/screens/perfil/account_setting_screen.dart';
import 'package:flutkit/custom/screens/perfil/app_setting_screen.dart';
import 'package:flutkit/custom/screens/perfil/configurar_contrasenia.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
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
  
  String _botonText = "INICIAR SESIÓN";
  bool _isLoggedIn = false, _estaCompletado = false, _confirmed = false;
  User _user = User();
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    loginController = LoginController();
    if(Provider.of<AppNotifier>(context, listen: false).isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      setState(() {
        _botonText = "CERRAR SESIÓN";
        _isLoggedIn = true;
        _estaCompletado = _user.completada!;
        _confirmed = _user.confirmed!;
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
      body: ListView(
        padding: MySpacing.fromLTRB(20, 10, 20, 20),
        children: [
          if(_isLoggedIn && !_confirmed)
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ValidarEmail(theme: theme)));
                },
                child: _buildSingleRow('Verificar correo', LucideIcons.lock),
              ),
              Divider(),
            ]
          ),
          if(_isLoggedIn && !_estaCompletado && _confirmed)
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroEstudiante()));
                },
                child: _buildSingleRow('Completa tu cuenta', LucideIcons.user),
              ),
              Divider(),
            ]
          ),
          if(_isLoggedIn && _estaCompletado && _confirmed)
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingScreen()));
                },
                child: _buildSingleRow('Información del estudiante', LucideIcons.user),
              ),
              Divider(),
            ],
          ),
          if(_isLoggedIn)
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordSettingScreen()));
                },
                child: _buildSingleRow('Información de la cuenta', LucideIcons.lock),
              ),
              Divider(),
            ]
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppSettingScreen()));
            },
            child: _buildSingleRow('Configuración de la App', LucideIcons.lock),
          ),
          Divider(),
          if(_isLoggedIn && _user.rolCustom! == "admin")
          Column(
            children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LectorQRScreen()));
              },
              child: _buildSingleRow('Lector de QR', LucideIcons.lock),
            ),
            Divider(),
            ]
          ),
          MySpacing.height(20),
          MyButton.block(
            onPressed: () {
              if(_isLoggedIn){
                showSnackBarWithFloating("Se cerró tu cuenta satisfactoriamente", Color.fromRGBO(32, 104, 14, 1));
                loginController.logout(context);
              }else{
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
  void showSnackBarWithFloating(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(message, color: theme.colorScheme.onPrimary),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
