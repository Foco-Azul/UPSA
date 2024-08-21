import 'dart:async';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/etiqueta.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/models/inscripcion.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/retroalimentacion_screen.dart';
import 'package:flutkit/custom/screens/inicio/etiquetas_screen.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class EventoScreen extends StatefulWidget {
  const EventoScreen({Key? key, this.id=-1}) : super(key: key);
  final int id;
  @override
  _EventoScreenState createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  int _id = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  String _backUrl = "";
  Evento _evento = Evento();
  User _user = User();
  bool _isLoggedIn = false;
  bool _ingresoMostrado = false;
  bool _inscrito = false;
  bool _siguiendo = false;
  Inscripcion _inscripcion = Inscripcion();
  late AnimacionCarga _animacionCarga;
 
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
    _evento = await ApiService().getEventoPopulateConInscripcionesSeguidores(_id);
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      if(_user.rolCustom! == "estudiante" || true){
        _filtrarNoticias(_user.id!);
        if (_evento.seguidores!.contains(_user.id)) {
          _siguiendo =  true;
        }
        for (var item in _evento.inscripciones!) {
          if(item.user == _user.id){
            _inscrito =  true;
            _inscripcion =  item;
          }
        }
      }
    }else{
      _filtrarNoticias(-1);
    }
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _filtrarNoticias(int id){
    List<Noticia> aux = [];
    for (var item in _evento.noticias!) {
      if(item.usuariosPermitidos!.isNotEmpty){
        for (var item2 in item.usuariosPermitidos!) {
          if(item2 == id){
            aux.add(item);
          }
        }
      }else{
        aux.add(item);
      }
    }
    _evento.noticias = aux;
  } 
  void _seguirActividad() async {
    _animacionCarga.setMostrar(true);
    _evento.seguidores!.add(_user.id!);
    await ApiService().setEventoSeguidores(_evento.id!, _evento.seguidores!);
    setState(() {    
      _siguiendo = true;
    });
    _animacionCarga.setMostrar(false);
  }
  void _dejarDeSeguirActividad() async {
    _animacionCarga.setMostrar(true);
    _evento.seguidores!.remove(_user.id!);
    await ApiService().setEventoSeguidores(_evento.id!, _evento.seguidores!);
    setState(() {
      _siguiendo = false;
    });
    _animacionCarga.setMostrar(false);
  }
  void _inscribirseActividad() async {
    _animacionCarga.setMostrar(true);
    _evento = await ApiService().getEventoPopulateConInscripcionesSeguidores(_id);
    if(_evento.capacidad! > -1){
      if(_evento.inscritos! < _evento.capacidad!){
        await ApiService().crearInscripcionActividad(_user.id!, _id, "evento");
        setState(() {
          MensajeTemporalInferior().mostrarMensaje(context,"¡Inscrito! Presenta el código QR para ingresar al evento. Tus inscripciones las podrás ver en sus mismos eventos y en tu perfil.", "exito");
        });
      }else{
        setState(() {
          MensajeTemporalInferior().mostrarMensaje(context,"Lo sentimos, cupos agotados.","error");
        });
      }
    }else{
      await ApiService().crearInscripcionActividad(_user.id!, _id, "evento");
      setState(() {
        MensajeTemporalInferior().mostrarMensaje(context,"¡Inscrito! Presenta el código QR para ingresar al evento. Tus inscripciones las podrás ver en sus mismos eventos y en tu perfil.", "exito");
      });
    }
    _animacionCarga.setMostrar(false);
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => super.widget));
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
                  text: _evento.titulo!,
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
              _breadcrumbs(),
              _crearGaleriaImagenes(),
              _crearFechasInicioFin(FuncionUpsa.armarFechaDeInicioFin(_evento.fechaDeInicio!), FuncionUpsa.armarFechaDeInicioFin(_evento.fechaDeFin!)),
              _contenedorRetroalimentacion(),
              _contenedorDescripcion(),
              _crearCalendarioOpcional(_evento.calendario!.isNotEmpty),
              _crearIngresoOpcional(_inscrito),
              _crearSeguimientoOpcional((_evento.noticias!.isNotEmpty)),
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
  
  Widget _contenedorRetroalimentacion(){
    return Visibility(
      visible: (_isLoggedIn && _user.rolCustom == "estudiante" && _user.estado! == "Completado") && _inscrito && _inscripcion.asistencia! && FuncionUpsa.diferenciaDeFechas(_evento.fechaDeFin!, "", "fechaActual") >= -7 && FuncionUpsa.diferenciaDeFechas(_evento.fechaDeFin!, "", "fechaActual") < 0,
      child: Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.all(15.0),
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.live_help_outlined, // Reemplaza con el icono que desees
                  color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
                ), 
                SizedBox(width: 4.0), // Espaciado entre el icono y el texto
                Text(
                  "retroalimentación".toUpperCase(), // Primer texto
                  style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
                ),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0), // Ajusta los valores del margen según sea necesario
              child: Column(
                children: [
                  Text(
                    "¿Qué te pareció el evento? Dejanos tu opinión para que podamos mejorar.",
                    style: AppTextStyles.parrafo(color: AppColorStyles.oscuro1),
                  ),
                ]
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RetroalimentacionScreen(id: _evento.id!, tipo: "evento", titulo: _evento.titulo!,)));
                },
                style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                child: Text(
                  'Dejar reseña',
                  style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                ),
              ),
            )
          ],
        ),
      )
    );
  }
  Widget _crearSeguimientoOpcional(bool condicion){
    return Visibility(
      visible: condicion,
      child: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Seguimiento",
              style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1)
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Wrap(
                      children: _buildMasNoticias(),
                    ),
                  )
                ]
              ),
            ),
          ],
        )
      )
    );
  }
  Widget _crearFechasInicioFin(String inicio, String fin){
    return Container(
      margin: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "INICIA",
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
              ),
              Text(
                inicio,
                style: AppTextStyles.botonMayor()
              ),
            ],
          ),
          SizedBox( width: 30,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FINALIZA",
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
              ),
              Text(
                fin,
                style: AppTextStyles.botonMayor()
              ),
            ],
          ),
        ],
      )
    );
  }
  Widget _crearGaleriaImagenes(){
    return Container(
      margin: EdgeInsets.all(15), 
      child: Stack(
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
                return Container(
                  child: widget,
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10, // Añade esta línea para alinear a la izquierda
            child: _buildPageIndicatorStatic(),
          ),
        ],
      )
    );
  }
  Widget _crearIngresoOpcional(bool condicion){
    return Visibility(
      visible: (_isLoggedIn && _user.rolCustom == "estudiante" && _user.estado! == "Completado") && condicion,
      child: Container(
        padding: EdgeInsets.all(15), // Añade un padding si es necesario
        margin: EdgeInsets.all(15), // Añade un padding si es necesario
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Ingreso",
                  style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1)
                ),
                SizedBox(width: 8), // Espacio entre el texto y el icono
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _ingresoMostrado = !_ingresoMostrado; // Alterna el valor de _ingresoMostrado
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del Row al contenido
                        children: [
                          Icon(
                            _ingresoMostrado ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                            size: 24,
                            color: AppColorStyles.altTexto1,
                          ),
                          SizedBox(width: 8.0), // Espacio entre el icono y el texto
                          Text(
                            _ingresoMostrado ? 'Clic para ocultar' : 'Click para mostrar', // Texto que cambia según _ingresoMostrado
                            style: AppTitleStyles.tarjetaMenor(color: AppColorStyles.altTexto1)
                          ),
                        ],
                      ),
                    )
                  ]
                )
              ],
            ),
            Visibility(
              visible: _ingresoMostrado,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Presenta el código para ingresar al evento.",
                      style: AppTextStyles.parrafo(),
                    ),
                  ),
                  _mostrarIngreso(),
                  SizedBox(height: 15)
                ],
              )
            )
          ],
        ),
      )
    );
  }
  Widget _contenedorDescripcion(){
    String descripcion = _evento.descripcion!;
    return
      Container(
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.all(15),
        decoration: AppDecorationStyle.tarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descripcion,
              style: AppTextStyles.parrafo()
            ),
            _crearEtiquetas(),
            Visibility(
              visible: _inscrito && FuncionUpsa.diferenciaDeFechas(_evento.fechaDeFin!, "", "fechaActual") > 0,
              child: Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Text(
                  "Inscrito",
                  style: AppTextStyles.parrafo(color: AppColorStyles.altTexto1),
                ),
              ), 
            ),
            _botonesOpcionales((_isLoggedIn && _user.rolCustom == "estudiante" && _user.estado! == "Completado" && FuncionUpsa.diferenciaDeFechas(_evento.fechaDeFin!, "", "fechaActual") > 0), (!_inscrito && ((_evento.capacidad!-_evento.inscritos!) > 0 || _evento.capacidad! == -1)), _siguiendo),
          ],
        ),
      );
  }
  Widget _botonesOpcionales(bool condicion, condicionInscribirse, condicionSeguir){
    return Visibility(
      visible: condicion,
      child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Visibility(
              visible: condicionInscribirse,
              child: Container(
                margin: EdgeInsets.only(right: 15),
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_inscrito) {
                      _showBottomSheet(context);
                    }
                  },
                  style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                  child: Row(
                    children: [
                      Icon(LucideIcons.logIn, color: AppColorStyles.oscuro1), // Icono a la izquierda
                      SizedBox(width: 8.0), // Espacio entre el icono y el texto
                      Text(
                        'Inscribirse',
                        style: AppTextStyles.botonMenor(), // Estilo del texto del botón
                      )
                    ]
                  ),
                ),
              ),
            ),
            Visibility(
              visible: condicionSeguir,
              child: Container(
                margin: EdgeInsets.only(right: 15),
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    _dejarDeSeguirActividad();
                  },
                  style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                  child: Row(
                    children: [
                      Icon(LucideIcons.bellRing, color: AppColorStyles.oscuro1), // Icono a la izquierda
                      SizedBox(width: 8.0), // Espacio entre el icono y el texto
                      Text(
                        'Dejar de seguir',
                        style: AppTextStyles.botonMenor(), // Estilo del texto del botón
                      ),
                    ]
                  )
                ),
              ),
            ),
            Visibility(
              visible: !condicionSeguir,
              child: Container(
                margin: EdgeInsets.only(right: 15),
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    _seguirActividad();
                  },
                  style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
                  child: Row(
                    children: [
                      Icon(LucideIcons.bellRing, color: AppColorStyles.oscuro1),// Icono a la izquierda
                      SizedBox(width: 8.0), // Espacio entre el icono y el texto
                      Text(
                        'Seguir',
                        style: AppTextStyles.botonMenor(), // Estilo del texto del botón
                      ),
                    ]
                  )
                ),
              ),
            ),
          ],
        )
      )
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
              data: _inscripcion.qr!,
              width: 200,
              height: 200,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
  }
  _buildMasNoticias() {
    List<Widget> masNoticias = [];
    for (int index = 0; index < _evento.noticias!.length; index++) {
      Noticia noticia = _evento.noticias![index];
      masNoticias.add(InkWell(
        onTap: () {
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 3,)),(Route<dynamic> route) => false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: noticia.id!,)));
        },
        child: Container(
          margin: EdgeInsets.only(right: 15),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.65, // 65% del ancho de la pantalla
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                      image: NetworkImage(_backUrl + noticia.imagen!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 150,
                  width: MediaQuery.of(context).size.width * 0.65, // 65% del ancho de la pantalla
                ),
                Text(
                  noticia.titulo!,
                  style: AppTitleStyles.tarjetaMenor()
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
                          if (!_inscrito) {
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
  Widget _crearCalendarioOpcional(bool condicion) {
    List<Map<String, dynamic>> calendarios = _evento.calendario!;
    return Visibility(
      visible: condicion,
      child: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Info",
              style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1)
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: calendarios.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calendarios[index]["titulo"]!,
                        style: AppTitleStyles.tarjetaMenor(),
                      ),
                      Visibility(
                        visible: calendarios[index]["descripcion"].toString().isNotEmpty,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            calendarios[index]["descripcion"]!,
                            style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                          ),
                        )
                      ),
                      Visibility(
                        visible: calendarios[index]["horaDeInicio"]!.toString().isNotEmpty || calendarios[index]["fechaDeInicio"]!.toString().isNotEmpty,
                        child: Text(
                          calendarios[index]["horaDeInicio"]!.toString().isNotEmpty ? calendarios[index]["fechaDeInicio"]! + " - " + calendarios[index]["horaDeInicio"] : calendarios[index]["fechaDeInicio"], 
                          style: AppTextStyles.parrafo(color: AppColorStyles.gris1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      )
    );
  }
  Widget _crearEtiquetas() {
    List<Etiqueta> etiquetas = _evento.etiquetas!;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Wrap(
        spacing: 8.0, // Espacio entre elementos en el eje principal
        runSpacing: 8.0, // Espacio entre elementos en el eje transversal
        children: List.generate(
          etiquetas.length,
          (index) {
            return InkWell(
              onTap: () {
                //Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EtiquetasScreen(etiqueta: etiquetas[index].nombre!,)));
              },
              child: Text(
                "#${etiquetas[index].nombre}",
                style: AppTextStyles.parrafo(color: AppColorStyles.altTexto1),
              ),
            );
          },
        ),
      ),
    );
  }
  List<Widget> _crearGaleria() {
    return _evento.imagenes!.map((url) {
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
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.network(
            _backUrl + url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        )
      );
    }).toList();
  }
  Widget _buildPageIndicatorStatic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4), // Padding interno del contenedor
          decoration: BoxDecoration(
            color: AppColorStyles.altTexto1, // Color de fondo del contenedor
            borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
          ),
          child: Text(
            '${_currentPage + 1}/${_evento.imagenes!.length}',
            style: AppTextStyles.etiqueta(color: AppColorStyles.blanco)
          ),
        ),
      ],
    );
  }
  Widget _breadcrumbs() {
    Categoria categoria = _evento.categoria!;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
        children: [
          Text(
            "Evento",
            style: AppTextStyles.botonMenor(color: AppColorStyles.gris1)
          ),
          Icon(LucideIcons.dot, color: AppColorStyles.gris1),
          Text(
            categoria.nombre!,
            style: AppTextStyles.botonMenor(color: AppColorStyles.gris1)
          ),
           Icon(LucideIcons.dot, color: AppColorStyles.gris1),
          Text(
            _evento.publicacion!,
            style: AppTextStyles.botonMenor(color: AppColorStyles.gris1)
          ),
        ],
      ),
    );
  }
}