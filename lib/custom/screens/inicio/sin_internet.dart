import 'package:flutkit/custom/models/configuracion.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SinInternetScreen extends StatefulWidget {
  const SinInternetScreen({Key? key,}) : super(key: key);
  @override
  _SinInternetScreenState createState() => _SinInternetScreenState();
}

class _SinInternetScreenState extends State<SinInternetScreen> {

  late AnimacionCarga _animacionCarga;

  @override
  void initState() {
    super.initState();
    _animacionCarga = AnimacionCarga(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.altFondo1,
      appBar: AppBar(
        backgroundColor: AppColorStyles.altFondo1,
        centerTitle: true,
        title: Text(
          "No se puede acceder",
          style: AppTitleStyles.principal()
        ),
      ),
      body: ListView(
        children: [
          _crearTarjeta(),
        ],
      )
    );
  }
  Widget _crearTarjeta(){
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.all(15.0),
      decoration: AppDecorationStyle.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.signal_wifi_connected_no_internet_4_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.altTexto1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Sin acceso a internet".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.only(top: 15.0, bottom: 10), // Ajusta los valores del margen según sea necesario
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child:  Text(
                    'Revisa tu coneccion a internet',
                    style: AppTextStyles.parrafo(color: AppColorStyles.oscuro1),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4,),
                  child: Divider(),
                ),
              ]
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () async{
                _animacionCarga.setMostrar(true);
                Configuracion configuracion = await ApiService().getConfiguracion();
                if(configuracion.version! != "-1"){
                  _animacionCarga.setMostrar(false);
                  Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
                }else{
                  MensajeTemporalInferior().mostrarMensaje(context,"No se pudo conectar a internet.", "error");
                }
                _animacionCarga.setMostrar(false);
                setState(() {
                  
                });
              },
              style: AppDecorationStyle.botonContacto(color: AppColorStyles.altVerde2),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Icon(Icons.replay_outlined, color: AppColorStyles.altTexto1), // Icono a la izquierda
                    SizedBox(width: 8.0), // Espacio entre el icono y el texto
                    Text(
                      'Reintentar',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.altTexto1), // Estilo del texto del botón
                    ),
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}
