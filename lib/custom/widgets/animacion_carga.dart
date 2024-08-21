import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutkit/custom/theme/styles.dart';

class AnimacionCarga {
  bool mostrar = false;
  final BuildContext context;
  OverlayEntry? _overlayEntry;

  AnimacionCarga({
    required this.context,
  }) {
    _crearOverlay(); // Crear el overlay al inicializar la clase
  }

  void _crearOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: AppColorStyles.altFondo1.withOpacity(0.5), // Color semi-transparente
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColorStyles.altTexto1),
                  ),
                  SizedBox(width: 20,),
                  Text(
                    "Espera por favor...",
                    style: AppTitleStyles.subtitulo(color: AppColorStyles.altTexto1),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setMostrar(bool mostrar) {
    if (this.mostrar != mostrar) {
      this.mostrar = mostrar;
      if (mostrar) {
        _mostrarOverlay();
      } else {
        _ocultarOverlay();
      }
    }
  }

  void _mostrarOverlay() {
    if (_overlayEntry != null && !_overlayEntry!.mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _ocultarOverlay() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry?.remove();
    }
  }
}
