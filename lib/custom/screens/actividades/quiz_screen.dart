import 'dart:async';
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
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    bool hayErrores = false;
    for (var item in _quizPregunta.campos!) {
      if(item["opciones"].length > 0 && item["respuestaSeleccionada"] <= 0){
        item["error"] = "Responde esta pregunta";
        hayErrores = true;
      }else{
        item["error"] = "";
      }
    }
    setState(() { });
    if(hayErrores == false){
      _enviarFormulario();
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
              style: AppTextStyles.parrafo(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Divider(),
          ),
          _crearFormulario(),
        ],
      ),
    );
  }
  Widget _crearFormulario(){
    if(!_isLoggedIn || _bandera){
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
        ]
      );
    }
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
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.centerLeft,
          child: Text(
            data['label'],
            style: (data["opciones"].length > 0) ? AppTextStyles.parrafo(color: AppColorStyles.gris1) : AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
          ),
        ),
        if(data["opciones"].length > 0)
        _crearOpciones(data["opciones"], data["id"]),
        if (data["error"]!.isNotEmpty && data["opciones"].length > 0)
        Container(
          margin: EdgeInsets.only(top: 8),
          width: double.infinity,
          child: Text(
            data["error"]!,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Divider(),
        ),
      ],
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
        Row(
          children: <Widget>[
            Text(
              data["opcion"],
              style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
            ),
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
                        item["respuestaSeleccionada"] = value!;
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}