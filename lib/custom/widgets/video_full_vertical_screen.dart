import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FullScreenVideo extends StatefulWidget {
  const FullScreenVideo({Key? key, this.videoUrl=""}) : super(key: key);
  final String videoUrl;
  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  //late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    /*_videoController = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl))
    ..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });*/

  }

  @override
  void dispose() {
    //_videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: AppColorStyles.blanco,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),/*
      body: Container(
        margin: EdgeInsets.only(bottom: 100),
        alignment: Alignment.topCenter,
        child: _videoController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          )
        : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColorStyles.blanco,
        onPressed: () {
          setState(() {
            _videoController.value.isPlaying
                ? _videoController.pause()
                : _videoController.play();
          });
        },
        child: Icon(
          _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: AppColorStyles.altTexto1,
        ),
      ),*/
    );
  }
}
