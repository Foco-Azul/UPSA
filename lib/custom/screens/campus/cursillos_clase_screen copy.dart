import 'dart:async';
//import 'package:chewie/chewie.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';


class CursillosClaseScreen extends StatefulWidget {
  const CursillosClaseScreen({Key? key}) : super(key: key);
  @override
  _CursillosClaseScreenState createState() => _CursillosClaseScreenState();
}

class _CursillosClaseScreenState extends State<CursillosClaseScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;
  late Timer timerAnimation;
   late VideoPlayerController _controller;
   bool _isFullScreen = false;
   //late ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse("https://upsa.focoazul.com/uploads/Mi_video_29_04_2024_1_b816dc7eb3.mp4")
    )
    ..initialize().then((_) {
      setState(() {});
      _controller.play();
    });
    /*
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 16 / 9, // Proporción de aspecto del video
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      allowFullScreen: true, // Permitir pantalla completa
    );*/
    _cargarDatos();
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
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
        appBar: AppBar(
          toolbarHeight: 50,
          centerTitle: true, // Centra el título del AppBar
          title: MyText(
            "Física",
            style: TextStyle(
              fontSize: 18, // Tamaño del texto
              fontWeight: FontWeight.w600, // Peso del texto
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: MySpacing.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _breadcrumbs(),
                /*
                Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : CircularProgressIndicator(),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200, // Tamaño deseado para el reproductor de video
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  ),
                )*/
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        persistentFooterButtons: <Widget>[
          IconButton(
            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullScreen,
          ),
        ],
      );
    }
  } 
  Widget _breadcrumbs() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
        children: [
          MyText(
            "Cursillo",
            fontSize: 14,
            fontWeight: 500,
          ),
          Icon(LucideIcons.dot),
          MyText(
            "25/02/2024",
            fontSize: 14,
            fontWeight: 500,
          ),
        ],
      ),
    );
  }
}
