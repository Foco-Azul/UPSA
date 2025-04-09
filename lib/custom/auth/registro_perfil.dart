import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/models/colegio.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:intl/intl.dart';
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
import 'package:search_choices/search_choices.dart';

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
    "promo": "",
  };
  List<Colegio> _colegios = [];
  late AnimacionCarga _animacionCarga;
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic> _campoPromo = {};

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
    _campoPromo = await ApiService().getCampoPersonalziadoJson(2); 
    _userMeta = _user.userMeta!;
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    setState(() {
      _errores["nombres"] = validacion.validarNombres(_userMeta.nombres, true);
      _errores["apellidos"] = validacion.validarNombres(_userMeta.apellidos, true);
      _errores["cedulaDeIdentidad"] = validacion.validarAlfanumericos(FuncionUpsa.eliminarEspaciosInicioFin(_userMeta.cedulaDeIdentidad), true);
      _errores["celular1"] = validacion.validarCelular(_userMeta.celular1, true);
      if (_userMeta.colegio!.id! != -1){
        _errores["colegio"] = "";
      }else{
        _errores["colegio"] = "Selecciona una opción";
      }
      if(_userMeta.fechaDeNacimiento == null || _userMeta.fechaDeNacimiento!.isEmpty){
        _errores["fechaDeNacimiento"] = "Este campo es requerido";
      }else{
        _errores["fechaDeNacimiento"] = "";
      }
      if (_userMeta.promo!.isNotEmpty){
        _errores["promo"] = "";
      }else{
        _errores["promo"] = "Selecciona una opción";
      }
    });

    if (_errores["nombres"]!.isEmpty && _errores["apellidos"]!.isEmpty && _errores["cedulaDeIdentidad"]!.isEmpty && _errores["celular1"]!.isEmpty && _errores["colegio"]!.isEmpty && _errores["promo"]!.isEmpty) {
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
              primary: AppColorStyles.altVerde1, // header background color
              onPrimary: AppColorStyles.blanco, // header text color
              onSurface: AppColorStyles.altTexto1, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColorStyles.altTexto1, // button text color
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

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getCouponLoadingScreen(
            context,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColorStyles.altFondo1,
        appBar: AppBar(
          backgroundColor: AppColorStyles.altFondo1,
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
                    _crearCampoSelectorSimple(_campoPromo["attributes"]["label"], _errores["promo"]!, "promo"),
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
    List<DropdownMenuItem<dynamic>> items = [];
    List<int> selectedItems = []; 
    int pos = 0;
    if(campo == "curso"){
      items.add(
        DropdownMenuItem(
          value: "0-4º Secundaria", // El valor asociado a esta opción
          child: Text('4º Secundaria', style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
        ),
      );
      items.add(
        DropdownMenuItem(
          value: "1-5º Secundaria", // El valor asociado a esta opción
          child: Text('5º Secundaria', style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
        ),
      );
      items.add(
        DropdownMenuItem(
          value: "2-6º Secundaria", // El valor asociado a esta opción
          child: Text('6º Secundaria', style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
        ),
      );
      if(_userMeta.curso! == '4º Secundaria'){
        selectedItems.add(0);
      }else{
        if(_userMeta.curso! == '5º Secundaria'){
          selectedItems.add(1);
        }else{
          if(_userMeta.curso! == '6º Secundaria'){
            selectedItems.add(2);
          }
        }
      }
    }
    pos = 0;
    if(campo == "promo"){
      for (var opcion in _campoPromo["attributes"]["opciones"]) {
        items.add(
          DropdownMenuItem(
            value: "$pos-${opcion["opcion"]}", // El valor asociado a esta opción
            child: Text(opcion["opcion"]!, style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
          ),
        );
        if(_userMeta.promo == opcion["opcion"]){
          selectedItems.add(pos);
        }
        pos++;
      }
    }
    pos = 0;
    if(campo == "colegio"){
      for (var colegio in _colegios) {
        items.add(
          DropdownMenuItem(
            value: "${colegio.id}-${colegio.nombre}", // El valor asociado a esta opción
            child: Text(colegio.nombre!, style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
          ),
        );
        if(_userMeta.colegio!.id == colegio.id){
          selectedItems.add(pos);
        }
        pos++;
      }
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorationStyle.campoContainerForm(),
            child: SearchChoices.multiple(
              menuBackgroundColor: AppColorStyles.blanco,
              fieldDecoration: BoxDecoration(
                border: Border.all(color: Colors.transparent), // Esto elimina el borde
              ),
              items: items,
              selectedItems: selectedItems,
              hint: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(label, style: AppTextStyles.parrafo(),),
              ),
              searchHint: "Selecciona una opcion",
              onChanged: (value) {
                setState(() {
                  if(campo == "promo"){
                    if(value.length > 0){
                      List<String> aux = (items[value[value.length - 1]].value.toString()).split("-");
                      _userMeta.promo = aux[1];
                    }else{
                      _userMeta.promo = "";
                      selectedItems = [];
                    }
                  }
                  if(campo == "colegio"){
                    if(value.length > 0){
                      List<String> aux = (items[value[value.length - 1]].value.toString()).split("-");
                      _userMeta.colegio = Colegio(
                        id: int.parse(aux[0]),
                        nombre: aux[1],
                      );
                    }else{
                      _userMeta.colegio = Colegio();
                      selectedItems = [];
                    }
                  }
                });
              },
              closeButton: "Guardar",
              doneButton: "Guardar",
              displayClearIcon: false,
              isExpanded: true,
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
                  backgroundColor: AppColorStyles.altTexto1,
                  child: Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: AppColorStyles.blanco,
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
        style: AppDecorationStyle.botonBienvenida(colorFondo: AppColorStyles.altVerde1),
        child: Text(
          'Continuar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.oscuro1),  // Estilo del texto del botón
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
              textCapitalization: TextCapitalization.words, // Para capitalizar cada palabra
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
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      alignment: Alignment.centerLeft,
      child: Text(
        'Registrar tus datos aquí te permitirá inscribirte fácilmente a nuestros talleres, clubes y eventos exclusivos. ',
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
        "Llenemos tu perfil",
        style: AppTitleStyles.onboarding(color: AppColorStyles.altTexto1),
      ),
    );
  }
}