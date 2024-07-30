import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutter/material.dart';

class MensajeTemporalInferior {
  void mostrarMensaje(BuildContext context, String mensaje, String tipo) {
    SnackBar snackBar;

    switch (tipo) {
      case 'error':
        snackBar = SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_sharp, color: AppColorsMensaje.errorTexto), // Aplicar el color al icono
              SizedBox(width: 8), // Espacio entre el icono y el texto
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: AppColorsMensaje.errorTexto,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          backgroundColor: AppColorsMensaje.errorFondo,
          behavior: SnackBarBehavior.floating,
        );
        break;
      case 'exito':
        snackBar = SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_sharp, color: AppColorsMensaje.exitoTexto), // Icono de éxito
              SizedBox(width: 8), // Espacio entre el icono y el texto
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: AppColorsMensaje.exitoTexto,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          backgroundColor: AppColorsMensaje.exitoFondo,
          behavior: SnackBarBehavior.floating,
        );
        break;
      case 'notificacion':
        snackBar = SnackBar(
          content: Row(
            children: [
              Icon(Icons.notifications_none_sharp, color: AppColorsMensaje.notificacionTexto), // Icono de advertencia
              SizedBox(width: 8), // Espacio entre el icono y el texto
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: AppColorsMensaje.notificacionTexto,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          backgroundColor: AppColorsMensaje.notificacionFondo,
          behavior: SnackBarBehavior.floating,
        );
        break;
      default:
        snackBar = SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.blue, // Color predeterminado para otros tipos de mensajes
          behavior: SnackBarBehavior.floating,
        );
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}




