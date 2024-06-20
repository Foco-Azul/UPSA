import 'dart:async';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/concurso.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';


class ConcursoScreen extends StatefulWidget {
  const ConcursoScreen({Key? key, this.idConcurso=-1}) : super(key: key);
  final int idConcurso;
  @override
  _ConcursoScreenState createState() => _ConcursoScreenState();
}

class _ConcursoScreenState extends State<ConcursoScreen> {
  int _idConcurso = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _numPages = 1;
  int _inscritos = -1;
  String _qr = "";
  List<Noticia> _noticiasRelacionadas = [];
  String _backUrl = "";
  Concurso _concurso = Concurso();
  User _user = User();
  bool _isLoggedIn = false;
  bool _ingresoMostrado = false;
  @override
  void initState() {
    super.initState();
    _idConcurso = widget.idConcurso;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _inicializarDatos();
  }

  void _inicializarDatos() {
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
    }
    _cargarDatosAsincronos();
  }

  Future<void> _cargarDatosAsincronos() async { 
    if (_isLoggedIn) {
      _user.concursosInscritos = await ApiService().getConcursosInscritos(_user.id!);
      _user.concursosSeguidos = await ApiService().getConcursosSeguidos(_user.id!);
      if(_user.concursosInscritos!.isNotEmpty){
        for (var inscripcion in _user.concursosInscritos!) {
          _qr = inscripcion["qr"]!;
        }
      }
    }
    _concurso = await ApiService().getConcurso(_idConcurso);
    _noticiasRelacionadas = await ApiService().getNoticiasRelacionadasConActividad(_concurso.noticiasRelacionadas!);
    await dotenv.load(fileName: ".env");
    Timer(Duration(milliseconds: 1000), () {});
    _backUrl = dotenv.get('backUrl');
    _concurso.galeriaDeFotos!.insert(0, _concurso.fotoPrincipal!);
    _numPages = _concurso.galeriaDeFotos!.length;
    _inscritos = _concurso.inscritos!;
    Timer(Duration(seconds: 1), () {
      setState(() {
        controller.uiLoading = false;
      });
     });
  }

  void _seguirActividad() async {
    _user.concursosSeguidos!.add({"idActividad":_idConcurso});
    await ApiService().setActividadesSeguidos(_user.id!, _user.concursosSeguidos!, "concursos");
    setState(() {    
    });
  }
  void _dejarDeSeguirActividad() async {
    _user.concursosSeguidos!.removeWhere((actividad) => actividad["idActividad"] == _idConcurso);
    await ApiService().setActividadesSeguidos(_user.id!, _user.concursosSeguidos!, "concursos");
    setState(() {
      // Actualiza la interfaz de usuario si es necesario
    });
  }
  void _inscribirseActividad() async {
    _concurso = await ApiService().getConcurso(_idConcurso);
    if(_concurso.capacidad! > -1){
      if(_concurso.inscritos! < _concurso.capacidad!){
        int idInscripcion = await ApiService().crearInscripcionConcurso(_user.id!, _idConcurso);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => super.widget));
        setState(() {
          _inscritos++;
          MensajeTemporalInferior().mostrarMensaje(context,"¡Inscrito! Presenta el código QR para ingresar al evento. Tus inscripciones las podrás ver en sus mismos eventos y en tu perfil.",Color.fromRGBO(5, 50, 12, 1), Color.fromRGBO(255, 255, 255, 1));
        });
      }else{
        setState(() {
          _inscritos = _concurso.inscritos!;
          MensajeTemporalInferior().mostrarMensaje(context,"Lo sentimos, cupos agotados.",Color.fromRGBO(255, 0, 0, 1), Color.fromRGBO(255, 255, 255, 1));
        });
      }
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => super.widget));
      int idInscripcion = await ApiService().crearInscripcionConcurso(_user.id!, _idConcurso);
      setState(() {
        _inscritos++;
        MensajeTemporalInferior().mostrarMensaje(context,"¡Inscrito! Presenta el código QR para ingresar al evento. Tus inscripciones las podrás ver en sus mismos eventos y en tu perfil.",Color.fromRGBO(5, 50, 12, 1), Color.fromRGBO(255, 255, 255, 1));
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
          backgroundColor: Color.fromRGBO(244, 251, 249, 1),
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0), // Margen a la derecha
              child: RichText(
                text: TextSpan(
                  text: _concurso.titulo!,
                  style: TextStyle(
                    fontSize: 18, // Tamaño del texto
                    fontWeight: FontWeight.w600, // Peso del texto
                    color: Colors.black, // Color del texto
                  ),
                ),
                overflow: TextOverflow.visible, // Permite que el texto se muestre en múltiples líneas
                textAlign: TextAlign.center, // Alinea el texto al centro
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: MySpacing.only(left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _breadcrumbs(),
                SizedBox(
                  height: 8,
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: PageView(
                        pageSnapping: true,
                        physics: ClampingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: _crearGaleria().map((widget) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: widget,
                          );
                        }).toList(),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicatorStatic(),
                      ),
                    ),
                  ],
                ),
                if(_concurso.fechaInicio!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            "Inicia",
                            fontSize: 12,
                            fontWeight: 500,
                          ),
                          MyText(
                            _concurso.fechaInicio!,
                            fontSize: 14,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                    ),
                    if(_concurso.fechaFin!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            "Finaliza",
                            fontSize: 12,
                            fontWeight: 500,
                          ),
                          MyText(
                            _concurso.fechaFin!,
                            fontSize: 14,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                Container(
                  margin: MySpacing.top(12),
                  child: MyText(
                    _concurso.descripcion!,
                    fontSize: 14,
                  ),
                ),
                _crearEtiquetas(),
                _concurso.capacidad! > -1
                ? ((_concurso.capacidad! - _inscritos) > 0
                    ? MyText.titleLarge(
                        "Cupos disponibles: ${_concurso.capacidad! - _inscritos}",
                        fontSize: 16,
                        fontWeight: 600,
                      )
                    : MyText.titleLarge(
                        "Cupos agotados",
                        fontSize: 16,
                        fontWeight: 600,
                      ))
                : MyText.titleLarge(
                    "Cupos ilimitados",
                    fontSize: 16,
                    fontWeight: 600,
                  ),
                if(_isLoggedIn && _user.estado! == "Completado")
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: 16),
                  child: Wrap(
                    children: [
                        if (_user.concursosInscritos!.any((concurso) => concurso['idActividad'] == _idConcurso))
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: MyButton.large(
                            padding: const EdgeInsets.fromLTRB(23, 23, 23, 23),
                            onPressed: () {},
                            elevation: 0,
                            splashColor: theme.colorScheme.onPrimary.withAlpha(60),
                            backgroundColor: Color.fromRGBO(5, 50, 12, 1),
                            borderRadiusAll: 16.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.logIn, color: Colors.white), // Icono antes del texto
                                SizedBox(width: 8.0),
                                MyText.bodyMedium(
                                  'Inscritó',
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if(!(_user.concursosInscritos!.any((concurso) => concurso['idActividad'] == _idConcurso)) && ((_concurso.capacidad!-_inscritos) > 0 || _concurso.capacidad! == -1))
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: MyButton.medium(
                          buttonType: MyButtonType.outlined,
                          borderColor: Colors.black,
                          borderRadiusAll: 16.0,
                          splashColor: Color.fromRGBO(32, 104, 14, 1).withAlpha(60),
                          onPressed: () {
                            if (!(_user.concursosInscritos!.any((concurso) => concurso['idActividad'] == _idConcurso))) {
                              _showBottomSheet(context);
                            }
                          },
                          elevation: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.logIn, color: Colors.black), // Icono antes del texto
                              SizedBox(width: 8.0), // Espacio entre el icono y el texto
                              MyText.bodyMedium(
                                'Inscribirse',
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      _user.concursosSeguidos!.any((actividad) => actividad["idActividad"] == _idConcurso)
                        ? Container(
                          margin: const EdgeInsets.all(8.0),
                          child: MyButton.large(
                            padding: const EdgeInsets.fromLTRB(23, 23, 23, 23),
                            onPressed: () {_dejarDeSeguirActividad();},
                            elevation: 0,
                            splashColor: theme.colorScheme.onPrimary.withAlpha(60),
                            backgroundColor: Color.fromRGBO(5, 50, 12, 1),
                            borderRadiusAll: 16.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.bellRing, color: Colors.white), // Icono antes del texto
                                SizedBox(width: 8.0),
                                MyText.bodyMedium(
                                  'Dejar de seguir',
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ],
                            ),
                          ),
                        )
                        : Container(
                          margin: const EdgeInsets.all(8.0),
                          child: MyButton.medium(
                            buttonType: MyButtonType.outlined,
                            borderColor: Colors.black,
                            borderRadiusAll: 16.0,
                            borderRadius: BorderRadius.circular(16.0),
                            splashColor: Color.fromRGBO(32, 104, 14, 1).withAlpha(60),
                            onPressed: () {_seguirActividad();},
                            elevation: 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.bellRing, color: Colors.black), // Icono antes del texto
                                SizedBox(width: 8.0), 
                                MyText.bodyMedium(
                                  'Seguir',
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ),
                Divider(),
                if( _concurso.calendario!.isNotEmpty)
                _crearCalendario(),
                if(_concurso.calendario!.isNotEmpty)
                Divider(),
                if (_user.concursosInscritos!.any((concurso) => concurso['idActividad'] == _idConcurso))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MyText.titleLarge(
                          "Ingreso",
                          fontSize: 18,
                          fontWeight: 800,
                        ),
                        SizedBox(width: 8), // Espacio entre el texto y el icono
                        IconButton(
                          icon: Icon(
                            _ingresoMostrado ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                            size: 24,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _ingresoMostrado = !_ingresoMostrado; // Alterna el valor de _ingresoMostrado
                            });
                          },
                        ),
                      ],
                    ),
                    if(_ingresoMostrado)
                    MyText.titleLarge(
                      "Presenta el código para ingresar al evento.",
                      fontSize: 15,
                      fontWeight: 600,
                    ),
                    SizedBox(height: 10),
                    if(_ingresoMostrado)
                    _mostrarIngreso(),
                    Container(
                      padding: EdgeInsets.only(top: 16.0, bottom: 0), // Espacio en la parte superior del Divider
                      child: Divider(),
                    )
                  ],
                ),
                if(_concurso.noticiasRelacionadas!.isNotEmpty && _noticiasRelacionadas.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Seguimiento",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if(_concurso.noticiasRelacionadas!.isNotEmpty && _noticiasRelacionadas.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Column(
                        children: <Widget>[
                            Container(
                            padding: MySpacing.only(top: 12, bottom: 12),
                            child: Wrap(
                              children: _buildMasNoticias(),
                            ),
                          )
                        ]
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  
  _buildMasNoticias() {
    List<Widget> masNoticias = [];
    for (int index = 0; index < _noticiasRelacionadas.length; index++) {
      Noticia noticia = _noticiasRelacionadas[index];
      masNoticias.add(InkWell(
        onTap: () {
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 3,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: noticia.id!,)));
        },
        child: Container(
          margin: EdgeInsets.only(top: 8.0, bottom: 8, right: 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.65, // 65% del ancho de la pantalla
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: NetworkImage(_backUrl + noticia.foto!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 150,
                  width: MediaQuery.of(context).size.width * 0.65, // 65% del ancho de la pantalla
                ),
                SizedBox(height: 16),
                Text(
                  noticia.titular!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return masNoticias;
  }
  void _showBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext buildContext) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: MySpacing.fromLTRB(24, 24, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyText.titleLarge(
                      "Confirma tu inscripción y recibirás un QR para registrar tu acceso",
                      fontSize: 16,
                      fontWeight: 600,
                    ),
                    SizedBox(height: 16.0), 
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      child: MyButton.medium(
                        buttonType: MyButtonType.outlined,
                        borderColor: Colors.black,
                        borderRadiusAll: 16.0,
                        splashColor: Color.fromRGBO(32, 104, 14, 1).withAlpha(60),
                        onPressed: () {
                          if (!(_user.concursosInscritos!.any((concurso) => concurso['idActividad'] == _idConcurso))) {
                            _inscribirseActividad();
                            _seguirActividad();
                          }
                        },
                        elevation: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.logIn, color: Colors.black), // Icono antes del texto
                            SizedBox(width: 8.0), // Espacio entre el icono y el texto
                            MyText.bodyMedium(
                              'Confirmar inscripción',
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        );
      }
    );
  }
  Widget _crearCalendario() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleLarge(
            "Calendario de eventos",
            fontSize: 18,
            fontWeight: 800,
          ),
          SizedBox(height: 8.0), // Espacio entre los textos
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _concurso.calendario!.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _concurso.calendario![index]["titulo"],
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      _concurso.calendario![index]["inicio"]+_concurso.calendario![index]["fin"],
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _mostrarIngreso(){
    return
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Alinea el Column en el centro verticalmente
          crossAxisAlignment: CrossAxisAlignment.center, // Alinea el BarcodeWidget en el centro horizontalmente
          children: [
            BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: _qr,
              width: 200,
              height: 200,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
  }
  Widget _crearEtiquetas() {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 12),
      child: Wrap(
        spacing: 8.0, // Espacio entre elementos en el eje principal
        runSpacing: 8.0, // Espacio entre elementos en el eje transversal
        children: List.generate(
          _concurso.etiquetas!.length,
          (index) {
            return Text(
              "#${_concurso.etiquetas![index]}",
              style: TextStyle(fontSize: 14.0),
            );
          },
        ),
      ),
    );
  }
  List<Widget> _crearGaleria() {
    return _concurso.galeriaDeFotos!.map((url) {
      return Container(
        decoration: BoxDecoration(
          color: customTheme.card,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: customTheme.shadowColor.withAlpha(120),
                blurRadius: 24,
                spreadRadius: 4)
          ]),
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image.network(
              _backUrl + url,
              height: 240.0,
              fit: BoxFit.fill,
            ),
          ),
        )
      );
    }).toList();
  }
  List<Widget> _buildPageIndicatorStatic() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromRGBO(32, 104, 14, 1) : const Color.fromARGB(160, 156, 171, 1).withAlpha(140),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
  Widget _breadcrumbs() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
        children: [
          MyText(
            "Evento",
            fontSize: 14,
            fontWeight: 500,
          ),
          Icon(LucideIcons.dot),
          MyText(
            _concurso.categoria!,
            fontSize: 14,
            fontWeight: 500,
          ),
          Icon(LucideIcons.dot),
          MyText(
            _concurso.publicacion!,
            fontSize: 14,
            fontWeight: 500,
          ),
        ],
      ),
    );
  }
}
