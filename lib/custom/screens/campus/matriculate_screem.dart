import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/matriculate.dart';
import 'package:flutkit/custom/models/prefixe.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
//import 'package:url_launcher/url_launcher.dart';


class MatriculateScreen extends StatefulWidget {
  const MatriculateScreen({Key? key}) : super(key: key);
  @override
  _MatriculateScreenState createState() => _MatriculateScreenState();
}

class _MatriculateScreenState extends State<MatriculateScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  Matriculate _matriculate = Matriculate();
  bool _isLoggedIn = false;
  User _user = User();
  final Map<String, dynamic> _formData = {
    "fecha": "",
    "telefono": "",
    "horario": "",
    "codigoDeTelefono": "+591", 
  };
  final Map<String, String> _formDataError = {
    "errorFecha": "",
    "errorTelefono": "",
    "errorHorario": ""
  };
  Validacion validacion = Validacion();
  bool _bandera = false;
  bool _permitido = false;
  late AnimacionCarga _animacionCarga;
  DateTime selectedDate = DateTime.now(); // Maneja la fecha
  TimeOfDay selectedTime = TimeOfDay.now(); // Maneja la hora
  List<Prefixe> _prefixes = [];

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _animacionCarga = AnimacionCarga(context: context);
    _cargarDatos();
  }
  
  void _cargarDatos() async { 
    setState(() {
      controller.uiLoading = true;
    });    
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Inscribete',
      screenClass: 'Inscribete', // Clase o tipo de pantalla
    );
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    _prefixes = await ApiService().getPrefixesPopulate();
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user = await ApiService().getUserPopulateParaSolitudDeInscripcion(_user.id!);
      if(_user.solicitudesDeInscripciones!.length < 2){
        _permitido = true;
      }
    }
    await dotenv.load(fileName: ".env");
    _matriculate = await ApiService().getMatriculate();
    _modificarListaMasInformacion();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos() {
    setState((){
      _formDataError["errorFecha"] = _formData["fecha"]!.isEmpty ? "Este campo es requerido" : "";
      _formDataError["errorTelefono"] = validacion.validarCelular(_formData["telefono"], true, _formData["codigoDeTelefono"], _prefixes);
      _formDataError["errorHorario"] = _formData["horario"]!.isEmpty ? "Este campo es requerido" : "";
    });
    if(_formDataError["errorFecha"]!.isEmpty && _formDataError["errorTelefono"]!.isEmpty && _formDataError["errorHorario"]!.isEmpty){
      _enviarFormulario();
    }
  }
  void _enviarFormulario() async{
    _animacionCarga.setMostrar(true);
    String respuesta = await ApiService().crearSolicitudDeInscripcion(_formData, _user.id!);
    if(respuesta == "exito"){
      _bandera = true;
      MensajeTemporalInferior().mostrarMensaje(context,"Solicitud enviado exitosamente.", "exito");
    }else{
      MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
    }
    setState(() {
    });
    _animacionCarga.setMostrar(false);
  }
  void _modificarListaMasInformacion(){
    List<List<dynamic>> nuevoMasInformacion = [];
    for (var item in _matriculate.masInformacion!) {
      List<dynamic> aux = [];
      var aux2 = {
        "headerValue": item["titulo"],
        "expandedValue": item["descripcion"],
        "isExpanded": false
      };
      aux.add(aux2);
      nuevoMasInformacion.add(aux);
    }
    _matriculate.masInformacion = nuevoMasInformacion;
  }
  _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale("es"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Fecha actual como mínima
      lastDate: DateTime.now().add(Duration(days: 365)), // Un año desde la fecha actual
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColorStyles.altVerde1, // Color de fondo del encabezado
              onPrimary: AppColorStyles.blanco,  // Color del texto del encabezado
              onSurface: AppColorStyles.altTexto1, // Color del texto del cuerpo
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColorStyles.altTexto1, // Color del texto del botón
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _formData["fecha"] = DateFormat('dd-MM-yyyy').format(selectedDate); // Formatear solo la fecha
      });
    }
  }

  _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate), // Hora inicial basada en la fecha seleccionada
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColorStyles.altVerde1, // Color de fondo del encabezado
              onPrimary: AppColorStyles.blanco,  // Color del texto del encabezado
              onSurface: AppColorStyles.altTexto1, // Color del texto del cuerpo
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime; // Guardar solo la hora seleccionada
        final DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _formData["horario"] = DateFormat('HH:mm').format(fullDateTime); // Formatear solo la hora
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
          centerTitle: true,
          title: Text(
            _matriculate.titulo!,
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearLista(),
              _crearComoMatricularse(),
              _crearMasInformacion(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 2,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.account_circle_sharp),
              title: Text(
                'Mi perfil',
                style: AppTextStyles.bottomMenu()
              ),
            ),
          ],
          onItemSelected: (index) {
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: index,)),(Route<dynamic> route) => false);
          },
        ),
      );
    }
  } 
  Widget _crearListaDesplegables() {
    return Column(
      children: List.generate( _matriculate.masInformacion!.length, (index) {
        return _crearDesplegable( _matriculate.masInformacion![index]);
      }),
    );
  }
  Widget _crearDesplegable(List<dynamic> data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      decoration: AppDecorationStyle.desplegable(),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            data[index]["isExpanded"] = isExpanded;
          });
        },
        children: data.map<ExpansionPanel>((dynamic item) {
          return ExpansionPanel(
            backgroundColor: AppColorStyles.blanco,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item["headerValue"], style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.gris2)),
              );
            },
            body: Container(
              padding: EdgeInsets.only(left: 15.0, right: 15, bottom: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                item["expandedValue"],
                style: AppTextStyles.parrafo(),
              ),
            ),
            isExpanded: item["isExpanded"],
          );
        }).toList(),
      ),
    );
  }
  Widget _crearMasInformacion(){
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Más información", // Primer texto
            style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1),
          ),
          _crearListaDesplegables(),
        ],
      ),
    );
  }
  Widget _crearComoMatricularse(){
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Tu camino comienza aquí".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Text(
                  _matriculate.comoMatricularse!,
                  style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                ),
              ]
            ),
          ),
          _crearFormulario(),
          /*
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    if(_matriculate.instructivo!.isNotEmpty){
                      await launchUrl(Uri.parse(_backUrl+_matriculate.instructivo!),mode: LaunchMode.externalApplication,);
                    }
                  },
                  style: AppDecorationStyle.botonContacto(),
                  child: Text(
                    'Instructivo',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blanco), // Estilo del texto del botón
                  ),
                ),
              ),
              /*
              SizedBox(width: 8.0),
              Container(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    if(_matriculate.enlaceFormulario!.isNotEmpty){
                      await launchUrl(Uri.parse(_matriculate.enlaceFormulario!),mode: LaunchMode.externalApplication);
                    }
                  },
                  style: AppDecorationStyle.botonContacto(),
                  child: Text(
                    'Llenar formulario',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blanco), // Estilo del texto del botón
                  ),
                ),
              )
              */
            ]
          )*/
        ],
      ),
    );
  }
   Widget _crearFormulario(){
    if(!_isLoggedIn || (_isLoggedIn && _user.estado! != "Completado") || !_permitido || _bandera){
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_search_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "visita de inscripción".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                _matriculate.ayuda!,
                style: AppTextStyles.parrafo(),
              ),
            ),
            Visibility(
              visible: _bandera,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                child: Text(
                  "Solicitud enviada exitosamente.",
                  style: AppTextStyles.parrafo(),
                ),
              ),
            ),
            Visibility(
              visible: _isLoggedIn && !_permitido,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                child: Text(
                  "LLegaste a la cantidad maxima de solicitudes de Inscripción.",
                  style: AppTextStyles.parrafo(),
                ),
              ),
            ),
            Visibility(
              visible: !_isLoggedIn,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ingresa con tu cuenta para agendar una cita.",
                      style: AppTextStyles.parrafo(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Login2Screen()));
                      },
                      style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                      child: Text(
                        'Ingresar',
                        style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                      ),
                    ),
                  )
                ],
              )
            ),
            if(_isLoggedIn && _user.estado! != "Completado")
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                  child: Text(
                    "Completá tu perfil para solicitar un Test vocacional.",
                    style: AppTextStyles.parrafo(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      if(_user.estado == "Nuevo"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ValidarEmail()));
                      }
                      if(_user.estado == "Verificado"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroPerfil()));
                      }
                      if(_user.estado == "Perfil parte 1"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroCarrera()));
                      }
                      if(_user.estado == "Perfil parte 2"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegistroIntereses()));
                      } 
                    },
                    style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                    child: Text(
                      'Completa tu perfil',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                    ),
                  ),
                )
              ],
            )
          ]
        )
      );
    }else{
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_search_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "visita de inscripción".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                _matriculate.ayuda!,
                style: AppTextStyles.parrafo(),
              ),
            ),
            Column(
              children: [
                /*
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        onChanged: (value) {
                          _formData["fecha"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["fecha"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "Fecha de cita", labelText: "Fecha de cita"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      if (_formDataError["errorFecha"]!.isNotEmpty)
                      Text(
                        _formDataError["errorFecha"]!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                    ]
                  )
                ),  
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        onChanged: (value) {
                          _formData["horario"] = value;
                          setState(() {});
                        },
                        initialValue: _formData["horario"],
                        decoration: AppDecorationStyle.campoContacto(hintText: "Horario de cita", labelText: "Horario de cita"),
                        style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                      ),
                      if (_formDataError["errorHorario"]!.isNotEmpty)
                      Text(
                        _formDataError["errorHorario"]!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                    ]
                  )
                ), */ 
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(text: _formData["fecha"]),
                              decoration: AppDecorationStyle.campoContacto(hintText: "", labelText: "Fecha de cita"),
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
                      if (_formDataError["errorFecha"]!.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text(
                          _formDataError["errorFecha"]!,
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
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(text: _formData["horario"]),
                              decoration: AppDecorationStyle.campoContacto(hintText: "", labelText: "Horario de cita"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            child: MyButton(
                              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              onPressed: () {
                                _pickTime(context);
                              },
                              elevation: 0,
                              borderRadiusAll: 4,
                              backgroundColor: AppColorStyles.altTexto1,
                              child: Icon(
                                Icons.access_time,
                                size: 20,
                                color: AppColorStyles.blanco,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_formDataError["errorHorario"]!.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text(
                          _formDataError["errorHorario"]!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            width: 120,
                            decoration: AppDecorationStyle.campoContainerForm(),
                            child: CountryCodePicker(
                              onChanged: (value) {
                                _formData["codigoDeTelefono"] = value.dialCode ?? "+591";
                              },
                              headerText: "Selecciona tu país",
                              // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                              initialSelection: _formData["codigoDeTelefono"],
                              // Filtrar países disponibles
                              countryFilter: _prefixes.map((item) => item.codigoDePais ?? "BO").toList(), // Códigos de país permitidos
                              // optional. Shows only country name and flag
                              showCountryOnly: false,
                              // optional. Shows only country name and flag when popup is closed.
                              showOnlyCountryWhenClosed: false,
                              // optional. aligns the flag and the Text left
                              alignLeft: false,
                            ),
                          ),
                          SizedBox(width: 10), // Para agregar un espacio entre los campos
                          Expanded(
                            child: Container(
                              decoration: AppDecorationStyle.campoContainerForm(),
                              child: TextFormField(
                                onChanged: (value) {
                                  _formData["telefono"] = value;
                                  setState(() {});
                                },
                                decoration: AppDecorationStyle.campoContacto(hintText: "Teléfono de contacto", labelText: "Teléfono de contacto"),  
                                style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_formDataError["errorTelefono"]!.isNotEmpty)
                      Text(
                        _formDataError["errorTelefono"]!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      _validarCampos();
                    },
                    style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                    child: Text(
                      'Enviar',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }
  Widget _crearLista(){
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Llegá lejos".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ]
          ),
          Column(
            children: List.generate(_matriculate.beneficios!.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
                child: Row(
                  children: [
                    Icon(
                      Icons.check, // Reemplaza con el icono que desees
                      color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                    ),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        _matriculate.beneficios![index]["descripcion"],
                        style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                        softWrap: true, // Permite el salto de línea automático
                      ),
                    )
                  ]
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}