import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/helpers/utils/generator.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/custom/screens/perfil/account_setting_screen.dart';
import 'package:flutkit/custom/screens/perfil/app_setting_screen.dart';
import 'package:flutkit/custom/screens/perfil/configurar_contrase%C3%B1a.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';


class EventoScreen extends StatefulWidget {
  const EventoScreen({Key? key, this.idEvento=-1}) : super(key: key);
  final int idEvento;
  @override
  _EventoScreenState createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  int _idEvento = -1;
  late ThemeData theme;
  late CustomTheme customTheme;

  late LoginController loginController;
  
  String _botonText = "INICIAR SESIÓN";
  bool _isLoggedIn = false, _estaCompletado = false;
  @override
  void initState() {
    super.initState();
    _idEvento = widget.idEvento;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    loginController = LoginController();
    if(Provider.of<AppNotifier>(context, listen: false).isLoggedIn){
      User user = Provider.of<AppNotifier>(context, listen: false).user;
      setState(() {
        _botonText = "CERRAR SESIÓN";
        _isLoggedIn = true;
        _estaCompletado = user.completada!;
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text("Titulo del evento"), // Aquí se establece el título del AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: MySpacing.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 4),
                              Text("Inicio"),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 4),
                              Text("Categoría"),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 4),
                              Text("Artículo"),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                decoration: BoxDecoration(
                    color: customTheme.card,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: customTheme.shadowColor.withAlpha(120),
                          blurRadius: 24,
                          spreadRadius: 4)
                    ]),
                child: Column(
                  children: [
                    ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      child: Image(
                        image: NetworkImage(
                            "https://upsa.focoazul.com/uploads/Captura_de_pantalla_2023_09_19_213839_84c8b91a78.png"),
                      ),
                    ),
                    Container(
                      padding: MySpacing.all(16),
                      child: Column(
                        children: [
                          MyText.titleLarge(
                              "14 Passengers Banned By Nona Airlines After bad Behaviour",
                              color: theme.colorScheme.onBackground,
                              fontWeight: 600),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              margin: MySpacing.top(16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                                    child: Image(
                                      image: AssetImage(
                                          './assets/images/profile/avatar_2.jpg'),
                                      height: 28,
                                      width: 28,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  MyText.bodySmall("John smith",
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 600,
                                      xMuted: true),
                                  Expanded(child: Container()),
                                  MyText.bodySmall("10 Jan, 2020",
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 500,
                                      xMuted: true),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: MySpacing.top(24),
                child: MyText(Generator.getParagraphsText(
                    paragraph: 4,
                    words: 30,
                    noOfNewLine: 2,
                    withHyphen: false)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
