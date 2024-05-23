import 'package:flutter/material.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';

class MensajeTemporalInferior {
  void mostrarMensaje(BuildContext context, String mensaje, Color backgroundColor, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(mensaje, color: color),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
