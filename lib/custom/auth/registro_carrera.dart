import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/universidad.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
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
  int _idDepartamento = 1;
  final Map<String, String> _errores = {
    "carreras": "",
    "informacionCarrera": "",
    "aplicacionTest": "",
    "universidades": "",
    "universidadExtranjera": "",
    "departamento": "",
  };
  List<Carrera> _carreras = [];
  List<Universidad> _universidades = [];
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
    _user = await ApiService().getUserPopulateConMetasParaFormularioCarrera(_user.id!);
    _carreras = await ApiService().getCarreras();
    _userMeta = _user.userMeta!;
    for (var item in _userMeta.universidades!) {
      _idDepartamento = item.idDepartamento!;
      _universidades = await ApiService().getUnivesidadeForId(item.idDepartamento!);
      break;
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    if(_userMeta.testVocacional!){
      _errores["aplicacionTest"] = _userMeta.aplicacionTest!.isEmpty ? "Este campo es requerido" : "";
    }else{
      _errores["aplicacionTest"] = "";
      _userMeta.aplicacionTest = "";
    }
    if(_userMeta.estudiarEnBolivia!){
      _errores["departamento"] = _userMeta.departamentoUniversidad!.isEmpty ? "Este campo es requerido" : "";
      _errores["universidadExtranjera"] = "";
      _userMeta.universidadExtranjera = "";
    }else{
      _errores["universidadExtranjera"] = _userMeta.universidadExtranjera!.isEmpty ? "Este campo es requerido" : "";
      _errores["departamento"] = "";
      _userMeta.departamentoUniversidad = "";
    }
    if(_userMeta.departamentoUniversidad!.isNotEmpty){
      _errores["universidades"] = (_userMeta.universidades!.isEmpty || _userMeta.universidades!.length > 3) ? "Selecciona de 1 a 3 universidades" : "";
    }else{
      _errores["universidades"] = "";
      _userMeta.universidades = [];
    }
    _errores["carreras"] =(_userMeta.carreras!.isEmpty || _userMeta.carreras!.length > 3) ? "Selecciona de 1 a 3 carreras" : "";
    _errores["informacionCarrera"] = _userMeta.informacionCarrera!.isEmpty ? "Este campo es requerido" : "";

    setState(() {

    });

    if (_errores["carreras"]!.isEmpty && _errores["informacionCarrera"]!.isEmpty && _errores["aplicacionTest"]!.isEmpty && _errores["universidades"]!.isEmpty) {
      _registrarCarrera();
    }
  }
  void _registrarCarrera() async {
    try {
      setState(() {
        _isInProgress = 0;
      });
      bool bandera = await ApiService().registrarCarrera(_userMeta, _user);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
          _isInProgress = -1;
        });
      } else {
        if(_user.estado == "Completado"){
          setState(() {
            _isInProgress = -1;
          });
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
        }else{
          _user.estado = "Perfil parte 2";
          Provider.of<AppNotifier>(context, listen: false).setUser(_user);
          setState(() {
            _isInProgress = -1;
          });
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
        }
      }
    } on Exception catch (e) {
      setState(() {
        _isInProgress = -1;
        _errores["error"] = e.toString().substring(11);
      });
    }
  }
  void _onOptionSelectedCarrera(List<ValueItem> selectedOptions) {
    _userMeta.carreras = [];
    if (selectedOptions.isNotEmpty) {
      for (var opcion in selectedOptions) {
        Carrera aux = Carrera(
          id: int.parse(opcion.value!),
          nombre: opcion.label
        );
        _userMeta.carreras!.add(aux);
      }
      setState(() {
      });
    } else {
      setState(() {
        _userMeta.carreras = [];
      });
    }
  }
  void _onOptionSelectedDepartamento(List<ValueItem> selectedOptions) async {
    if(selectedOptions.isNotEmpty){
      _idDepartamento = int.parse(selectedOptions[0].value!);
      _userMeta.departamentoUniversidad = selectedOptions[0].label;
      _userMeta.universidades = [];
      _universidades = await ApiService().getUnivesidadeForId(int.parse(selectedOptions[0].value!));
    }else{
      _userMeta.departamentoUniversidad = "";
    }
    setState(() {});
  }
  void _onOptionSelectedUniversidad(List<ValueItem> selectedOptions) {
    if (selectedOptions.isNotEmpty) {
      _userMeta.universidades = [];
      for (var opcion in selectedOptions) {
        Universidad aux = Universidad(
          nombre: opcion.label,
          idDepartamento: _idDepartamento,
        );
        _userMeta.universidades!.add(aux);
      }
      setState(() {
      });
    } else {
      setState(() {
        _userMeta.universidades = [];
      });
    }
  }
  void _onOptionSelectedinformacionCarrera(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.informacionCarrera = selectedOptions[0].label;
    }else{
      _userMeta.informacionCarrera = "";
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
      _userMeta.recibirInformacion = [];
      for (var item in selectedOptions) {
        Map<String, dynamic> aux = {
          "titulo": item.label,
        };
        _userMeta.recibirInformacion!.add(aux);
      }
      setState(() {
      });
    } else {
      setState(() {
        _userMeta.recibirInformacion = [];
      });
    }
  }
  List<ValueItem> _armarSelectedOptions(String  meta){
    List<ValueItem> res = [];
    if(meta == "recibirInformacion"){
      for (var item in _userMeta.recibirInformacion!) {
        ValueItem aux = ValueItem(
          label: item["titulo"]
        );
        res.add(aux);
      }
    }
    if(meta == "universidades"){
      for (var item in _userMeta.universidades!) {
        ValueItem aux = ValueItem(
          label: item.nombre!,
        );
        res.add(aux);
      }
    }
    if(meta == "departamentoUniversidad"){
      if(_userMeta.departamentoUniversidad!.isNotEmpty){
        if (_userMeta.departamentoUniversidad! == "CHUQUISACA") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '1');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "LA PAZ") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '2');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "ORURO") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '4');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "TARIJA") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '6');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "SANTA CRUZ") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '7');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "PANDO") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '9');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "COCHABAMBA") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '11');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "POTOSÍ") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '12');
          
          res.add(aux);
        } else if (_userMeta.departamentoUniversidad! == "BENI") {
          ValueItem aux = ValueItem(label: _userMeta.departamentoUniversidad!, value: '13');
          
          res.add(aux);
        }
      }
    }
    if(meta == "informacionCarrera"){
      if(_userMeta.informacionCarrera!.isNotEmpty){
        ValueItem aux = ValueItem(label: _userMeta.informacionCarrera!);
        res.add(aux);
      }
    }
    if(meta == "aplicacionTest"){
      if(_userMeta.aplicacionTest!.isNotEmpty){
        ValueItem aux = ValueItem(label: _userMeta.aplicacionTest!);
        res.add(aux);
      }
    }
    if(meta == "carreras"){
      if(_userMeta.carreras!.isNotEmpty){
        for (var item in _userMeta.carreras!) {
          ValueItem aux = ValueItem(
            value: item.id.toString(),
            label: item.nombre!,
          );
          res.add(aux);
        }
      }
    }
    return res;
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
        backgroundColor: AppColorStyles.verdeFondo,
        appBar: AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          leading: IconButton(
            icon: Icon(
              LucideIcons.chevronLeft,
              color: AppColorStyles.oscuro1
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(bottom: 30),
                    child: Column(     
                      children: <Widget>[
                        _crearTitulo(),
                        _crearDescripcion(),
                        _crearCampoOpcion("¿Ya hiciste un Test Vocacional?", "Si", "No", _userMeta.testVocacional!, _userMeta.testVocacional!, "testVocacional"),
                        _crearCampoSelectorOpcional('¿Dónde de aplicarón el test?', _userMeta.testVocacional!, _errores["aplicacionTest"]!, "aplicacionTest"),
                        _crearCampoSelectorMulti('Selecciona hasta tres carreras que te gustaría estudiar(en orden de importancia)', _userMeta.carreras!, _errores["carreras"]!, "carreras"),
                        _crearCampoSelectorMulti('¿Qué tan informado estás sobre tus opciones de carrera?', _userMeta.informacionCarrera!, _errores["informacionCarrera"]!, "informacionCarrera"),
                        _crearCampoOpcion('¿Piensas estudiar en Bolivia o en el extranjero?', "Bolivia", "Extranjero", _userMeta.estudiarEnBolivia!, _userMeta.estudiarEnBolivia!, "estudiarEnBolivia"),
                        _crearCampoTextoOpcional('Nombre de la Universidad', _userMeta.universidadExtranjera!, !_userMeta.estudiarEnBolivia!, _errores["universidadExtranjera"]!, "universidadExtranjera"),
                        _crearCampoSelectorOpcional('¿En qué departamento piensas estudiar?', _userMeta.estudiarEnBolivia!, _errores["departamento"]!, "departamentoUniversidad"),
                        _crearCampoSelectorMultiOpcional('Selecciona hasta tres universidades dónde te gustaría estudiar (en orden de importancia)', _userMeta.estudiarEnBolivia! && _userMeta.departamentoUniversidad!.isNotEmpty, _errores["universidades"]!, "universidades"),
                        _crearCampoSelectorMulti('¿Sobre qué aspectos te gustaría recibir información?(selecciona todas que aplican)', _userMeta.recibirInformacion!, "", "recibirInformacion"),
                        _crearBoton(),
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
  
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: () {
         _validarCampos();
        },
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Continuar',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearCampoSelectorMultiOpcional(String label, bool condicion, String error, String campo){
    List<ValueItem> opciones = [];
    List<ValueItem> opcionesSeleccionadas = [];
    if(campo == "universidades"){
      opciones = _buildValueItems("universidades");
      opcionesSeleccionadas = _armarSelectedOptions("universidades");
    }
    return Visibility(
      visible: condicion,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColorStyles.gris1,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    decoration: AppDecorationStyle.campoContainerForm(),
                    child: MultiSelectDropDown(
                      onOptionSelected: (selectedOptions) {
                        if (campo == "universidades") {
                          _onOptionSelectedUniversidad(selectedOptions);
                        }
                      },
                      options: opciones,
                      hint: "- Seleccionar -",
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: AppColorStyles.verde2),
                      selectedOptionIcon: const Icon(Icons.check_circle, color: AppColorStyles.verde2),
                      selectedOptionTextColor: AppColorStyles.oscuro1,
                      selectedOptionBackgroundColor: AppColorStyles.verdeFondo,
                      optionTextStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
                      borderRadius: 14,
                      borderColor: AppColorStyles.blancoFondo,
                      selectedOptions: opcionesSeleccionadas,
                    ),
                  ),
                ],
              ),
            ),
            if (error.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _crearCampoTextoOpcional(String label, String valor, bool condicion, String error, String campo){
    return Visibility(
      visible: condicion,
      child: Container(
        margin: EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColorStyles.gris1,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    decoration: AppDecorationStyle.campoContainerForm(),
                    child: TextFormField(
                      initialValue: valor,
                      onChanged: (value) {
                        setState(() {
                          _userMeta.universidadExtranjera = value;
                        });
                      },
                      decoration: AppDecorationStyle.campoTextoForm(hintText: "", labelText: ""),
                      style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
                    ),
                  ),
                ]
              )
            ),
            if (error.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _crearCampoSelectorMulti(String label, dynamic valor, String error, String campo){
    List<ValueItem> opciones = [];
    List<ValueItem> opcionesSeleccionadas = [];
    if(campo == "carreras"){
      opciones =  _buildValueItems("carreras");
      opcionesSeleccionadas = _armarSelectedOptions("carreras");
    }
    if(campo == "informacionCarrera"){
      opciones =  [
        ValueItem(label: 'Poco informado'),
        ValueItem(label: 'Medianamente informado'),
        ValueItem(label: 'Muy informado'),
        ValueItem(label: 'Ninguna de las anteriores'),
      ];
      opcionesSeleccionadas = _armarSelectedOptions("informacionCarrera");
    }
    if(campo == "recibirInformacion"){
      opciones =  [
        ValueItem(label: 'Orientación Vocacional'),
        ValueItem(label: 'Carreras (planes de estudio)'),
        ValueItem(label: 'Concursos académicos'),
        ValueItem(label: 'Doble titulación'),
        ValueItem(label: 'Intercambio estudiantil'),
        ValueItem(label: 'Ferias cientificas y/o emprendiemiento'),
        ValueItem(label: 'Actividades deportivas y culturales de la U'),
        ValueItem(label: 'Financiamiento/créditos/becas'),
        ValueItem(label: 'Programas de Postgrado'),
      ];
      opcionesSeleccionadas = _armarSelectedOptions("recibirInformacion");
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: AppColorStyles.gris1,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorationStyle.campoContainerForm(),
            child: MultiSelectDropDown(
              onOptionSelected: (selectedOptions) {
                if (campo == "carreras") {
                   _onOptionSelectedCarrera(selectedOptions);
                }
                if (campo == "informacionCarrera") {
                   _onOptionSelectedinformacionCarrera(selectedOptions);
                }
                if (campo == "recibirInformacion") {
                   _onOptionSelectedInfo(selectedOptions);
                }
              },
              options: opciones,
              hint: "- Seleccionar -",
              selectionType: SelectionType.multi,
              chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: AppColorStyles.verde2),
              selectedOptionIcon: const Icon(Icons.check_circle, color: AppColorStyles.verde2),
              selectedOptionTextColor: AppColorStyles.oscuro1,
              selectedOptionBackgroundColor: AppColorStyles.verdeFondo,
              optionTextStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
              borderRadius: 14,
              borderColor: AppColorStyles.blancoFondo,
              selectedOptions: opcionesSeleccionadas,
            ),
          ),
          if (error.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
  Widget _crearCampoSelectorOpcional(String label, bool condicion, String error, String campo){
    List<ValueItem> opciones = [];
    List<ValueItem> opcionesSeleccionadas = [];
    if(campo == "aplicacionTest"){
      opciones = [
        ValueItem(label: 'En el colegio'),
        ValueItem(label: 'En la UPSA'),
        ValueItem(label: 'Servicio Privado'),
        ValueItem(label: 'En otra Universidad'),
      ];
      opcionesSeleccionadas = _armarSelectedOptions("aplicacionTest");
    }
    if(campo == "departamentoUniversidad"){
      opciones = [
        ValueItem(label: 'CHUQUISACA', value: '1'),
        ValueItem(label: 'LA PAZ', value: '2'),
        ValueItem(label: 'ORURO', value: '4'),
        ValueItem(label: 'TARIJA', value: '6'),
        ValueItem(label: 'SANTA CRUZ', value: '7'),
        ValueItem(label: 'PANDO', value: '9'),
        ValueItem(label: 'COCHABAMBA', value: '11'),
        ValueItem(label: 'POTOSÍ', value: '12'),
        ValueItem(label: 'BENI', value: '13'),
      ];
      opcionesSeleccionadas = _armarSelectedOptions("departamentoUniversidad");
    }
    return Visibility(
      visible: condicion,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColorStyles.gris1,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    decoration: AppDecorationStyle.campoContainerForm(),
                    child: MultiSelectDropDown(
                      onOptionSelected: (selectedOptions) {
                        if (campo == "aplicacionTest") {
                          _onOptionSelectedDonde(selectedOptions);
                        }
                        if (campo == "departamentoUniversidad") {
                          _onOptionSelectedDepartamento(selectedOptions);
                        }
                      },
                      options: opciones,
                      hint: "- Seleccionar -",
                      selectionType: SelectionType.single,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: AppColorStyles.verde2),
                      selectedOptionIcon: const Icon(Icons.check_circle, color: AppColorStyles.verde2),
                      selectedOptionTextColor: AppColorStyles.oscuro1,
                      selectedOptionBackgroundColor: AppColorStyles.verdeFondo,
                      optionTextStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
                      borderRadius: 14,
                      borderColor: AppColorStyles.blancoFondo,
                      selectedOptions: opcionesSeleccionadas,
                    ),
                  ),
                ],
              ),
            ),
            if (error.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _crearCampoOpcion(String label, String opcion1, String opcion2, bool opcionValue1, bool opcionValue2, String campo){
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: AppColorStyles.gris1,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Alinea los hijos a la izquierda
            children: [
              ChoiceChip(
                backgroundColor: AppColorStyles.blancoFondo,
                avatar: opcionValue1 ? Icon(Icons.check_circle_outline) : Icon(Icons.circle_outlined),
                checkmarkColor: AppColorStyles.blancoFondo,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: AppColorStyles.verde2,
                label: Text(
                  opcion1,
                  style: TextStyle(
                    color: opcionValue1
                    ? AppColorStyles.blancoFondo
                    : AppColorStyles.verde2
                  ),
                ),
                selected: opcionValue1,
                onSelected: (selected) {
                  if(campo == "testVocacional"){
                    _userMeta.testVocacional = selected; 
                  }
                  if(campo == "estudiarEnBolivia"){
                    _userMeta.estudiarEnBolivia = selected; 
                  }
                  setState(() {});
                },
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColorStyles.verde2, // Color del borde
                    width: 1.0, // Ancho del borde
                  ),
                  borderRadius: BorderRadius.circular(14), // Radio de borde
                ),
              ),
              SizedBox(width: 8.0),
              ChoiceChip(
                backgroundColor: AppColorStyles.blancoFondo,
                avatar: !opcionValue2 ? Icon(Icons.check_circle_outline) : Icon(Icons.circle_outlined),
                checkmarkColor: AppColorStyles.blancoFondo,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: AppColorStyles.verde2,
                label: Text(
                  opcion2,
                  style: TextStyle(
                    color: !opcionValue2
                    ? AppColorStyles.blancoFondo
                    : AppColorStyles.verde2
                  ),
                ),
                selected: !opcionValue2,
                onSelected: (selected) {
                  if(campo == "testVocacional"){
                    _userMeta.testVocacional = !selected; 
                  }
                  if(campo == "estudiarEnBolivia"){
                    _userMeta.estudiarEnBolivia = !selected; 
                  }
                  setState(() {});
                },
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColorStyles.verde2, // Color del borde
                    width: 1.0, // Ancho del borde
                  ),
                  borderRadius: BorderRadius.circular(14), // Radio de borde
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _crearDescripcion(){
    return Container( 
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          '¿Qué piensas estudiar? Seleccioná tus preferencias.',
          style: TextStyle(
            color: AppColorStyles.oscuro1,
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
        ),
    );
  }
  Widget _crearTitulo() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        "Tus preferencias de carrera",
        style: AppTitleStyles.onboarding(color: AppColorStyles.verde1),
      ),
    );
  }
  List<ValueItem> _buildValueItems(String tipo) {
    List<ValueItem> res = [];
    if(tipo == "carreras"){
      for (var item in _carreras) {
        res.add(
          ValueItem(
            label: item.nombre!,
            value: item.id.toString(),
          )
        );  
      }
    }
    if(tipo == "universidades"){
      for (var item in _universidades) {
        res.add(
          ValueItem(
            label: item.nombre!
          )
        );
      }

    }
    return res;
  }
}