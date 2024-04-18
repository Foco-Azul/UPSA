/*
* File : Account Setting
* Version : 1.0.0
* */

import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:upsa/helpers/widgets/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PasswordSettingScreen extends StatefulWidget {
  @override
  _PasswordSettingScreenState createState() => _PasswordSettingScreenState();
}

class _PasswordSettingScreenState extends State<PasswordSettingScreen> {
  bool _passwordVisible = false;
  late CustomTheme customTheme;
  late ThemeData theme;

  String _primerNombre = "", _apellidoPaterno = "", _email = "";
  String _segundoNombre = "", _apellidoMaterno = "", _telefono = "";

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    cargarDatos();
  }

  void cargarDatos(){
    _email = "ddsaddas";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            LucideIcons.chevronLeft,
            size: 20,
            color: theme.colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        title: MyText.titleMedium("Configuración de la contraseña", fontWeight: 600),
      ),
      body: ListView(
        padding: MySpacing.nTop(20),
        children: <Widget>[
          MyText.bodyLarge("Cambiar contraseña",
            fontWeight: 600, letterSpacing: 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: MySpacing.top(8),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  style: MyTextStyle.titleSmall(
                    letterSpacing: 0,
                    color: theme.colorScheme.onBackground,
                    fontWeight: 500,
                    fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "Contraseña anterior",
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.border,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    prefixIcon: Icon(
                      LucideIcons.lock,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  obscureText: _passwordVisible,
                ),
              ),
              Container(
                margin: MySpacing.top(8),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  style: MyTextStyle.titleSmall(
                    letterSpacing: 0,
                    color: theme.colorScheme.onBackground,
                    fontWeight: 500,
                    fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "Nueva contraseña",
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.border,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    prefixIcon: Icon(
                      LucideIcons.lock,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  obscureText: _passwordVisible,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 24),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(28),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(0),
                          padding:
                              MaterialStateProperty.all(MySpacing.xy(20, 12))),
                      child: MyText.bodyMedium("GUARDAR",
                          fontWeight: 600, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                )
              )
            ]
          ),
        ],
      )
    );
  }
}
