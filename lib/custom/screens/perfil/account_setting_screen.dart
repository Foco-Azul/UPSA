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
  UserMeta _userMeta = UserMeta();
  User _user = User();
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
    _user = Provider.of<AppNotifier>(context, listen: false).user;
    _userMeta = await ApiService().getUserMeta(_user.id!);
    setState(() {
      controller.uiLoading = false;
    });
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
          title: MyText.titleMedium("Datos del estudiante", fontWeight: 600),
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
                          initialValue: _userMeta.primerNombre,
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
                            initialValue: _userMeta.segundoNombre,
                            decoration: InputDecoration(
                              labelText: "Segundo nombre",
                              enabled: false, 
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
                          initialValue: _userMeta.apellidoPaterno,
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
                            initialValue: _userMeta.apellidoMaterno,
                            decoration: InputDecoration(
                              labelText: "Apellido materno",
                              enabled: false, 
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
                      enabled: false, 
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    initialValue: _user.email,
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
                          initialValue: _userMeta.celular1,
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
                            initialValue: _userMeta.celular2,
                            decoration: InputDecoration(
                              labelText: "Celular 2",
                              enabled: false, 
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
                    initialValue: _userMeta.telfDomicilio,
                    decoration: InputDecoration(
                      labelText: "Telf Docimicilio",
                      enabled: false, 
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
                          initialValue: _userMeta.cedulaDeIdentidad,
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
                            initialValue: _userMeta.extension,
                            decoration: InputDecoration(
                              labelText: "Extensión",
                              enabled: false, 
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
                            initialValue: _userMeta.fechaDeNacimiento,
                            decoration: InputDecoration(
                              labelText: "Fecha de nacimiento",
                              enabled: false, 
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
                          initialValue: _userMeta.departamentoColegio,
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
                            initialValue: _userMeta.colegio,
                            decoration: InputDecoration(
                              labelText: "Colegio *",
                              enabled: false, 
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
                    initialValue: _userMeta.cursoDeSecundaria,
                    decoration: InputDecoration(
                      labelText: "¿En qué curso de secundaria estás?",
                      enabled: false, 
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
                    initialValue: _userMeta.tutorNombres,
                    decoration: InputDecoration(
                      labelText: "Nombres",
                      enabled: false, 
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
                          initialValue: _userMeta.tutorApellidoPaterno,
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
                            initialValue: _userMeta.tutorApellidoMaterno,
                            decoration: InputDecoration(
                              labelText: "Apellido materno",
                              enabled: false, 
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
                    initialValue: _userMeta.tutorCelular,
                    decoration: InputDecoration(
                      labelText: "Nº Celular",
                      enabled: false, 
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
                    initialValue: _userMeta.tutorEmail,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      enabled: false, 
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
                if(_userMeta.tieneHermano! != "No")
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
                    initialValue: _userMeta.hermano,
                    decoration: InputDecoration(
                      labelText: "Hermano",
                      enabled: false, 
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
                    initialValue: _userMeta.hijoDeGraduadoUpsa,
                    decoration: InputDecoration(
                      labelText: "¿Hijo/a de Graduado Upsa?",
                      enabled: false, 
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24, bottom: 0),
                  child: MyText.bodyLarge("Mis intereses",
                      fontWeight: 600, letterSpacing: 0),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                        Container(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        child: Wrap(
                          children: _buildChoiceList(),
                        ),
                      )
                    ]
                  )
                ),
              ]
            ),
          ],
        )
      );
    }
  }
  _buildChoiceList() {
    List<String> categoryList = [
      "Fútbol",
      "Tenis",
      "Idiomas",
      "Voluntariado",
      "Tecnologia",
      "Música",
      "Teatro",
      "Natación",
      "Esports",
      "Literatura",
      "Streaming",
    ];

    List<Widget> choices = [];
    for (var item in categoryList) {
      choices.add(Container(
        padding: MySpacing.all(8),
        child: ChoiceChip(
          checkmarkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selectedColor: Color.fromRGBO(32, 104, 14, 1),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText.bodyMedium(item,
                  color: _userMeta.intereses!.contains(item)
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onBackground),
            ],
          ),
          selected: _userMeta.intereses!.contains(item),
          onSelected: (selected) {
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
              width: 1.0, // Ancho del borde
            ),
            borderRadius: BorderRadius.circular(14), // Radio de borde
          ),
        ),
      ));
    }
    return choices;
  }
}
