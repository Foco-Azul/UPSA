/*
* File : Account Setting
* Version : 1.0.0
* */

import 'package:flutkit/helpers/extensions/extensions.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutter/services.dart';
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

class RegistroEstudiante extends StatefulWidget {
  @override
  _RegistroEstudianteState createState() => _RegistroEstudianteState();
}

class _RegistroEstudianteState extends State<RegistroEstudiante> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late ProfileController controller;

  String _primerNombre = "", _apellidoPaterno = "", _email = "";
  String _segundoNombre = "", _apellidoMaterno = "", _cedulaDeIdentidad = "", _extension = "", _sexo = "", _fechaDeNacimiento = "";
  String _celular1 = "", _celular2 = "", _telfDomicilio = "";
  String _departamentoColegio = "", _colegio = "", _cursoDeSecundaria = "";
  String _tutorNombres = "", _tutorApellidoPaterno = "", _tutorApellidoMaterno = "", _tutorCelular = "", _tutorEmail = "";
  String _hermano = "", _tieneHermano = "";
  bool _hijoDeGraduadoUpsa = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;
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
      _apellidoPaterno = userMeta.apellidoPaterno!;
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
          elevation: 0,
          title: MyText.titleMedium(
            "Registro de estudiante".tr(),
            fontWeight: 600,
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              LucideIcons.chevronLeft,
              size: 20,
              color: theme.colorScheme.onBackground,
            ).autoDirection(),
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: <Widget>[
            Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 40,
                            color: theme.colorScheme.onBackground.withAlpha(220),
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 16, bottom: 16),
                            child: MyText.titleLarge("¿Por qué debería llenar el formulario?", 
                            fontWeight: 600,
                            textAlign: TextAlign.center,),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: MySpacing.top(16),
                                child: Center(
                                  child: MyText.bodySmall(
                                    "Deberias llenar porque...",
                                    fontWeight: 600,
                                    letterSpacing: 0,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 12, top: 8),
                          child: MyText.titleLarge("Información personal", fontWeight: 600, textAlign: TextAlign.center),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: TextFormField(
                                  enabled: false, // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Primer nombre *",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  initialValue: _primerNombre,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Segundo nombre",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _segundoNombre,
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
                                    labelText: "Apellido paterno *",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  initialValue: _apellidoPaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Apellido materno",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _apellidoMaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( 
                                  enabled: false,// Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Correo electronico *",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: _email,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Cédula de identidad *",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _cedulaDeIdentidad,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Extensión",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _extension,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Sexo",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _sexo,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Fecha de nacimiento",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  
                                  initialValue: _fechaDeNacimiento,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 12, top: 8),
                          child: MyText.titleLarge("Información de contacto", fontWeight: 600, textAlign: TextAlign.center),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: TextFormField(
                                  // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Celular 1 *",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _celular1,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Celular 2",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _celular2,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Telf Domicilio",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _telfDomicilio,
                                ),
                              ),
                            ]
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 12, top: 8),
                          child: MyText.titleLarge("Información academica", fontWeight: 600, textAlign: TextAlign.center),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Departamento del colegio",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _departamentoColegio,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Colegio *",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  initialValue: _colegio,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "¿En qué curso de secundaria estás?",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  initialValue: _cursoDeSecundaria,
                                ),
                              ),
                            ]
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 12, top: 8, left: 12),
                          child: MyText.titleLarge("Datos del padre, madre o tutor (Opcional)", fontWeight: 600, textAlign: TextAlign.center),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Nombres",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _tutorNombres,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Apellido paterno",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _tutorApellidoPaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Apellido materno",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _tutorApellidoMaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Nº Celular",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _tutorCelular,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Correo electronico",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: _tutorEmail,
                                ),
                              ),
                            ]
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            ),
            Container(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 12, top: 8, left: 12),
                          child: MyText.titleLarge("Información adicional (Opcional)", fontWeight: 600, textAlign: TextAlign.center),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "¿Tienes Algún(a) Hermano(a) Que Esté Actualmente En La UPSA?",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _tieneHermano,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "Si Respondiste Que Si ¿Cuál Es Su Nombre Completo?",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _hermano,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "¿Hijo/a de Graduado Upsa?",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                  ),
                                  keyboardType: TextInputType.text,
                                  initialValue: _hijoDeGraduadoUpsa != null ? (_hijoDeGraduadoUpsa ? "Si" : "No") : null,
                                ),
                              ),
                            ]
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            )
          ],
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              onPressed: () {
                if (_currentPage > 0) {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text(_currentPage > 0 ? 'Anterior' : ''),
            ),
            TextButton(
              onPressed: () {
                if (_currentPage < 6) {
                  if(_currentPage == 5){
                    print("la ultima pagina");
                  }else{
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                }
              },
              child: Text(_currentPage < 5 ? 'Siguiente' : 'Enviar'),
            ),
          ],
        ),
      );
    } 
  }
}
