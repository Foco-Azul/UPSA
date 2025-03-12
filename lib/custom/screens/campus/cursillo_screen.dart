import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/cursillo.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class CursilloScreen extends StatefulWidget {
  const CursilloScreen({Key? key, this.id = -1}) : super(key: key);
  final int id;
  @override
  _CursilloScreenState createState() => _CursilloScreenState();
}

class _CursilloScreenState extends State<CursilloScreen> {
  int _id = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
  //late YoutubePlayerController _controller;
  bool _isPlayerInFullScreen = false;
  Cursillo _cursillo = Cursillo();
  List<Cursillo> _cursillosData = [];
  final List<int> _cursillos = [];
  int _anterior = -1;
  int _siguiente = -1;
  bool _isLoggedIn = false;
  late YoutubePlayerController _controllerVideo;
  
  @override
  void initState() {
    super.initState();
    _id = widget.id;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _id = widget.id;
    //_controllerVideo.setLoop();
    _cargarDatos();
  }
  String extractYoutubeId(String url) {
    String res = "";
    final RegExp regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|.*?[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );

    final match = regExp.firstMatch(url);

    if (match != null) {
      res = match.group(1).toString();
    }
    return res;
  }
  void _enterFullscreen() {
    _controllerVideo.exitFullScreen(lock: true);
    _controllerVideo.enterFullScreen(lock: true);
    _isPlayerInFullScreen = true;
  }
  void _exitFullScreen() {
    _controllerVideo.enterFullScreen(lock: true);
    _controllerVideo.exitFullScreen(lock: true);
    _isPlayerInFullScreen = false;
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      User user = Provider.of<AppNotifier>(context, listen: false).user;
      await ApiService().setUserCursillosVistos(user.id!, _id);
    }
    _cursillo = await ApiService().getCursilloPopulate(_id);
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Cursos_${FuncionUpsa.limpiarYReemplazar(_cursillo.titulo!)}',
      screenClass: 'Cursos_${FuncionUpsa.limpiarYReemplazar(_cursillo.titulo!)}', // Clase o tipo de pantalla
    );
    _cursillosData = await ApiService().getCursillosPopulate();
    _armarProximos();
    _controllerVideo = YoutubePlayerController.fromVideoId(
      videoId: extractYoutubeId(_cursillo.urlVideo!),
      autoPlay: true,
      params: YoutubePlayerParams(
        showFullscreenButton: false,
        loop: true,
        interfaceLanguage: 'es',
        enableCaption: false,
        enableKeyboard: true,
      ),
    );
    /*
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_cursillo.urlVideo!)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    */
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _armarProximos(){
    List<Categoria> categorias = [];
    for (var item in _cursillosData) {
      bool existe = false;
      for (var item2 in categorias) {
        if(item2.nombre == item.categoria!.nombre){
          existe = true;
          break;
        }
      }
      if(!existe){
        categorias.add(item.categoria!);
      }
    }
    for (var item in categorias) {
      for (var item2 in _cursillosData) {
        if(item2.categoria!.nombre == item.nombre){
          _cursillos.add(item2.id!);
        }
      }
    }
    for (int i = 0; i < _cursillos.length; i++) {
      if (_cursillos[i] == _id) {
        if(i < _cursillos.length-1){
          _siguiente = _cursillos[i+1];
        }
        if(i > 0){
          _anterior = _cursillos[i-1];
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getProductLoadingScreen(
            context,
          ),
        ),
      );
    } else {
      return PopScope(
        onPopInvoked: (canPop) {
          if (canPop) {
            _exitFullScreen();
          } 
        },
        child: Scaffold(
          appBar: !_isPlayerInFullScreen ? AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: AppColorStyles.altFondo1,
            centerTitle: true, // Centra el título del AppBar
            title: Text(
              _cursillo.categoria!.nombre!,
              style: AppTitleStyles.principal(),
            ),
          ) : null,
          backgroundColor: AppColorStyles.altFondo1,
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(_isPlayerInFullScreen ? 0 : 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _videoYoutube(),
                  _descripcion(),
                ],
              ),
            ),
          ),
          floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: _isPlayerInFullScreen ? 50 : 0),
            child: FloatingActionButton.small(
              backgroundColor: AppColorStyles.blanco,
              onPressed: () {
                setState(() {
                  if(_isPlayerInFullScreen){
                    _exitFullScreen();
                  }else{
                    _enterFullscreen();
                  }
                });
              },
              child: Icon(
                _isPlayerInFullScreen ? Icons.fullscreen_exit_outlined : Icons.fullscreen_outlined,
                color: AppColorStyles.altTexto1,
              ),
            ),
          ),
          bottomNavigationBar: !_isPlayerInFullScreen ? FlashyTabBar(
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
          ) : null
        )
      );
    }
  } 
  
  Widget _descripcion(){
    return
      Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColorStyles.blanco, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _cursillo.titulo!,
              style: AppTitleStyles.tarjeta(color: AppColorStyles.altTexto1),
            ),
            SizedBox(height: 10,),
            Text(
              _cursillo.descripcion!,
              style: AppTextStyles.parrafo(),
            ),
            _crearBotones(),
          ],
        ),
      );
  }
  Widget _crearBotones() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Visibility(
            visible: _anterior > 0,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CursilloScreen(id: _anterior)));
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
            visible: _siguiente > 0,
            child: Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CursilloScreen(id: _siguiente)));
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
        ],
      ),
    );
  }
  Widget _videoYoutube(){
    return YoutubePlayerScaffold(
      controller: _controllerVideo,
      aspectRatio: 16 / 8,
      builder: (context, player) {    
        return Column(
          children: [
            player,
          ],
        );
      },
    );
    /*
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
      ),
      builder: (context, player) {
        // Observar cambios en la altura del widget
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentHeight = context.size!.height;
          if (currentHeight > MediaQuery.of(context).size.height * 0.95) {
            // Probablemente esté en pantalla completa
            if (!_isPlayerInFullScreen) {
              setState(() {
                _isPlayerInFullScreen = true;
              });
            }
          } else {
            setState(() {
              _isPlayerInFullScreen = false;
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            });
          }
        });
        return Column(
          children: [
            player,
          ],
        );
      },
    );
    */
  }
}
