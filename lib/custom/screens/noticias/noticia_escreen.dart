import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/etiqueta.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/inicio/etiquetas_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/foto_full_screen.dart';
import 'package:flutkit/custom/widgets/video_full_vertical_screen.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class NoticiaScreen extends StatefulWidget {
  const NoticiaScreen({Key? key, this.idNoticia=-1}) : super(key: key);
  final int idNoticia;
  @override
  _NoticiaScreenState createState() => _NoticiaScreenState();
}

class _NoticiaScreenState extends State<NoticiaScreen> {
  int _idNoticia = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  String _backUrl = "";
  Noticia _noticia = Noticia();
  List<Noticia> _otrasNoticias = [];
  User _user = User();
  bool _isLoggedIn = false;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  
  @override
  void initState() {
    super.initState();
    _idNoticia = widget.idNoticia;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
  }
  
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _noticia = await ApiService().getNoticia(_idNoticia);
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Noticias_${FuncionUpsa.limpiarYReemplazar(_noticia.titulo!)}',
      screenClass: 'Noticias_${FuncionUpsa.limpiarYReemplazar(_noticia.titulo!)}', // Clase o tipo de pantalla
    );
    _otrasNoticias = await ApiService().getOtrasNoticias(_idNoticia);
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      if(_user.rolCustom! == "estudiante"){
        _filtrarNoticias(_user.id!);
      }
    }else{
      _filtrarNoticias(-1);
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _filtrarNoticias(int id){
    List<Noticia> aux = [];
    for (var item in _otrasNoticias) {
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
    _otrasNoticias = aux;
  } 

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getCartLoadingScreen(
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
          toolbarHeight: (_noticia.titulo!.length <= 42 ? 50.0 : ((50+(30*((((_noticia.titulo!.length) / 21).ceil())-2)))).toDouble()),
          title: Center(
            child: Container(
              padding: const EdgeInsets.only(right: 50.0),
              child: Text(
                _noticia.titulo!,
                style: AppTitleStyles.principal(),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _breadcrumbs(),
              _crearGaleriaImagenes(),
              _contenedorDescripcion(),
              _crearSeguimientoOpcional(_otrasNoticias.isNotEmpty),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 3,
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
            '${_currentPage + 1}/${_noticia.imagenes!.length}',
            style: AppTextStyles.etiqueta(color: AppColorStyles.blanco)
          ),
        ),
      ],
    );
  }
  List<Widget> _crearGaleria() {
    int pos = 0;
    return _noticia.imagenes!.map((url) {
      if(_noticia.video!.isNotEmpty && pos == 0){
        pos++;
        return Stack(
          children: [
            Container(
              width: double.infinity, // Asegura que el contenedor ocupe todo el ancho disponible
              height: double.infinity,
              decoration: BoxDecoration(
                color: customTheme.card,
                borderRadius: BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: customTheme.shadowColor.withAlpha(120),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Image.network(
                  _backUrl + url,
                  height: 240.0,
                  width: double.infinity, // Asegura que la imagen ocupe todo el ancho disponible
                  fit: BoxFit.contain,
                ),
              ),
            ),/*
            Positioned(
              bottom: 8, // Ajusta la posición del ícono según tu preferencia
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Acción al pulsar el ícono
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenVideo(videoUrl: _backUrl + _noticia.video!),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColorStyles.altTexto1, // Color de fondo del contenedor
                    borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
                  ),
                  child: Icon(
                    Icons.play_arrow_outlined, // Cambia al ícono que prefieras
                    color: AppColorStyles.blanco, // Color del ícono
                    size: 24.0, // Tamaño del ícono
                  ),
                )
              ),
            ),*/
          ],
        );
      }else{
        return Stack(
          children: [
            Container(
              width: double.infinity, // Asegura que el contenedor ocupe todo el ancho disponible
              height: double.infinity,
              decoration: BoxDecoration(
                color: customTheme.card,
                borderRadius: BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: customTheme.shadowColor.withAlpha(120),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Image.network(
                  _backUrl + url,
                  height: 240.0,
                  width: double.infinity, // Asegura que la imagen ocupe todo el ancho disponible
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 8, // Ajusta la posición del ícono según tu preferencia
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Acción al pulsar el ícono
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(imageUrl: _backUrl + url),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColorStyles.altTexto1, // Color de fondo del contenedor
                    borderRadius: BorderRadius.circular(24.0), // Borde redondeado con radio de 24
                  ),
                  child: Icon(
                    Icons.fullscreen_outlined, // Cambia al ícono que prefieras
                    color: AppColorStyles.blanco, // Color del ícono
                    size: 24.0, // Tamaño del ícono
                  ),
                )
              ),
            ),
          ],
        );
      }
    }).toList();
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
              "Más noticias",
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
  Widget _contenedorDescripcion(){
    String descripcion = _noticia.descripcion!;
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
              visible: _noticia.notaCompleta!.isNotEmpty,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!await launchUrl(
                        Uri.parse(_noticia.notaCompleta!),
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw Exception('Could not launch ${_noticia.notaCompleta!}');
                      }
                  },
                  style: AppDecorationStyle.botonContacto(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.externalLink,
                        color: AppColorStyles.blanco
                      ),
                      SizedBox(width: 8.0), // Espacio entre el icono y el texto
                      Text(
                        'Ver nota completa',
                        style: AppTextStyles.botonMenor(color: AppColorStyles.blanco), // Estilo del texto del botón
                      ),
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      );
  }
  Widget _crearEtiquetas() {
    List<Etiqueta> etiquetas = _noticia.etiquetas!;
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
  Widget _breadcrumbs() {
    Categoria categoria = _noticia.categoria!;
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0), // Aquí agregas el margin bottom
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
          children: [
            Text(
              "Noticia",
              style: AppTextStyles.botonMenor(color: AppColorStyles.gris1),
            ),
            Icon(LucideIcons.dot, color: AppColorStyles.gris1),
            Text(
              categoria.nombre!,
              style: AppTextStyles.botonMenor(color: AppColorStyles.gris1),
            ),
            Icon(LucideIcons.dot, color: AppColorStyles.gris1),
            Text(
              _noticia.publicacion!,
              style: AppTextStyles.botonMenor(color: AppColorStyles.gris1),
            ),
          ],
        ),
      ),
    );
  }
  _buildMasNoticias() {
    List<Widget> masNoticias = [];
    for (int index = 0; index < _otrasNoticias.length; index++) {
      Noticia noticia = _otrasNoticias[index];
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
                      fit: BoxFit.contain,
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
}
