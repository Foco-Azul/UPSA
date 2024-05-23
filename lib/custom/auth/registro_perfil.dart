import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/models/promocion.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/helpers/extensions/extensions.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    "promocion": "",
  };
  List<Promocion> _promociones = [];

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
    _promociones = await ApiService().getPromociones();
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
      if (_userMeta.promocion == null || _userMeta.promocion!.isEmpty) {
        _errores["promocion"] = "Selecciona una opción";
      }else{
        _errores["promocion"] = "";
      }
      if(_userMeta.fechaDeNacimiento == null){
        _errores["fechaDeNacimiento"] = "Este campo es requerido";
      }else{
        _errores["fechaDeNacimiento"] = "";
      }
    });

    if (_errores["nombres"]!.isEmpty && _errores["apellidos"]!.isEmpty && _errores["cedulaDeIdentidad"]!.isEmpty && _errores["celular1"]!.isEmpty && _errores["promocion"]!.isEmpty) {
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
  void _onOptionSelected(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.promocion = {"id":int.parse(selectedOptions[0].value!)};
    }else{
      _userMeta.promocion = {};
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
                  MyContainer.bordered(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    //margin: EdgeInsets.only(top: 100,),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(     
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: const <Widget>[
                              Icon(FontAwesomeIcons.addressCard, size: 40, color: Color.fromRGBO(215, 215, 215, 1),), // Icono a la izquierda
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[// Espacio entre el icono y el texto
                            MyText.titleLarge(
                              "📝 Llenemos tu perfil",
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
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                            color: Color.fromRGBO(32, 104, 14, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
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
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                            color: Color.fromRGBO(32, 104, 14, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
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
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
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
                                                  color: Color.fromRGBO(32, 104, 14, 1),
                                                  width: 2.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
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
                                          backgroundColor: Color.fromRGBO(32, 104, 14, 1),
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
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                            color: Color.fromRGBO(32, 104, 14, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
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
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                            color: Color.fromRGBO(32, 104, 14, 1),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
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
                                  MyText.bodyMedium(
                                    'Nombre de promoción',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelected,
                                    options: _buildValueItems(),
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.single,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                  if (_errores["promocion"]!.isNotEmpty)     
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["promocion"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MySpacing.height(20),
                            SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                color: Color.fromRGBO(32, 104, 14, 1),
                                onPressed: () {
                                  _validarCampos();
                                },
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                padding: MySpacing.xy(100, 16),
                                pressedOpacity: 0.5,
                                child: MyText.bodyMedium(
                                  "Continuar",
                                  color: theme.colorScheme.onSecondary,
                                  fontSize: 16,
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
    return _promociones.map((promocion) {
      return ValueItem(
        label: promocion.nombre!,
        value: promocion.id.toString(),
      );
    }).toList();
  }
}
