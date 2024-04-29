/*
* File : Account Setting
* Version : 1.0.0
* */

import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutkit/loading_effect.dart';

class AccountSettingScreen extends StatefulWidget {
  @override
  _AccountSettingScreenState createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late ProfileController controller;

  String _primerNombre = "", _apellidoPaterno = "", _email = "";
  String _segundoNombre = "", _apellidoMaterno = "", _telefono = "";

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    controller = ProfileController();

    cargarDatos();
  }

  void cargarDatos() async{
    User user = Provider.of<AppNotifier>(context, listen: false).user;
    UserMeta userMeta = await ApiService().getUserMeta(user.id!);
    setState(() {
      _email = user.email!;
      _primerNombre = userMeta.primerNombre!;
      _segundoNombre = userMeta.segundoNombre!;
      _apellidoPaterno = userMeta.apellidoPaterno!;
      _apellidoMaterno = userMeta.apellidoMaterno!;
      _telefono = userMeta.telefono!.toString();
      controller.uiLoading = false;
    });
    print(userMeta.primerNombre);
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
          title: MyText.titleMedium("Configuración de la cuenta", fontWeight: 600),
        ),
        body: ListView(
          padding: MySpacing.nTop(20),
          children: <Widget>[
            MyText.bodyLarge("Información personal",
              fontWeight: 600, letterSpacing: 0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _primerNombre,
                          decoration: InputDecoration(
                            labelText: "Primer nombre *",
                            enabled: false, 
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _segundoNombre = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Segundo nombre",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _apellidoPaterno,
                          decoration: InputDecoration(
                            enabled: false, 
                            labelText: "Apellido paterno *",
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _apellidoMaterno = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _apellidoMaterno,
                            decoration: InputDecoration(
                              labelText: "Apellido materno",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    enabled: false, // Esto hace que el campo sea editable
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    initialValue: _email,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _primerNombre,
                          decoration: InputDecoration(
                            labelText: "Celular 1 *",
                            enabled: false, 
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _segundoNombre = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Celular 2",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "Telf Docimicilio",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _primerNombre,
                          decoration: InputDecoration(
                            labelText: "Cédula de identidad *",
                            enabled: false, 
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _segundoNombre = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Extensión",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _primerNombre,
                          decoration: InputDecoration(
                            labelText: "Sexo",
                            enabled: false, 
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _segundoNombre = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Fecha de nacimiento",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _primerNombre,
                          decoration: InputDecoration(
                            labelText: "Departamento colegio",
                            enabled: false, 
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _segundoNombre = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Colegio *",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "¿En qué curso de secundaria estás?",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24, bottom: 0),
                  child: MyText.bodyLarge("Datos del padre, madre o tutor",
                      fontWeight: 600, letterSpacing: 0),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "Nombres",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: MySpacing.top(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: MyTextStyle.titleSmall(
                            letterSpacing: 0,
                            color: theme.colorScheme.onBackground,
                            fontWeight: 500,
                            fontSize: 14),
                          initialValue: _primerNombre,
                          decoration: InputDecoration(
                            labelText: "Apellido paterno",
                            enabled: false, 
                            border: theme.inputDecorationTheme.border,
                            enabledBorder: theme.inputDecorationTheme.border,
                            focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: MySpacing.left(8),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _segundoNombre = value;
                              });
                            },
                            style: MyTextStyle.titleSmall(
                              letterSpacing: 0,
                              color: theme.colorScheme.onBackground,
                              fontWeight: 500,
                              fontSize: 14),
                            initialValue: _segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Apellido materno",
                              border: theme.inputDecorationTheme.border,
                              enabledBorder: theme.inputDecorationTheme.border,
                              focusedBorder: theme.inputDecorationTheme.focusedBorder,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "Nº Celular",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24, bottom: 0),
                  child: MyText.bodyLarge("Información adicional",
                      fontWeight: 600, letterSpacing: 0),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "¿Tienes Algún(a) Hermano(a) Que Esté Actualmente En La UPSA?",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "Si Respondiste Que Si ¿Cuál Es Su Nombre Completo?",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  margin: MySpacing.top(16),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _telefono = value;
                      });
                    },
                    style: MyTextStyle.titleSmall(
                      letterSpacing: 0,
                      color: theme.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: 14),
                    initialValue: _telefono,
                    decoration: InputDecoration(
                      labelText: "¿Hijo/a de Graduado Upsa?",
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
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
}
