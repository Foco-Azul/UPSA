import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/models/carrera.dart';
import 'package:flutkit/custom/models/universidad.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/homes/homes_screen.dart';
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
  final Map<String, String> _errores = {
    "carreras": "",
    "informacionCarrera": "",
    "aplicacionTest": "",
    "universidad": "",
    "universidadExtranjera": "",
    "departamento": "",
  };
  List<Carrera> _carreras = [];
  List<Universidad> _universidades = [];
  List<String> _opcionesRecibirInformacion = [];
  late AnimacionCarga _animacionCarga;


  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    controller = ProfileController();
    _animacionCarga = AnimacionCarga(context: context);
    cargarDatos();
  }

  void cargarDatos() async{
    _user = Provider.of<AppNotifier>(context, listen: false).user;
    _user = await ApiService().getUserPopulateConMetasParaFormularioCarrera(_user.id!);
    _opcionesRecibirInformacion = await ApiService().getCampoPersonalziado(1); 
    _carreras = await ApiService().getCarreras();
    _universidades = await ApiService().getUniversidadesPopulate();
    _userMeta = _user.userMeta!;
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
    _errores["carreras"] =(_userMeta.carreras!.isEmpty || _userMeta.carreras!.length > 2) ? "Selecciona de 1 a 2 carreras" : "";
    _errores["universidad"] = _userMeta.universidad!.id! == -1 ? "Este campo es requerido" : "";

    setState(() {

    });

    if (_errores["carreras"]!.isEmpty && _errores["aplicacionTest"]!.isEmpty && _errores["universidad"]!.isEmpty) {
      _registrarCarrera();
    }
  }
  void _registrarCarrera() async {
    try {
      _animacionCarga.setMostrar(true);
      bool bandera = await ApiService().registrarCarrera(_userMeta, _user);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
        });
      } else {
        _animacionCarga.setMostrar(false);
        if(_user.estado == "Completado"){
          setState(() {
          });
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
        }else{
          _user.estado = "Perfil parte 2";
          Provider.of<AppNotifier>(context, listen: false).setUser(_user);
          setState(() {
          });
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
        }
      }
    } on Exception catch (e) {
      _animacionCarga.setMostrar(false);
      setState(() {
        _errores["error"] = e.toString().substring(11);
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
                        _crearCampoSelectorSimpleOpcional('¿Dónde de aplicarón el test?', _userMeta.testVocacional!, _errores["aplicacionTest"]!, "aplicacionTest"),
                        _crearCampoSelectorMulti('Seleccioná hasta dos carreras que te gustaría estudiar(en orden de importancia)', _userMeta.carreras!, _errores["carreras"]!, "carreras"),
                        _crearCampoSelectorSimple('Seleccioná la universidad dónde te gustaría estudiar (en orden de importancia)', _userMeta.universidad!, _errores["universidad"]!, "universidad"),
                        _crearCampoSelectorMulti('¿Sobre qué aspectos te gustaría recibir información?(seleccioná todas las que aplican)', _userMeta.recibirInformacion!, "", "recibirInformacion"),
                        _crearBoton(),
                      ]
                    )
                  )
                ]
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
        style: AppDecorationStyle.botonBienvenida(colorFondo: AppColorStyles.altVerde1),
        child: Text(
          'Continuar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.oscuro1), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearCampoSelectorMulti(String label, dynamic valor, String error, String campo){
    List<DropdownMenuItem<dynamic>> items = [];
    List<int> selectedItems = []; 
    int pos = 0;
    if(campo == "carreras"){
      for (var item in _carreras) {
        items.add(
          DropdownMenuItem(
            value: "${item.id}-${item.nombre!}", // El valor asociado a esta opción
            child: Text(item.nombre!, style: AppTextStyles.parrafo(),), // Lo que se mostrará en el desplegable
          ),
        );  
      }
      for (var carreraUser in _userMeta.carreras!) {
        pos = 0;
        for (var carrera in _carreras) {
          if(carreraUser.id! == carrera.id!){
            selectedItems.add(pos);
          }
          pos++;
        }
      }
    }
    pos = 0;
    if(campo == "recibirInformacion"){
      for (var item in _opcionesRecibirInformacion) {
        items.add(
          DropdownMenuItem(
            value: "$pos-$item", // El valor asociado a esta opción
            child: Text(item, style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
          ),
        );
        for (var recibirInformacionUser in _userMeta.recibirInformacion!) {
          if(recibirInformacionUser["titulo"]! == item){
            selectedItems.add(pos);
          }
        }
        pos++;
      }
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
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorationStyle.campoContainerForm(),
            child: SearchChoices.multiple(
              fieldDecoration: BoxDecoration(
                border: Border.all(color: Colors.transparent), // Esto elimina el borde
              ),
              items: items,
              selectedItems: selectedItems,
              hint: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Seleccionar...", style: AppTextStyles.parrafo(),),
              ),
              searchHint: "- Seleccionar -",
              onChanged: (value) {
                setState(() {
                  if(campo == "carreras"){
                    if (value.isNotEmpty) {
                      _userMeta.carreras = [];
                      for (var count in value) {
                        List<String> aux = (items[count].value.toString()).split("-");
                        _userMeta.carreras!.add(
                          Carrera(
                            id: int.parse(aux[0]),
                            nombre: aux[1],
                          )
                        );
                      }
                    } else {
                      _userMeta.carreras = [];
                    }
                  }
                  if(campo == "recibirInformacion"){
                    if (value.isNotEmpty) {
                      _userMeta.recibirInformacion = [];
                      for (var count in value) {
                        List<String> aux = (items[count].value.toString()).split("-");
                        _userMeta.recibirInformacion!.add(
                          {
                            "titulo": aux[1],
                          }
                        );
                      }
                    } else {
                      _userMeta.recibirInformacion = [];
                    }
                  }
                  selectedItems = value;
                });
              },
              closeButton: (selectedItems) {
                return (selectedItems.isNotEmpty
                    ? "Guardar (${selectedItems.length})"
                    : "Guardar sin seleccion");
              },
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
  Widget _crearCampoSelectorSimple(String label, dynamic valor, String error, String campo){
    List<DropdownMenuItem<dynamic>> items = [];
    List<int> selectedItems = []; 
    int pos = 0;
    if(campo == "universidad"){
      for (var universidad in _universidades) {
        items.add(
          DropdownMenuItem(
            value: "${universidad.id}-${universidad.nombre}", // El valor asociado a esta opción
            child: Text(universidad.nombre!, style: AppTextStyles.parrafo()), // Lo que se mostrará en el desplegable
          ),
        );
        if(_userMeta.universidad!.id == universidad.id){
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
          Text(
            label,
            style: TextStyle(
              color: AppColorStyles.gris1,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorationStyle.campoContainerForm(),
            child: SearchChoices.multiple(
              fieldDecoration: BoxDecoration(
                border: Border.all(color: Colors.transparent), // Esto elimina el borde
              ),
              items: items,
              selectedItems: selectedItems,
              hint: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Seleccionar...", style: AppTextStyles.parrafo(),),
              ),
              searchHint: "Selecciona una opcion",
              onChanged: (value) {
                setState(() {
                  if(campo == "universidad"){
                    if (value.isNotEmpty) {
                      List<String> aux = (items[value[value.length - 1]].value.toString()).split("-");
                      _userMeta.universidad = (
                        Universidad(
                          id: int.parse(aux[0]),
                          nombre: aux[1],
                        )
                      );
                    } else {
                      _userMeta.universidad = Universidad();
                      selectedItems = value;
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
  Widget _crearCampoSelectorSimpleOpcional(String label, bool condicion, String error, String campo){
    List<DropdownMenuItem<dynamic>> items = [];
    List<int> selectedItems = []; 
    if(campo == "aplicacionTest"){
      items = [
        DropdownMenuItem(
          value: "${0}-${'En el colegio'}", // El valor asociado a esta opción
          child: Text('En el colegio', style: AppTextStyles.parrafo(),), // Lo que se mostrará en el desplegable
        ),
        DropdownMenuItem(
          value: "${1}-${'En la UPSA'}", // El valor asociado a esta opción
          child: Text('En la UPSA', style: AppTextStyles.parrafo(),), // Lo que se mostrará en el desplegable
        ),
        DropdownMenuItem(
          value: "${2}-${'Servicio Privado'}", // El valor asociado a esta opción
          child: Text('Servicio Privado', style: AppTextStyles.parrafo(),), // Lo que se mostrará en el desplegable
        ),
        DropdownMenuItem(
          value: "${3}-${'En otra Universidad'}", // El valor asociado a esta opción
          child: Text('En otra Universidad', style: AppTextStyles.parrafo(),), // Lo que se mostrará en el desplegable
        ),
      ];
      if(_userMeta.aplicacionTest == 'En el colegio'){
        selectedItems.add(0);
      }else{
        if(_userMeta.aplicacionTest == 'En la UPSA'){
        selectedItems.add(1);
        }else{
          if(_userMeta.aplicacionTest == 'Servicio Privado'){
            selectedItems.add(2);
          }else{
            if(_userMeta.aplicacionTest == 'En otra Universidad'){
              selectedItems.add(3);
            }
          } 
        }
      }
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
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: AppDecorationStyle.campoContainerForm(),
                    child: SearchChoices.multiple(
                      fieldDecoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent), // Esto elimina el borde
                      ),
                      items: items,
                      selectedItems: selectedItems,
                      hint: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Seleccionar...", style: AppTextStyles.parrafo(),),
                      ),
                      searchHint: "Selecciona una opcion",
                      onChanged: (value) {
                        setState(() {
                          if(campo == "aplicacionTest"){
                            if(value.length > 0){
                              List<String> aux = (items[value[value.length - 1]].value.toString()).split("-");
                              _userMeta.aplicacionTest = aux[1];
                              selectedItems = [value[value.length - 1]];
                            }else{
                              _userMeta.aplicacionTest = "";
                              selectedItems = value;
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
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Alinea los hijos a la izquierda
            children: [
              ChoiceChip(
                backgroundColor: AppColorStyles.blanco,
                avatar: opcionValue1 ? Icon(Icons.check_circle_outline) : Icon(Icons.circle_outlined),
                checkmarkColor: AppColorStyles.blanco,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: AppColorStyles.altTexto1,
                label: Text(
                  opcion1,
                  style: TextStyle(
                    color: opcionValue1
                    ? AppColorStyles.blanco
                    : AppColorStyles.altTexto1
                  ),
                ),
                selected: opcionValue1,
                onSelected: (selected) {
                  if(campo == "testVocacional"){
                    _userMeta.testVocacional = selected; 
                  }
                  setState(() {});
                },
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColorStyles.altTexto1, // Color del borde
                    width: 1.0, // Ancho del borde
                  ),
                  borderRadius: BorderRadius.circular(14), // Radio de borde
                ),
              ),
              SizedBox(width: 8.0),
              ChoiceChip(
                backgroundColor: AppColorStyles.blanco,
                avatar: !opcionValue2 ? Icon(Icons.check_circle_outline) : Icon(Icons.circle_outlined),
                checkmarkColor: AppColorStyles.blanco,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: AppColorStyles.altTexto1,
                label: Text(
                  opcion2,
                  style: TextStyle(
                    color: !opcionValue2
                    ? AppColorStyles.blanco
                    : AppColorStyles.altTexto1
                  ),
                ),
                selected: !opcionValue2,
                onSelected: (selected) {
                  if(campo == "testVocacional"){
                    _userMeta.testVocacional = !selected; 
                  }
                  setState(() {});
                },
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColorStyles.altTexto1, // Color del borde
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
        alignment: Alignment.centerLeft,
        child: Text(
          '¿Qué pensás estudiar? Seleccioná tus preferencias.',
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
        style: AppTitleStyles.onboarding(color: AppColorStyles.altTexto1),
      ),
    );
  }
}