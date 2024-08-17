import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/models/colegio.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:intl/intl.dart';
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
  final Map<String, String> _errores = {
    "nombres": "",
    "apellidos": "",
    "cedulaDeIdentidad": "",
    "fechaDeNacimiento": "",
    "celular1": "",
    "colegio": "",
    "curso": "",
  };
  List<Colegio> _colegios = [];
  late AnimacionCarga _animacionCarga;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    controller = ProfileController();
    selectedDate = DateTime.now();
    _animacionCarga = AnimacionCarga(context: context);
    cargarDatos();
  }
  void cargarDatos() async{
    _user = Provider.of<AppNotifier>(context, listen: false).user;
    _user = await ApiService().getUserPopulateConMetasParaFormularioPerfil(_user.id!);
    _colegios = await ApiService().getColegios();
    _userMeta = _user.userMeta!;
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    setState(() {
      _errores["nombres"] = validacion.validarNombres(_userMeta.nombres, true);
      _errores["apellidos"] = validacion.validarNombres(_userMeta.apellidos, true);
      _errores["cedulaDeIdentidad"] = validacion.validarNumerosPositivos(_userMeta.cedulaDeIdentidad, true, true);
      _errores["celular1"] = validacion.validarCelular(_userMeta.celular1, true);
      if (_userMeta.colegio!.id! != -1){
        _errores["colegio"] = "";
      }else{
        _errores["colegio"] = "Selecciona una opción";
      }
      if(_userMeta.fechaDeNacimiento == null){
        _errores["fechaDeNacimiento"] = "Este campo es requerido";
      }else{
        _errores["fechaDeNacimiento"] = "";
      }
      if (_userMeta.curso!.isNotEmpty){
        _errores["curso"] = "";
      }else{
        _errores["curso"] = "Selecciona una opción";
      }
    });

    if (_errores["nombres"]!.isEmpty && _errores["apellidos"]!.isEmpty && _errores["cedulaDeIdentidad"]!.isEmpty && _errores["celular1"]!.isEmpty && _errores["colegio"]!.isEmpty && _errores["curso"]!.isEmpty) {
      _registrarEstudiante();
    }
  }
  void _registrarEstudiante() async {
    try {
      _animacionCarga.setMostrar(true);
      bool bandera = await ApiService().registrarPerfil(_userMeta, _user.id!);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
        });
      } else {
        _user.estado = "Perfil parte 1";
        Provider.of<AppNotifier>(context, listen: false).setUser(_user);
        _animacionCarga.setMostrar(false);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
      }
    } on Exception catch (e) { 
      _animacionCarga.setMostrar(false);
      setState(() {
        _errores["error"] = e.toString().substring(11);
      });
    }
  }
  _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        locale: const Locale("es"),
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2005),
        lastDate: DateTime.now(),
        builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColorStyles.verde2, // header background color
              onPrimary: AppColorStyles.oscuro1, // header text color
              onSurface: AppColorStyles.verde2, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColorStyles.verde2, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },);
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _userMeta.fechaDeNacimiento = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  List<ValueItem> _armarSelectedOptions(String  tipo){
    List<ValueItem> res = [];
    if(tipo == "curso"){
      if(_userMeta.curso!.isNotEmpty){
        ValueItem aux = ValueItem(
          label: _userMeta.curso!,
        );
        res.add(aux);
      }
    }
    if(tipo == "colegio"){
      if(_userMeta.colegio!.nombre!.isNotEmpty){
        ValueItem aux = ValueItem(
          label: _userMeta.colegio!.nombre!,
          value: _userMeta.colegio!.id.toString(),
        );
        res.add(aux);
      }
    }
    return res;
  }
  void _onOptionSelectedCurso(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.curso = selectedOptions[0].label;
    }else{
      _userMeta.curso = "";
    }
    setState(() {});
  }
  void _onOptionSelectedColegio(List<ValueItem> selectedOptions) {
    if(selectedOptions.isNotEmpty){
      _userMeta.colegio = Colegio(
        id: int.parse(selectedOptions[0].value!),
        nombre: selectedOptions[0].label,
      );
    }else{
      _userMeta.colegio = Colegio();
    }
    setState(() {});
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
              Container(
                margin: EdgeInsets.all(15),
                child: Column(     
                  children: <Widget>[
                    _crearTitulo(),
                    _crearDescripcion(),
                    _crearCampoConError(_errores["nombres"]!, _userMeta.nombres!, "Nombre(s)", "", "nombres"),
                    _crearCampoConError(_errores["apellidos"]!, _userMeta.apellidos!,"Apellido(s)", "", "apellidos"),
                    _crearCampoConIcono(),
                    _crearCampoConError2(_errores["celular1"]!, _userMeta.celular1!,"Número de teléfono", "", "celular1"),
                    _crearCampoConError(_errores["cedulaDeIdentidad"]!, _userMeta.cedulaDeIdentidad!, "Cédula de identidad", "", "cedulaDeIdentidad"),
                    _crearCampoSelectorSimple('¿En que curso de secundaria estás?', _errores["curso"]!, "curso"),
                    _crearCampoSelectorSimple('Colegio', _errores["colegio"]!, "colegio"),
                    _crearBoton(),
                  ]
                )
              ),
            ]
          ),
        )
      );
    } 
  }
  Widget _crearCampoSelectorSimple(String label, String error, String campo){
    List<ValueItem> opciones = [];
    List<ValueItem> opcionesSeleccionadas = [];
    if(campo == "curso"){
      opciones =  [
        ValueItem(label: '4º Secundaria'),
        ValueItem(label: '5º Secundaria'),
        ValueItem(label: '6º Secundaria'),
      ];
      opcionesSeleccionadas = _armarSelectedOptions("curso");
    }
    if(campo == "colegio"){
      for (var item in _colegios) {
        opciones.add(ValueItem(label: item.nombre!, value: item.id!.toString()));
      }
      opcionesSeleccionadas = _armarSelectedOptions("colegio");
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorationStyle.campoContainerForm(),
            child: MultiSelectDropDown(
              onOptionSelected: (selectedOptions) {
                if (campo == "curso") {
                  _onOptionSelectedCurso(selectedOptions);
                }
                if (campo == "colegio") {
                  _onOptionSelectedColegio(selectedOptions);
                }
              },
              options: opciones,
              hint: label,
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
  Widget _crearCampoConIcono(){
    return  Container(
      margin: EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: AppDecorationStyle.campoContainerForm(),
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _userMeta.fechaDeNacimiento),
                    decoration: AppDecorationStyle.campoTextoForm(hintText: "", labelText: "Fecha de nacimiento"),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                child: MyButton(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  onPressed: () {
                    _pickDate(context);
                  },
                  elevation: 0,
                  borderRadiusAll: 4,
                  backgroundColor: AppColorStyles.verde1,
                  child: Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: AppColorStyles.blancoFondo,
                  ),
                ),
              ),
            ],
          ),
          if (_errores["fechaDeNacimiento"]!.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              _errores["fechaDeNacimiento"]!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 15, bottom: 60),
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
  Widget _crearCampoConError2(String error, String value, String labelText, String hintText, String campo){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Container(
                width: 70,
                decoration: AppDecorationStyle.campoContainerForm(),
                child: TextFormField(
                  readOnly: true,
                  initialValue: "+591",
                  onChanged: (value) {
                  },
                  decoration: AppDecorationStyle.campoTextoForm(hintText: "hintText", labelText: ""),  
                  style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                ),
              ),
              SizedBox(width: 10), // Para agregar un espacio entre los campos
              Expanded(
                child: Container(
                  decoration: AppDecorationStyle.campoContainerForm(),
                  child: TextFormField(
                    initialValue: value,
                    onChanged: (value) {
                      if (campo == "nombres") {
                        _userMeta.nombres = value;
                      }
                      if (campo == "apellidos") {
                        _userMeta.apellidos = value;
                      }
                      if (campo == "celular1") {
                        _userMeta.celular1 = value;
                      }
                      if (campo == "cedulaDeIdentidad") {
                        _userMeta.cedulaDeIdentidad = value;
                      }
                      setState(() {});
                    },
                    decoration: AppDecorationStyle.campoTextoForm(hintText: hintText, labelText: labelText),  
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                  ),
                ),
              ),
            ],
          ),
          if (error.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
    );
  }
  Widget _crearCampoConError(String error, String value, String labelText, String hintText, String campo){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: AppDecorationStyle.campoContainerForm(),
            child: TextFormField(
              initialValue: value,
              onChanged: (value) {
                if(campo == "nombres"){
                  _userMeta.nombres = value;
                }
                if(campo == "apellidos"){
                  _userMeta.apellidos = value;
                }
                if(campo == "celular1"){
                  _userMeta.celular1 = value;
                }
                if(campo == "cedulaDeIdentidad"){
                  _userMeta.cedulaDeIdentidad = value;
                }
                setState(() {});
              },
              decoration: AppDecorationStyle.campoTextoForm(hintText: hintText, labelText: labelText),  
              style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
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
          )
        ],
      ),
    );
  }
  Widget _crearDescripcion(){
    return Text(
      'Tus datos permitirán que podás inscribirte en nuestros eventos, test vocacionales, entre otros.',
      style: TextStyle(
        color: AppColorStyles.oscuro1,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ),
    );
  }
  Widget _crearTitulo() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        "Llenemos tu perfil",
        style: AppTitleStyles.onboarding(color: AppColorStyles.verde1),
      ),
    );
  }
}