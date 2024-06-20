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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


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
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId('https://www.youtube.com/watch?v=YMx8Bbev6T4')!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

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
                YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                  ),
                  builder: (context, player) {
                    return Column(
                      children: [
                        player,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
