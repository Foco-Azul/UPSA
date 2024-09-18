import 'dart:async';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/registro_carrera.dart';
import 'package:flutkit/custom/auth/registro_intereses.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/auth/validar_email.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/quiz_preguntas.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key, this.id=-1}) : super(key: key);
  final int id;
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _id = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  QuizPregunta _quizPregunta = QuizPregunta();
  User _user = User();
  bool _isLoggedIn = false;
  late AnimacionCarga _animacionCarga;
  bool _bandera = false;
  final Map<String, int> _marcador = {
    "actual": 0,
    "inicial": 0,
    "final":0,
  };
  String _errorGeneral = "";
  final List<String> _respuestasCorrectas = [
    "¡Bien tirau!",
    "¡Le achuntaste!",
    "¡Estás tiluchi!",
    "¡Bien ahí!",
    "¡Esssa!",
    "¡Buena, pariente!",
    "Ya casi, ¡vos podés!",
    "¡Felicidades! Sos un jichi.",
  ];
  final List<String> _respuestasInCorrectas = [
    "¡Uy! Le pelaste.", 
    "¡Al aguaa!",
    "Ya pues, oye…",
    "Negativo.",
    "Le pelaste de nuevo.",
    "Ponete las pilas.", 
    "Jaja, moderate.", 
    "Bueno, lo intentaste. ¡A estudiar!",
  ];
  final random = Random();
  bool _permitido = true;

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _animacionCarga = AnimacionCarga(context: context);
    _cargarDatos();
  }
  
  Future<void> _cargarDatos() async { 
    _quizPregunta = await ApiService().getQuizPopulateParaLLenar(_id);
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Quizzes_${FuncionUpsa.limpiarYReemplazar(_quizPregunta.titulo!)}',
      screenClass: 'Quizzes_${FuncionUpsa.limpiarYReemplazar(_quizPregunta.titulo!)}', // Clase o tipo de pantalla
    );
    _marcador["final"] = _quizPregunta.campos!.length - 1;
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      for (var item in _quizPregunta.usuarios!) {
        if(item["id"] == _user.id){
          if(item["cantidad"] >= 3){
            _permitido = false;
          }
        }
      }
    }
    print(_permitido);
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    bool hayErrores = false;
    for (var item in _quizPregunta.campos!) {
      if(item["opciones"].length > 0 && item["respuestaSeleccionada"] <= 0){
        hayErrores = true;
      }
    }
    setState(() { });
    if(hayErrores == false){
      _errorGeneral = "";
      _enviarFormulario();
    }else{
      _errorGeneral = "Tienes preguntas sin responder";
    }
  }
  void _enviarFormulario() async{
    _animacionCarga.setMostrar(true);
    String respuesta = await ApiService().crearQuizRespuesta(_quizPregunta.campos!, _user.id!, _quizPregunta.id!);
    if(respuesta == "exito"){
      _bandera = true;
      MensajeTemporalInferior().mostrarMensaje(context,"Se envio con éxito la Quiz.", "exito");
    }else{
      MensajeTemporalInferior().mostrarMensaje(context,"Algo salio mal.", "error");
    }
    _animacionCarga.setMostrar(false);
    setState(() {
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getDatingHomeScreen(
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
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: RichText(
                text: TextSpan(
                  text: _quizPregunta.titulo!,
                  style: AppTitleStyles.principal(),
                ),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearTarjetaConFormulario(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 1,
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
  
  Widget _crearTarjetaConFormulario(){
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
            child: Text(
              _quizPregunta.descripcion!,
              style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Divider(),
          ),
          Row(
            children: [
              Icon(
                Icons.psychology_alt_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Quiz".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ]
          ),
          _crearFormulario(),
        ],
      ),
    );
  }
  Widget _crearFormulario(){
    if(!_isLoggedIn || _bandera || !_permitido){
      return Column(
        children: [
          Visibility(
            visible: !_isLoggedIn,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ingresa con tu cuenta para responder el Quiz.",
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
          Visibility(
            visible: _isLoggedIn && !_permitido,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0), // Ajusta los valores del margen según sea necesario
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Alcanzaste el maximo de intentos.",
                    style: AppTextStyles.parrafo(),
                  ),
                ),
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
                    'Completar perfil',
                    style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: _bandera,
            child: Text(
              "Se envio con éxito la Quiz.",
              style: AppTextStyles.parrafo(),
            ) 
          ),
        ],
      );
    }else{
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _crearPreuntas(),
          if(_errorGeneral.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            width: double.infinity,
            child: Text(
              _errorGeneral,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.start,
            ),
          ),
          _crearBotones(),
        ]
      );
    }
  }
  Widget _crearBotones() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Visibility(
            visible: _marcador["actual"]! > 0,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _marcador["actual"] = _marcador["actual"]! - 1;
                  });
                },
                style: AppDecorationStyle.botonCursillo(),
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: 3.14, // Rotar 180 grados (π radianes)
                      child: Icon(Icons.arrow_right_alt_outlined, color: AppColorStyles.oscuro1),
                    ),
                    Text(
                      'Anterior',
                      style: AppTextStyles.botonMenor(),
                    )
                  ]
                ),
              ),
            ),
          ),
          Visibility(
            visible: _marcador["actual"]! < _marcador["final"]!,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _marcador["actual"] = _marcador["actual"]! + 1;
                  });
                },
                style: AppDecorationStyle.botonCursillo(),
                child: Row(
                  children: [
                    Text(
                      'Próximo',
                      style: AppTextStyles.botonMenor(),
                    ),
                    Icon(Icons.arrow_right_alt_outlined, color: AppColorStyles.oscuro1),
                  ]
                ),
              ),
            ), 
          ),
          Visibility(
            visible: _marcador["actual"]! == _marcador["final"]!,
            child: Container(
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
          ),
        ],
      ),
    );
  }
  Widget _crearPreuntas() {
    List<Map<String, dynamic>> campos = _quizPregunta.campos!;
    List<Widget> tarjetas = campos.map((item) => _crearPregunta(item)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
      children: tarjetas,
    );
  }
  Widget _crearPregunta(Map<String,dynamic> data) {
    return Visibility(
      visible: _marcador["actual"] == data["pos"],
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            alignment: Alignment.centerLeft,
            child: Text(
              data['label'],
              style: (data["opciones"].length > 0) ? AppTextStyles.parrafo(color: AppColorStyles.oscuro2) : AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
            ),
          ),
          if(data["opciones"].length > 0)
          _crearOpciones(data["opciones"], data["id"]),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Divider(),
          ),
        ],
      )
    );
  }
  Widget _crearOpciones(List<Map<String, dynamic>> data, int idCampo) {
    List<Widget> tarjetas = data.map((item) => _crearOpcion(item, idCampo)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
      children: tarjetas,
    );
  }
  Widget _crearOpcion(Map<String,dynamic> data, int idCampo) {
    Map<String,dynamic> campo = {};
    for (var item in _quizPregunta.campos!) {
      if(item["id"] == idCampo){
        campo = item;
      }
    }
    return Column(
      children: [
        SizedBox(height: 8,),
        Row(
          children: <Widget>[
            Container(
              margin: MySpacing.right(8),
              child: Radio(
                value: int.tryParse(data["id"].toString())!,
                visualDensity: VisualDensity.compact,
                groupValue: int.tryParse(campo["respuestaSeleccionada"].toString()),
                fillColor: MaterialStateProperty.all(AppColorStyles.altTexto1),
                onChanged: (int? value) {
                  setState(() {
                    for (var item in _quizPregunta.campos!) {
                      if(item["id"] == idCampo){
                        if(item["respuestaSeleccionada"] == -1){
                          item["respuestaSeleccionada"] = value!;
                          if(data["esCorrecto"] == true){
                            data["mensaje"] = _respuestasCorrectas[random.nextInt(_respuestasCorrectas.length)];
                          }else{
                            data["mensaje"] = _respuestasInCorrectas[random.nextInt(_respuestasInCorrectas.length)];
                          }
                        }
                      }
                    }
                    
                  });
                },
              ),
            ),
            Flexible(
              child: Text(
                data["opcion"],
                style: AppTextStyles.parrafo(color: (data["mensaje"].isNotEmpty) ? (data["esCorrecto"] ? AppColorStyles.verde1 : Color(0xFFA91010)) :AppColorStyles.gris1),
                softWrap: true,
                overflow: TextOverflow.visible,
              )
            ),
          ],
        ),
        if(data["mensaje"].isNotEmpty)
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            data["mensaje"],
            style: AppTextStyles.parrafo(color: data["esCorrecto"] ? AppColorStyles.verde1 : Color(0xFFA91010)),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        )
      ],
    );
  }
}