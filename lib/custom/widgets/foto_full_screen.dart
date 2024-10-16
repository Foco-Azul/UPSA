import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  String _imageUrl = "";
  double _rotation = 0;
  final PhotoViewController _controller = PhotoViewController();
  
  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl;
    _imageUrl = FuncionUpsa.obtenerImagenUrl(_imageUrl);
  }

  void _rotateImage() {
    setState(() {
      if(_rotation == 90){
        _rotation -= 90;
      }else{
        _rotation += 90;
      }
      _controller.rotation = _rotation * 3.1416 / 180; // Convert to radians
    });
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
            color: AppColorStyles.blanco
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.screen_rotation_outlined, color: AppColorStyles.blanco),
            onPressed: _rotateImage,
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(_imageUrl),
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
          controller: _controller,
        ),
      ),
    );
  }
}