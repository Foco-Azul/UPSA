import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActualizacionScreen extends StatefulWidget {
  const ActualizacionScreen({Key? key, this.isAndroid = true, this.android = "", this.ios = "",}) : super(key: key);
  final bool isAndroid;
  final String android;
  final String ios;
  @override
  _ActualizacionScreenState createState() => _ActualizacionScreenState();
}

class _ActualizacionScreenState extends State<ActualizacionScreen> {
  bool _isAndroid = true;
  String _android = "";
  String _ios = "";

  @override
  void initState() {
    super.initState();
    _isAndroid = widget.isAndroid;
    _android = widget.android;
    _ios = widget.ios;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.verdeFondo,
      appBar: AppBar(
        backgroundColor: AppColorStyles.verdeFondo,
        centerTitle: true,
        title: Text(
          "Actualizacción de app",
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
                Icons.app_shortcut_outlined, // Reemplaza con el icono que desees
                color: AppColorStyles.verde1, // Ajusta el color si es necesario
              ), 
              SizedBox(width: 4.0), // Espaciado entre el icono y el texto
              Text(
                "Nueva versión DE NIBU disponbile".toUpperCase(), // Primer texto
                style: AppTextStyles.etiqueta(color: AppColorStyles.verde1),
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
                    'Actualizá para contar con las siguientes novedades.',
                    style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4,),
                  child: Divider(),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '1. Momentum\n2. Impulso\n3. Torque',
                    style: AppTextStyles.parrafo(color: AppColorStyles.oscuro2),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Divider(),
                ),
              ]
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () async{
                // Acción que deseas realizar al pulsar el Container
                if(_isAndroid){
                  await launchUrl(Uri.parse(_android), mode: LaunchMode.externalApplication,);
                }else{
                  await launchUrl(Uri.parse(_ios), mode: LaunchMode.externalApplication,);
                }
              },
              style: AppDecorationStyle.botonContacto(),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Icon(Icons.get_app_outlined, color: AppColorStyles.blancoFondo), // Icono a la izquierda
                    SizedBox(width: 8.0), // Espacio entre el icono y el texto
                    Text(
                      _isAndroid ? 'Actualizar en Google Play' : 'Actualizar en App Store',
                      style: AppTextStyles.botonMenor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
