import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/helpers/extensions/extensions.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  Validacion validacion = Validacion();
  UserMeta _userMeta = UserMeta();
  User _user = User();
  int _isInProgress = -1;
  final Map<String, String> _errores = {
    "segundoNombre": "",
    "apellidoMaterno": "",
    "cedulaDeIdentidad": "",
    "extension": "",
    "sexo": "",
    "fechaDeNacimiento": "",
    "celular1": "",
    "celular2": "",
    "telfDomicilio": "",
    "departamentoColegio": "",
    "colegio": "",
    "cursoDeSecundaria": "",
    "tutorNombres": "",
    "tutorApellidoPaterno": "",
    "tutorApellidoMaterno": "",
    "tutorCelular": "",
    "tutorEmail": "",
    "hermano": "",
    "tieneHermano": "",
    "error": "",
    "hijoDeGraduadoUpsa": "",
  };
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    controller = ProfileController();
    selectedDate = DateTime.now();
    cargarDatos();
  }
  void cargarDatos() async{
     _user = Provider.of<AppNotifier>(context, listen: false).user;
    _userMeta = await ApiService().getUserMeta(_user.id!);
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    setState(() {
      _errores["segundoNombre"] = validacion.validarNombres(_userMeta.segundoNombre, false);
      _errores["apellidoMaterno"] = validacion.validarNombres(_userMeta.apellidoMaterno, false);
      _errores["cedulaDeIdentidad"] = validacion.validarNumerosPositivos(_userMeta.cedulaDeIdentidad, true, true);
      _errores["extension"] = validacion.validarNombres(_userMeta.extension, false);
      _errores["sexo"] = validacion.validarNombres(_userMeta.sexo, false);
      //_errores["fechaDeNacimiento"] = validacion.fecha(_userMeta.fechaDeNacimiento, false);

      _errores["celular1"] = validacion.validarNumerosPositivos(_userMeta.celular1, true, true);
      _errores["celular2"] = validacion.validarNumerosPositivos(_userMeta.celular2, false, true);
      _errores["telfDomicilio"] = validacion.validarNumerosPositivos(_userMeta.telfDomicilio, false, true);

      _errores["departamentoColegio"] = validacion.validarAlfanumericos(_userMeta.departamentoColegio, false);
      _errores["colegio"] = validacion.validarAlfanumericos(_userMeta.colegio, true);
      _errores["cursoDeSecundaria"] = validacion.validarAlfanumericos(_userMeta.cursoDeSecundaria, false);

      _errores["tutorNombres"] = validacion.validarNombres(_userMeta.tutorNombres, false);
      _errores["tutorApellidoPaterno"] = validacion.validarNombres(_userMeta.tutorApellidoPaterno, false);
      _errores["tutorApellidoMaterno"] = validacion.validarNombres(_userMeta.tutorApellidoMaterno, false);
      _errores["tutorCelular"] = validacion.validarNumerosPositivos(_userMeta.tutorCelular, false, true);
      _errores["tutorEmail"] = validacion.validarCorreo(_userMeta.tutorEmail, false);

      _errores["hermano"] = validacion.validarNombres(_userMeta.hermano, false);
      _errores["hijoDeGraduadoUpsa"] = validacion.validarNombres(_userMeta.hijoDeGraduadoUpsa, false);
    });

    if (_errores["segundoNombre"]!.isEmpty && _errores["apellidoMaterno"]!.isEmpty && _errores["cedulaDeIdentidad"]!.isEmpty && _errores["extension"]!.isEmpty && _errores["sexo"]!.isEmpty && _errores["celular1"]!.isEmpty && _errores["celular2"]!.isEmpty && _errores["telfDomicilio"]!.isEmpty && _errores["departamentoColegio"]!.isEmpty && _errores["colegio"]!.isEmpty && _errores["cursoDeSecundaria"]!.isEmpty && _errores["tutorNombres"]!.isEmpty && _errores["tutorApellidoPaterno"]!.isEmpty && _errores["tutorApellidoMaterno"]!.isEmpty && _errores["tutorCelular"]!.isEmpty && _errores["tutorEmail"]!.isEmpty && _errores["hermano"]!.isEmpty) {
      _registrarEstudiante();
    }else{
      showSnackBarWithFloating("Hay campos con errores, revisa el formulario.");
    }
  }
  void _registrarEstudiante() async {
    try {
      setState(() {
        _isInProgress = 0;
      });
      bool bandera = await ApiService().registrarEstudiante(_userMeta, _user.id!);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
          showSnackBarWithFloating(_errores["error"]!);
          _isInProgress = -1;
        });
      } else {
        _user.completada = true;
        Provider.of<AppNotifier>(context, listen: false).setUser(_user);
        setState(() {
          _isInProgress = -1;
          showSnackBarWithFloating("Exito!!!");
        });
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
      }
    } on Exception catch (e) {
      setState(() {
        _errores["error"] = e.toString().substring(11);
      });
    }
  }
  DateTime selectedDate = DateTime.now();
  _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),);
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _userMeta.fechaDeNacimiento = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  void showSnackBarWithFloating(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(message, color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        body: Stack( 
          children: <Widget>[
            PageView(
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
                                  initialValue: _userMeta.primerNombre,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.segundoNombre = value;
                                    });
                                  },
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
                                    error: _errores["segundoNombre"]!.isNotEmpty
                                      ? Text(
                                          _errores["segundoNombre"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _userMeta.segundoNombre,
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
                                  initialValue: _userMeta.apellidoPaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.apellidoMaterno = value;
                                    });
                                  },
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
                                    error: _errores["apellidoMaterno"]!.isNotEmpty
                                      ? Text(
                                          _errores["apellidoMaterno"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _userMeta.apellidoMaterno,
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
                                  initialValue: _user.email,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.cedulaDeIdentidad = value;
                                    });
                                  },
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
                                    error: _errores["cedulaDeIdentidad"]!.isNotEmpty
                                      ? Text(
                                          _errores["cedulaDeIdentidad"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _userMeta.cedulaDeIdentidad,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(   
                                        labelText: "Extensión",
                                        border: theme.inputDecorationTheme.border,
                                        enabledBorder: theme.inputDecorationTheme.border,
                                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                        contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                                         error: _errores["extension"]!.isNotEmpty
                                          ? Text(
                                              _errores["extension"]!,
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : null,
                                      ),
                                      child: DropdownButtonHideUnderline(     
                                        child: DropdownButton(
                                          style: MyTextStyle.titleSmall(
                                            letterSpacing: 0,
                                            color: theme.colorScheme.onBackground,
                                            fontWeight: 500,
                                            fontSize: 14
                                          ),
                                          // Initial Value
                                          value: _userMeta.extension,
                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          // Array list of items
                                          items: ["", "EXT", "NS", "CB", "PT", "BN", "CH", "LP", "CBBA", "OR", "PO", "TJ", "SC", "BE", "PD"].map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _userMeta.extension = newValue!;
                                            });
                                          },
                                          // Cambia el color de fondo de la lista desplegable
                                          dropdownColor: Colors.grey[200], // Cambia aquí al color deseado
                                        )
                                      )
                                    ),
                                  ],
                                ),
                              ),     
                              Container(
                                margin: MySpacing.top(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(   
                                        labelText: "Sexo",
                                        border: theme.inputDecorationTheme.border,
                                        enabledBorder: theme.inputDecorationTheme.border,
                                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                        contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                                        error: _errores["sexo"]!.isNotEmpty
                                          ? Text(
                                              _errores["sexo"]!,
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : null,
                                      ),
                                      child: DropdownButtonHideUnderline(     
                                        child: DropdownButton(
                                          style: MyTextStyle.titleSmall(
                                            letterSpacing: 0,
                                            color: theme.colorScheme.onBackground,
                                            fontWeight: 500,
                                            fontSize: 14
                                          ),
                                          // Initial Value
                                          value: _userMeta.sexo,
                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          // Array list of items
                                          items: ["", "Masculino", "Femenino"].map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _userMeta.sexo = newValue!;
                                            });
                                          },
                                          // Cambia el color de fondo de la lista desplegable
                                          dropdownColor: Colors.grey[200], // Cambia aquí al color deseado
                                        )
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: TextEditingController(text: _userMeta.fechaDeNacimiento),
                                        readOnly: true,
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
                                      ),
                                    ),
                                    Container(
                                      margin: MySpacing.only(left: 8, top: 32),
                                      child: MyButton(
                                        padding: MySpacing.xy(18, 16),
                                        onPressed: () {
                                          _pickDate(context);
                                        },
                                        elevation: 0,
                                        borderRadiusAll: 4,
                                        child: Icon(
                                          LucideIcons.calendar,
                                          size: 20,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.celular1 = value;
                                    });
                                  },
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
                                    error: _errores["celular1"]!.isNotEmpty
                                      ? Text(
                                          _errores["celular1"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _userMeta.celular1,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.celular2 = value;
                                    });
                                  },
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
                                    error: _errores["celular2"]!.isNotEmpty
                                      ? Text(
                                          _errores["celular2"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _userMeta.celular2,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.telfDomicilio = value;
                                    });
                                  },
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
                                    error: _errores["telfDomicilio"]!.isNotEmpty
                                      ? Text(
                                          _errores["telfDomicilio"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _userMeta.telfDomicilio,
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
                                margin: MySpacing.top(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(   
                                        labelText: "Departamento del colegio",
                                        border: theme.inputDecorationTheme.border,
                                        enabledBorder: theme.inputDecorationTheme.border,
                                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                        contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                                        error: _errores["departamentoColegio"]!.isNotEmpty
                                          ? Text(
                                              _errores["departamentoColegio"]!,
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : null,
                                      ),
                                      child: DropdownButtonHideUnderline(     
                                        child: DropdownButton(
                                          style: MyTextStyle.titleSmall(
                                            letterSpacing: 0,
                                            color: theme.colorScheme.onBackground,
                                            fontWeight: 500,
                                            fontSize: 14
                                          ),
                                          // Initial Value
                                          value: _userMeta.departamentoColegio,
                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          // Array list of items
                                          items: ["","EXTRANJERO", "NO SABE/NO RESPONDE", "COCHABAMBA", "POTOSÍ", "BENI", "CHUQUISACA", "LA PAZ", "ORURO", "TARIJA", "SANTA CRUZ", "BENI", "PANDO"].map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _userMeta.departamentoColegio = newValue!;
                                            });
                                          },
                                          // Cambia el color de fondo de la lista desplegable
                                          dropdownColor: Colors.grey[200], // Cambia aquí al color deseado
                                        )
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.colegio = value;
                                    });
                                  },
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
                                    error: _errores["colegio"]!.isNotEmpty
                                      ? Text(
                                          _errores["colegio"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  initialValue: _userMeta.colegio,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(   
                                        labelText: "¿En qué curso de secundaria estás?",
                                        border: theme.inputDecorationTheme.border,
                                        enabledBorder: theme.inputDecorationTheme.border,
                                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                        contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                                        error: _errores["cursoDeSecundaria"]!.isNotEmpty
                                          ? Text(
                                              _errores["cursoDeSecundaria"]!,
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : null,
                                      ),
                                      child: DropdownButtonHideUnderline(     
                                        child: DropdownButton(
                                          style: MyTextStyle.titleSmall(
                                            letterSpacing: 0,
                                            color: theme.colorScheme.onBackground,
                                            fontWeight: 500,
                                            fontSize: 14
                                          ),
                                          // Initial Value
                                          value: _userMeta.cursoDeSecundaria,
                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          // Array list of items
                                          items: ["", "Tercero Secundaria", "Cuarto Secundaria", "Quinto Secundaria", "Sexto Secundaria"].map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _userMeta.cursoDeSecundaria = newValue!;
                                            });
                                          },
                                          // Cambia el color de fondo de la lista desplegable
                                          dropdownColor: Colors.grey[200], // Cambia aquí al color deseado
                                        )
                                      )
                                    ),
                                  ],
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
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.tutorNombres = value;
                                    });
                                  },
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
                                    error: _errores["tutorNombres"]!.isNotEmpty
                                      ? Text(
                                          _errores["tutorNombres"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _userMeta.tutorNombres,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.tutorApellidoPaterno = value;
                                    });
                                  },
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
                                    error: _errores["tutorApellidoPaterno"]!.isNotEmpty
                                      ? Text(
                                          _errores["tutorApellidoPaterno"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _userMeta.tutorApellidoPaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.tutorApellidoMaterno = value;
                                    });
                                  },
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
                                    error: _errores["tutorApellidoMaterno"]!.isNotEmpty
                                      ? Text(
                                          _errores["tutorApellidoMaterno"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _userMeta.tutorApellidoMaterno,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.tutorCelular = value;
                                    });
                                  },
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
                                    error: _errores["tutorCelular"]!.isNotEmpty
                                      ? Text(
                                          _errores["tutorCelular"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  initialValue: _userMeta.tutorCelular,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.tutorEmail = value;
                                    });
                                  },
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
                                    error: _errores["tutorEmail"]!.isNotEmpty
                                      ? Text(
                                          _errores["tutorEmail"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: _userMeta.tutorEmail,
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
                                margin: MySpacing.top(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(   
                                        labelText: "¿Tienes Algún(a) Hermano(a) Que Esté Actualmente En La UPSA?",
                                          labelStyle: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        border: theme.inputDecorationTheme.border,
                                        enabledBorder: theme.inputDecorationTheme.border,
                                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                        contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                                        error: _errores["tieneHermano"]!.isNotEmpty
                                          ? Text(
                                              _errores["tieneHermano"]!,
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : null,
                                      ),
                                      child: DropdownButtonHideUnderline(     
                                        child: DropdownButton(
                                          style: MyTextStyle.titleSmall(
                                            letterSpacing: 0,
                                            color: theme.colorScheme.onBackground,
                                            fontWeight: 500,
                                            fontSize: 14
                                          ),
                                          // Initial Value
                                          value: _userMeta.tieneHermano,
                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          // Array list of items
                                          items: ["No", "Si"].map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _userMeta.tieneHermano = newValue!;
                                            });
                                          },
                                          // Cambia el color de fondo de la lista desplegable
                                          dropdownColor: Colors.grey[200], // Cambia aquí al color deseado
                                        )
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              if(_userMeta.tieneHermano == "Si")
                              Container(
                                margin: MySpacing.top(16),
                                child: TextFormField( // Esto hace que el campo sea editable
                                  onChanged: (value) {
                                    setState(() {
                                      _userMeta.hermano = value;
                                    });
                                  },
                                  style: MyTextStyle.titleSmall(
                                    letterSpacing: 0,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: 500,
                                    fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: "¿Cuál Es Su Nombre Completo?",
                                    border: theme.inputDecorationTheme.border,
                                    enabledBorder: theme.inputDecorationTheme.border,
                                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                    error: _errores["hermano"]!.isNotEmpty
                                      ? Text(
                                          _errores["hermano"]!,
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : null,
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')), // Permite solo letras
                                  ],
                                  initialValue: _userMeta.hermano,
                                ),
                              ),
                              Container(
                                margin: MySpacing.top(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(   
                                        labelText: "¿Hijo/a de Graduado Upsa?",
                                          labelStyle: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        border: theme.inputDecorationTheme.border,
                                        enabledBorder: theme.inputDecorationTheme.border,
                                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
                                        contentPadding: EdgeInsets.only(bottom: 0, top: 0),
                                        error: _errores["hijoDeGraduadoUpsa"]!.isNotEmpty
                                          ? Text(
                                              _errores["hijoDeGraduadoUpsa"]!,
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : null,
                                      ),
                                      child: DropdownButtonHideUnderline(     
                                        child: DropdownButton(
                                          style: MyTextStyle.titleSmall(
                                            letterSpacing: 0,
                                            color: theme.colorScheme.onBackground,
                                            fontWeight: 500,
                                            fontSize: 14
                                          ),
                                          // Initial Value
                                          value: _userMeta.hijoDeGraduadoUpsa,
                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          // Array list of items
                                          items: ["No", "Si"].map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _userMeta.hijoDeGraduadoUpsa = newValue!;
                                            });
                                          },
                                          // Cambia el color de fondo de la lista desplegable
                                          dropdownColor: Colors.grey[200], // Cambia aquí al color deseado
                                        )
                                      )
                                    ),
                                  ],
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
          ],
            ),
            if (_isInProgress == 0)
            Positioned.fill(
              child: ProgressEspera(
                theme: theme, // Pasar el tema como argumento
              ),
            ),
          ]
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
                    _validarCampos();
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
