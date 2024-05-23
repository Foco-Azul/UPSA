import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/universidad.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/helpers/extensions/extensions.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class RegistroCarrera extends StatefulWidget {
  @override
  _RegistroCarreraState createState() => _RegistroCarreraState();
}

class _RegistroCarreraState extends State<RegistroCarrera> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late ProfileController controller;
  Validacion validacion = Validacion();
  UserMeta _userMeta = UserMeta();
  User _user = User();
  int _isInProgress = -1;
  final Map<String, String> _errores = {
    "carreras": "",
    "infoCar": "",
    "aplicacionTest": "",
    "universidades": "",
  };
  List<String> selectedChoices = [];
  List<Carrera> _carreras = [];
  List<Universidad> _universidades = [];
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
    _carreras = await ApiService().getCarreras();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    if(!_userMeta.testVocacional!){
      _errores["carreras"] =(_userMeta.carreras == null || _userMeta.carreras!.isEmpty || _userMeta.carreras!.length > 3) ? "Selecciona de 1 a 3 carreras" : "";
      _errores["infoCar"] = _userMeta.infoCar == null || _userMeta.infoCar!.isEmpty ? "Este campo es requerido" : "";
      _errores["universidades"] = (_userMeta.universidades == null || _userMeta.universidades!.isEmpty || _userMeta.universidades!.length > 3) ? "Selecciona de 1 a 3 universidades" : "";
      _errores["aplicacionTest"] = "";
    }else{
      _errores["aplicacionTest"] = _userMeta.aplicacionTest == null || _userMeta.aplicacionTest!.isEmpty ? "Este campo es requerido" : "";
       _errores["carreras"] = "";
      _errores["infoCar"] = "";
      _errores["universidades"] = "";
    }
    setState(() {

    });

    if (_errores["carreras"]!.isEmpty && _errores["infoCar"]!.isEmpty && _errores["aplicacionTest"]!.isEmpty && _errores["universidades"]!.isEmpty) {
      _registrarCarrera();
    }
  }
  void _registrarCarrera() async {
    try {
      setState(() {
        _isInProgress = 0;
      });
      bool bandera = await ApiService().registrarCarrera(_userMeta, _user.id!);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
          _isInProgress = -1;
        });
      } else {
        _user.estado = "Perfil parte 2";
        Provider.of<AppNotifier>(context, listen: false).setUser(_user);
        setState(() {
          _isInProgress = -1;
        });
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
      }
    } on Exception catch (e) {
      setState(() {
        _isInProgress = -1;
        _errores["error"] = e.toString().substring(11);
      });
    }
  }
  DateTime selectedDate = DateTime.now();
  void _onOptionSelectedCarrera(List<ValueItem> selectedOptions) {
    if (selectedOptions.isNotEmpty) {
      List<int> carreras = selectedOptions.map((option) => int.parse(option.value!)).toList();
      setState(() {
        _userMeta.carreras = carreras;
      });
    } else {
      setState(() {
        _userMeta.carreras = [];
      });
    }
  }
  void _onOptionSelectedDepartamento(List<ValueItem> selectedOptions) async {
    if(selectedOptions.isNotEmpty){
      _userMeta.departamentoEstudiar = selectedOptions[0].label;
      _universidades = await ApiService().getUnivesidadeForId(int.parse(selectedOptions[0].value!));
    }else{
      _userMeta.departamentoEstudiar = "";
    }
    setState(() {});
    // Aquí puedes realizar otras acciones con las opciones seleccionadas, si es necesario
  }
  void _onOptionSelectedUniversidad(List<ValueItem> selectedOptions) {
    if (selectedOptions.isNotEmpty) {
      List<String> universidades = selectedOptions.map((option) => option.label).toList();
      setState(() {
        _userMeta.universidades = universidades;
      });
    } else {
      setState(() {
        _userMeta.universidades = [];
      });
    }
  }
  void _onOptionSelectedInfoCar(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.infoCar = selectedOptions[0].label;
    }else{
      _userMeta.infoCar = "";
    }
    setState(() {});
  }
  void _onOptionSelectedDonde(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.aplicacionTest = selectedOptions[0].label;
    }else{
      _userMeta.aplicacionTest = "";
    }
    setState(() {});
  }
  void _onOptionSelectedInfo(List<ValueItem> selectedOptions) {
    if (selectedOptions.isNotEmpty) {
      List<String> recibirInfo = selectedOptions.map((option) => option.label).toList();
      setState(() {
        _userMeta.recibirInfo = recibirInfo;
      });
    } else {
      setState(() {
        _userMeta.recibirInfo = [];
      });
    }
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
                              "📚 Tus preferencias de carrera",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8), // Espacio entre el título y el texto
                        MyText.bodyMedium(
                          'Gracias a esta información recibirás una atención pedagógica adecuada tu perfil.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    '¿Ya hiciste un Test Vocacional?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start, // Alinea los hijos a la izquierda
                                    children: [
                                      ChoiceChip(
                                        checkmarkColor: Colors.white,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        selectedColor: Color.fromRGBO(32, 104, 14, 1),
                                        label: MyText.bodyMedium(
                                          "Si",
                                          color: _userMeta.testVocacional!
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onBackground
                                        ),
                                        selected: _userMeta.testVocacional!,
                                        onSelected: (selected) {
                                          setState(() {
                                            _userMeta.testVocacional = selected; 
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
                                            width: 1.0, // Ancho del borde
                                          ),
                                          borderRadius: BorderRadius.circular(14), // Radio de borde
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      ChoiceChip(
                                        checkmarkColor: Colors.white,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        selectedColor: Color.fromRGBO(32, 104, 14, 1),
                                        label: MyText.bodyMedium(
                                          "No",
                                          color: !_userMeta.testVocacional!
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onBackground
                                        ),
                                        selected: !_userMeta.testVocacional!,
                                        onSelected: (selected) {
                                          setState(() {
                                            _userMeta.testVocacional = !selected; 
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
                                            width: 1.0, // Ancho del borde
                                          ),
                                          borderRadius: BorderRadius.circular(14), // Radio de borde
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if(_userMeta.testVocacional!)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    '¿Dónde de aplicarón el test?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelectedDonde,
                                    options: const <ValueItem>[
                                      ValueItem(label: 'En el colegio', value: '1'),
                                      ValueItem(label: 'En la UPSA', value: '2'),
                                      ValueItem(label: 'Servicio Privado', value: '3'),
                                      ValueItem(label: 'En otra Universidad', value: '4'),
                                    ],
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.single,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                  if (_errores["aplicacionTest"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["aplicacionTest"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if(!_userMeta.testVocacional!)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    'Selecciona hasta tres carreras que te gustaría estudiar(en orden de importancia)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelectedCarrera,
                                    options: _buildValueItems("carreras"),
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.multi,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                  if (_errores["carreras"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["carreras"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if(!_userMeta.testVocacional!)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    '¿Qué tan informado estás sobre tus opciones de carrera?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelectedInfoCar,
                                    options: const <ValueItem>[
                                      ValueItem(label: 'Poco informado', value: '1'),
                                      ValueItem(label: 'Medianamente informado', value: '2'),
                                      ValueItem(label: 'Muy informado', value: '3'),
                                      ValueItem(label: 'Ninguna de las anteriores', value: '4'),
                                    ],
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.single,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                  if (_errores["infoCar"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["infoCar"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if(!_userMeta.testVocacional!)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    '¿Piensas estudiar en Bolivia o en el extranjero?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start, // Alinea los hijos a la izquierda
                                    children: [
                                      ChoiceChip(
                                        checkmarkColor: Colors.white,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        selectedColor: Color.fromRGBO(32, 104, 14, 1),
                                        label: MyText.bodyMedium(
                                          "Bolivia",
                                        color: _userMeta.estudiarBolivia!
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onBackground
                                        ),
                                        selected: _userMeta.estudiarBolivia!,
                                        onSelected: (selected) {
                                          setState(() {
                                            _userMeta.estudiarBolivia = selected; 
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
                                            width: 1.0, // Ancho del borde
                                          ),
                                          borderRadius: BorderRadius.circular(14), // Radio de borde
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      ChoiceChip(
                                        checkmarkColor: Colors.white,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        selectedColor: Color.fromRGBO(32, 104, 14, 1),
                                        label: MyText.bodyMedium(
                                          "Extranjero",
                                        color: !_userMeta.estudiarBolivia!
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onBackground
                                        ),
                                        selected: !_userMeta.estudiarBolivia!,
                                        onSelected: (selected) {
                                          setState(() {
                                            _userMeta.estudiarBolivia = !selected; 
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
                                            width: 1.0, // Ancho del borde
                                          ),
                                          borderRadius: BorderRadius.circular(14), // Radio de borde
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if(!_userMeta.testVocacional! && _userMeta.estudiarBolivia!)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    '¿En qué departamento piensas estudiar?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelectedDepartamento,
                                    options: const <ValueItem>[
                                      ValueItem(label: 'CHUQUISACA', value: '1'),
                                      ValueItem(label: 'LA PAZ', value: '2'),
                                      ValueItem(label: 'ORURO', value: '4'),
                                      ValueItem(label: 'TARIJA', value: '6'),
                                      ValueItem(label: 'SANTA CRUZ', value: '7'),
                                      ValueItem(label: 'PANDO', value: '9'),
                                      ValueItem(label: 'COCHABAMBA', value: '11'),
                                      ValueItem(label: 'POTOSÍ', value: '12'),
                                      ValueItem(label: 'BENI', value: '13'),
                                    ],
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.single,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                ],
                              ),
                            ),
                            if(!_userMeta.testVocacional! && _userMeta.departamentoEstudiar!.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    'Selecciona hasta tres universidades dónde te gustaría estudiar (en orden de importancia)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelectedUniversidad,
                                    options: _buildValueItems("universidades"),
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.multi,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                  if (_errores["universidades"]!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errores["universidades"]!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if(!_userMeta.testVocacional!)
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  MyText.bodyMedium(
                                    '¿Sobre qué aspectos te gustaría recibir información?(selecciona todas que aplican)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  MultiSelectDropDown(
                                    onOptionSelected: _onOptionSelectedInfo,
                                    options: const <ValueItem>[
                                      ValueItem(label: 'Orientación Vocacional', value: '1'),
                                      ValueItem(label: 'Carreras (planes de estudio)', value: '2'),
                                      ValueItem(label: 'Concursos académicos', value: '3'),
                                      ValueItem(label: 'Doble titulación', value: '4'),
                                      ValueItem(label: 'Intercambio estudiantil', value: '5'),
                                      ValueItem(label: 'Ferias cientificas y/o emprendiemiento', value: '6'),
                                      ValueItem(label: 'Actividades deportivas y culturales de la U', value: '7'),
                                      ValueItem(label: 'Financiamiento/créditos/becas', value: '8'),
                                      ValueItem(label: 'Programas de Postgrado', value: '9'),
                                    ],
                                    hint: "- Seleccionar -",
                                    selectionType: SelectionType.multi,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: Color.fromRGBO(32, 104, 14, 1)),
                                    optionTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
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
                  )
                ]
              ),
              if (_isInProgress == 0)
              Positioned.fill(
                child: ProgressEspera(
                  theme: theme, // Pasar el tema como argumento
                ),
              ),
            ]
          )
        ),
      );
    } 
  }
  List<ValueItem> _buildValueItems(String tipo) {
    if(tipo == "carreras"){
      return _carreras.map((promocion) {
      return ValueItem(
        label: promocion.nombre!,
        value: promocion.id.toString(),
      );
    }).toList();
    }else{
      if(tipo == "universidades"){
        return _universidades.map((universidad) {
        return ValueItem(
          label: universidad.nombre!,
          value: universidad.id,
        );
        }).toList();
      }else{
        return [];
      }
    }
  }
}
