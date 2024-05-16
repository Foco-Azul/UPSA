import 'dart:async';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';


class EventoScreen extends StatefulWidget {
  const EventoScreen({Key? key, this.idEvento=-1}) : super(key: key);
  final int idEvento;
  @override
  _EventoScreenState createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  int _idEvento = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late Timer timerAnimation;
  int _numPages = 1;
  int _inscritos = -1;
  String _qr = "";
  
  String _backUrl = "";
  Evento _evento = Evento();
  User _user = User();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _idEvento = widget.idEvento;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
  }
  void _cargarDatos() async {
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if(_isLoggedIn){
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      _user.eventosInscritos = await ApiService().getEventosInscritos(_user.id!);
      _user.eventosSeguidos = await ApiService().getEventosSeguidos(_user.id!);
      if(_user.eventosInscritos.containsKey(_idEvento)){
        _user.qr = await ApiService().getQrEvento(_user.eventosInscritos[_idEvento]!);
        setState(() {
          _qr =_user.qr!;
        });
      }
    }
    _evento = await ApiService().getEvento(_idEvento);
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _evento.galeriaDeFotos!.insert(0, _evento.fotoPrincipal!);
    _numPages = _evento.galeriaDeFotos!.length;
    _inscritos = _evento.inscritos!;
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        controller.uiLoading = false;
      });
    });
  }
  void _seguirActividad() async {
    await ApiService().setEventosSeguidos(_user.id!, _user.eventosSeguidos!);
    setState(() {
      _user.eventosSeguidos!.add(_idEvento);
    });
  }
  void _dejarDeSeguirActividad() async {
    await ApiService().setEventosSeguidos(_user.id!, _user.eventosSeguidos!);
    setState(() {
      _user.eventosSeguidos!.remove(_idEvento);
    });
  }
  void _inscribirseActividad() async {
    _evento = await ApiService().getEvento(_idEvento);
    if(_evento.capacidad! > -1){
      if(_evento.inscritos! < _evento.capacidad!){
        int idInscripcion = await ApiService().crearInscripcionEvento(_user.id!, _idEvento);
        _user.eventosInscritos[_idEvento] = idInscripcion;
        setState(() {
          _inscritos++;
          Navigator.pop(context);
          showSnackBarWithFloating("Inscripción exitosa", Color.fromRGBO(32, 104, 14, 1));
        });
      }else{
        setState(() {
          _inscritos = _evento.inscritos!;
          Navigator.pop(context);
          showSnackBarWithFloating("Lo sentimos, cupos agotados", Color.fromRGBO(255, 0, 0, 1));
        });
      }
    }else{
      int idInscripcion = await ApiService().crearInscripcionEvento(_user.id!, _idEvento);
      _user.eventosInscritos[_idEvento] = idInscripcion;
      setState(() {
        _inscritos++;
        Navigator.pop(context);
        showSnackBarWithFloating("Inscripción exitosa", Color.fromRGBO(32, 104, 14, 1));
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
          toolbarHeight: 50,
          title: Center(
            child: MyText(
              _evento.titulo!,
              style: TextStyle(
                fontSize: 18, // Tamaño del texto
                fontWeight: FontWeight.w600, // Peso del texto
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(LucideIcons.share),
              onPressed: () {
                // Acción al presionar el icono de compartir
              },
            ),
          ],
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
                if(_evento.fechaDeInicio!.isNotEmpty)
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
                            _evento.fechaDeInicio!,
                            fontSize: 14,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                    ),
                    if(_evento.fechaDeFin!.isNotEmpty)
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
                            _evento.fechaDeFin!,
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
                  margin: MySpacing.only(top: 12, bottom: 12),
                  child:  MyText.titleLarge(
                    _evento.titulo!,
                    fontSize: 18,
                    fontWeight: 800,
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(),
                Container(
                  margin: MySpacing.top(12),
                  child: MyText(
                    _evento.cuerpo!,
                    fontSize: 14,
                  ),
                ),
                _crearEtiquetas(),
                Visibility(
                  visible: _qr.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Código QR: ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        // Código QR con la frase "gian"
                        BarcodeWidget(
                          barcode: Barcode.qrCode(),
                          data: _qr,
                          width: 200,
                          height: 200,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                _evento.capacidad! > -1
                ? ((_evento.capacidad! - _inscritos) > 0
                    ? MyText.titleLarge(
                        "Cupos disponibles: ${_evento.capacidad! - _inscritos}",
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
                if(_isLoggedIn && _user.confirmed! && _user.completada!)
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: 16),
                  child: Wrap(
                    children: [
                        if(_user.eventosInscritos.containsKey(_idEvento))
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: MyButton.large(
                            padding: const EdgeInsets.fromLTRB(23, 23, 23, 23),
                            onPressed: () {},
                            elevation: 0,
                            splashColor: theme.colorScheme.onPrimary.withAlpha(60),
                            backgroundColor: Color.fromRGBO(32, 104, 14, 1),
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
                      if(!_user.eventosInscritos.containsKey(_idEvento) && ((_evento.capacidad!-_inscritos) > 0 || _evento.capacidad! == -1))
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: MyButton.medium(
                          buttonType: MyButtonType.outlined,
                          borderColor: Colors.black,
                          borderRadiusAll: 16.0,
                          splashColor: Color.fromRGBO(32, 104, 14, 1).withAlpha(60),
                          onPressed: () {
                            if (!_user.eventosInscritos.containsKey(_idEvento)) {
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
                      _user.eventosSeguidos!.contains(_idEvento)
                        ? Container(
                          margin: const EdgeInsets.all(8.0),
                          child: MyButton.large(
                            padding: const EdgeInsets.fromLTRB(23, 23, 23, 23),
                            onPressed: () {_dejarDeSeguirActividad();},
                            elevation: 0,
                            splashColor: theme.colorScheme.onPrimary.withAlpha(60),
                            backgroundColor: Color.fromRGBO(32, 104, 14, 1),
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
                if(_evento.calendario!.isNotEmpty)
                _crearCalendario(),
                if(_evento.calendario!.isNotEmpty)
                Divider(),
              ],
            ),
          ),
        ),
      );
    }
  }
  void showSnackBarWithFloating(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(message, color: theme.colorScheme.onPrimary),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                      "Texto de confirmación",
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
                          if (!_user.eventosInscritos.containsKey(_idEvento)) {
                            _inscribirseActividad();
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
            itemCount: _evento.calendario!.length,
            itemBuilder: (BuildContext context, int index) {
              final evento = _evento.calendario![index];
              return Container(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.keys.first,
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      evento.values.first,
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


  Widget _crearEtiquetas() {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 12),
      child: Wrap(
        spacing: 8.0, // Espacio entre elementos en el eje principal
        runSpacing: 8.0, // Espacio entre elementos en el eje transversal
        children: List.generate(
          _evento.etiquetas!.length,
          (index) {
            return Text(
              "#${_evento.etiquetas![index]}",
              style: TextStyle(fontSize: 14.0),
            );
          },
        ),
      ),
    );
  }
  List<Widget> _crearGaleria() {
    return _evento.galeriaDeFotos!.map((url) {
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
          child: Image.network(
            _backUrl + url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        ),
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
            _evento.categoria!,
            fontSize: 14,
            fontWeight: 500,
          ),
          Icon(LucideIcons.dot),
          MyText(
            _evento.publicacion!,
            fontSize: 14,
            fontWeight: 500,
          ),
        ],
      ),
    );
  }
}
