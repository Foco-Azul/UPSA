import 'dart:async';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/matriculate.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/campus/contacto_screem.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  String _backUrl= "";
  bool _isLoggedIn = false;
  User _user = User();
  final Map<String, dynamic> _formData = {
    "fecha": "",
    "telefono": "",
    "horario": ""
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
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user = await ApiService().getUserPopulateParaSolitudDeInscripcion(_user.id!);
      if(_user.solicitudesDeInscripciones!.length < 2){
        _permitido = true;
      }
    }
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _matriculate = await ApiService().getMatriculate();
    _modificarListaMasInformacion();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    setState(() {
      _formDataError["errorFecha"] = _formData["fecha"]!.isEmpty ? "Este campo es requerido" : "";
      _formDataError["errorTelefono"] = validacion.validarCelular(_formData["telefono"], true);
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
          backgroundColor: AppColorStyles.blancoFondo,
          selectedIndex: 2,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
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
            backgroundColor: AppColorStyles.blancoFondo,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item["headerValue"], style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.gris2)),
              );
            },
            body: Container(
              padding: EdgeInsets.all(15.0),
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
            style: AppTitleStyles.tarjeta(color: AppColorStyles.verde1),
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
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Tu camino comienza aquí".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Text(
                  "Sabemos que elegir una universidad es una de las decisiones más importantes de tu vida. Por eso, te invitamos a visitar nuestra área de Admisiones y descubrir cómo la UPSA será donde alcancés tus metas.",
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
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
                    style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
                  color: AppColorStyles.verde1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "visita de inscripción".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
                ),
              ]
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
              visible: !_permitido,
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
                    child: Text(
                      "Inicia tu proceso de inscripción agendando una cita mediante el siguiente formulario.",
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
                      style: AppDecorationStyle.botonContacto(),
                      child: Text(
                        'Ingresar',
                        style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
                    style: AppDecorationStyle.botonContacto(),
                    child: Text(
                      'Completar perfil',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
                  color: AppColorStyles.verde1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "visita de inscripción".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
              child: Text(
                "Inicia tu proceso de inscripción agendando una cita mediante el siguiente formulario.",
                style: AppTextStyles.parrafo(),
              ),
            ),
            Column(
              children: [
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
                ),  
                Container(
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
                              decoration: AppDecorationStyle.campoContacto(hintText: "hintText", labelText: ""),  
                              style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
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
                    style: AppDecorationStyle.botonContacto(),
                    child: Text(
                      'Enviar',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Llegá lejos".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
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
                      color: AppColorStyles.verde1, // Ajusta el color si es necesario
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