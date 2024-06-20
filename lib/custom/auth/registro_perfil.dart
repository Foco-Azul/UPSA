import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/models/colegio.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/helpers/extensions/extensions.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutkit/loading_effect.dart';

class RegistroPerfil extends StatefulWidget {
  @override
  _RegistroPerfilState createState() => _RegistroPerfilState();
}

class _RegistroPerfilState extends State<RegistroPerfil> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late ProfileController controller;
  Validacion validacion = Validacion();
  UserMeta _userMeta = UserMeta();
  User _user = User();
  int _isInProgress = -1;
  final Map<String, String> _errores = {
    "nombres": "",
    "apellidos": "",
    "cedulaDeIdentidad": "",
    "fechaDeNacimiento": "",
    "celular1": "",
    "colegio": "",
  };
  List<Colegio> _colegios = [];

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
    _colegios = await ApiService().getColegios();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    setState(() {
      _errores["nombres"] = validacion.validarNombres(_userMeta.nombres, true);
      _errores["apellidos"] = validacion.validarNombres(_userMeta.apellidos, true);
      _errores["cedulaDeIdentidad"] = validacion.validarNumerosPositivos(_userMeta.cedulaDeIdentidad, true, true);
      _errores["celular1"] = validacion.validarNumerosPositivos(_userMeta.celular1, true, true);
      if (_userMeta.colegio == null || _userMeta.colegio!.isEmpty) {
        _errores["colegio"] = "Selecciona una opción";
      }else{
        _errores["colegio"] = "";
      }
      if(_userMeta.fechaDeNacimiento == null){
        _errores["fechaDeNacimiento"] = "Este campo es requerido";
      }else{
        _errores["fechaDeNacimiento"] = "";
      }
    });

    if (_errores["nombres"]!.isEmpty && _errores["apellidos"]!.isEmpty && _errores["cedulaDeIdentidad"]!.isEmpty && _errores["celular1"]!.isEmpty && _errores["colegio"]!.isEmpty) {
      _registrarEstudiante();
    }
  }
  void _registrarEstudiante() async {
    try {
      setState(() {
        _isInProgress = 0;
      });
      bool bandera = await ApiService().registrarPerfil(_userMeta, _user.id!);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
          _isInProgress = -1;
        });
      } else {
        _user.estado = "Perfil parte 1";
        Provider.of<AppNotifier>(context, listen: false).setUser(_user);
        setState(() {
          _isInProgress = -1;
        });
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
      }
    } on Exception catch (e) { 
      setState(() {
        _isInProgress = -1;
        _errores["error"] = e.toString().substring(11);
        print(e.toString().substring(11));
      });
    }
  }
  DateTime selectedDate = DateTime.now();
  _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        locale: const Locale("es"),
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2005),
        lastDate: DateTime.now(),);
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _userMeta.fechaDeNacimiento = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  void _onOptionSelected(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.colegio = {"id":int.parse(selectedOptions[0].value!)};
    }else{
      _userMeta.colegio = {};
    }
    setState(() {
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
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    color: Color.fromRGBO(244, 251, 249, 1),
                    child: Column(     
                      children: <Widget>[
                        Row(
                          children: <Widget>[// Espacio entre el icono y el texto
                            MyText.titleLarge(
                              "Llenemos tu perfil",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8), // Espacio entre el título y el texto
                        MyText.bodyMedium(
                          'Los datos de tu perfil nos permitirá sugerirte una carrera de estudio y un seguimiento más personalizado.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                          spreadRadius: 2, // Radio de propagación
                                          blurRadius: 5, // Radio de desenfoque
                                          offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          _userMeta.nombres = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        border: InputBorder.none,
                                        labelText: 'Nombre(s)',
                                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(5, 50, 12, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_errores["nombres"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["nombres"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                          spreadRadius: 2, // Radio de propagación
                                          blurRadius: 5, // Radio de desenfoque
                                          offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          _userMeta.apellidos = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        border: InputBorder.none,
                                        labelText: 'Apellido(s)',
                                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(5, 50, 12, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_errores["apellidos"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["apellidos"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                                spreadRadius: 2, // Radio de propagación
                                                blurRadius: 5, // Radio de desenfoque
                                                offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            readOnly: true,
                                            controller: TextEditingController(text: _userMeta.fechaDeNacimiento),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                              border: InputBorder.none,
                                              labelText: 'Fecha de nacimiento',
                                              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(5, 50, 12, 1),
                                                  width: 2.0,
                                                ),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 16),
                                        child: MyButton(
                                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                          onPressed: () {
                                            _pickDate(context);
                                          },
                                          elevation: 0,
                                          borderRadiusAll: 4,
                                          backgroundColor: Color.fromRGBO(5, 50, 12, 1),
                                          child: Icon(
                                            LucideIcons.calendar,
                                            size: 20,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_errores["fechaDeNacimiento"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["fechaDeNacimiento"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                          spreadRadius: 2, // Radio de propagación
                                          blurRadius: 5, // Radio de desenfoque
                                          offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          _userMeta.celular1 = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        border: InputBorder.none,
                                        labelText: 'Número de teléfono',
                                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(5, 50, 12, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                  ),
                                  if (_errores["celular1"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["celular1"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                          spreadRadius: 2, // Radio de propagación
                                          blurRadius: 5, // Radio de desenfoque
                                          offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          _userMeta.cedulaDeIdentidad = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        border: InputBorder.none,
                                        labelText: 'Cédula de identidad',
                                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(5, 50, 12, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                  ),
                                  if (_errores["cedulaDeIdentidad"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["cedulaDeIdentidad"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),   
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[                                                             
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5), // Color de la sombra con opacidad
                                          spreadRadius: 2, // Radio de propagación
                                          blurRadius: 5, // Radio de desenfoque
                                          offset: Offset(0, 3), // Desplazamiento de la sombra (horizontal, vertical)
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        MultiSelectDropDown(
                                          onOptionSelected: _onOptionSelected,
                                          options: _buildValueItems(),
                                          hint: "- Colegio -",
                                          selectionType: SelectionType.single,
                                          chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                          optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                          selectedOptionIcon: const Icon(Icons.check_circle),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_errores["colegio"]!.isNotEmpty)     
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["colegio"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ]
                              )
                            ),
                            MySpacing.height(20),
                            SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                color: Color.fromRGBO(5, 50, 12, 1),
                                onPressed: () {
                                  _validarCampos();
                                },
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                padding: MySpacing.xy(100, 16),
                                pressedOpacity: 0.5,
                                child: MyText.bodyMedium(
                                  "Continuar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            MySpacing.height(20),
                          ]
                        ),
                      ]
                    )
                  ),
                ]
              ),
              if (_isInProgress == 0)
              Positioned.fill(
                child: ProgressEspera(
                  theme: theme, // Pasar el tema como argumento
                ),
              ),
            ]
          ),
        )
      );
    } 
  }
  List<ValueItem> _buildValueItems() {
    return _colegios.map((colegio) {
      return ValueItem(
        label: colegio.nombre!,
        value: colegio.id.toString(),
      );
    }).toList();
  }
}
