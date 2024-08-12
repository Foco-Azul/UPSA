
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
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
      body: ListView(
        children: [
          _crearContenido(
            'lib/custom/assets/images/logo.png',
            'Tenemos una nueva version de la app UPSA',
            'Actualizá la app para disfrutar de todos los beneficios.'
          ),
        ],
      )
    );
  }

  Widget _crearContenido(String imagen, String titulo, String descripcion){
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 100),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 250.0,
                child: Image.asset(
                  imagen,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColorStyles.verde1, height: 1,), textAlign: TextAlign.center,),
              SizedBox(
                height: 20,
              ),
              Text(descripcion, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColorStyles.gris1, height: 1.5), textAlign: TextAlign.center),
              GestureDetector(
                onTap: () async{
                  // Acción que deseas realizar al pulsar el Container
                  if(_isAndroid){
                    await launchUrl(Uri.parse(_android), mode: LaunchMode.externalApplication,);
                  }else{
                    await launchUrl(Uri.parse(_ios), mode: LaunchMode.externalApplication,);
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: SizedBox(
                    width: 315.0,
                    child: Image.asset(
                      _isAndroid ? "lib/custom/assets/images/google_play.png" : "lib/custom/assets/images/app_store.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
