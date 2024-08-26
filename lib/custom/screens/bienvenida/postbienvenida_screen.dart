// ignore_for_file: avoid_print

import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:flutkit/custom/auth/register_screen.dart';
import 'package:flutkit/custom/screens/campus/sobre_nosotros_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PostBienvenidaScreen extends StatefulWidget {
  PostBienvenidaScreen({Key? key}) : super(key: key);

  @override
  _PostBienvenidaScreenState createState() => _PostBienvenidaScreenState();
}

class _PostBienvenidaScreenState extends State<PostBienvenidaScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.altFondo1,
      appBar: AppBar(
        backgroundColor: AppColorStyles.altFondo1,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
            },
            child: Container(
              margin: EdgeInsets.only(right: 15),
              child: Text(
                'Saltar',
                style: TextStyle(
                  color: AppColorStyles.gris2,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _crearImgen(),
          _crearContenedorPostBienvenida(),
        ],
      ),
    );
  }
  Widget _crearContenedorPostBienvenida(){
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColorStyles.altTexto1, // Establece el color de fondo
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Hace que el Column se adapte al tamaño de su contenido
            children: [
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 20),
                child: Icon(
                  Icons.rocket, // Icono que deseas mostrar
                  color: AppColorStyles.blanco, // Color del icono
                  size: 50, // Tamaño del icono
                ),
              ),
              Text(
                'Despegando',
                style: AppTitleStyles.onboarding(color: AppColorStyles.blanco),
              ),
              SizedBox(height: 15,),
              Text(
                'Iniciá tu vida universitaria junto a la UPSA.',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColorStyles.blanco),
                textAlign: TextAlign.center,
              ),
              _crearBoton("Registrar mi cuenta", "signup", AppColorStyles.oscuro1, AppColorStyles.altVerde1),
              _crearBoton("Iniciar Sesión", "login",AppColorStyles.oscuro1, AppColorStyles.altFondo1),
              Container(
                margin: MySpacing.only(top: 50, bottom: 15, left: 60, right: 60),
                child: Text.rich(
                  TextSpan(
                    text: 'Al registrar tu cuenta, aceptás nuestros ',
                    style: TextStyle(fontWeight: FontWeight.normal, height: 1.3, fontSize: 10, color: AppColorStyles.blanco),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Términos de uso',
                        style: TextStyle(decoration: TextDecoration.underline, decorationColor: AppColorStyles.blanco,  decorationThickness: 2),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SobreNosotrosScreen()));
                          },
                      ),
                      TextSpan( 
                        text: ' y ',
                      ),
                      TextSpan(
                        text: 'Políticas de privacidad',
                        style: TextStyle(decoration: TextDecoration.underline, decorationColor: AppColorStyles.blanco, decorationThickness: 2),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SobreNosotrosScreen()));
                          },
                      ),
                      TextSpan(
                        text: '.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _crearBoton(String texto, String tipo, Color colorTexto, Color colorFondo){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 15),
      child: ElevatedButton(
        onPressed: () {
          if(tipo == "login"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Login2Screen()));
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => Register2Screen()));
          }
        },
        style: AppDecorationStyle.botonBienvenida(colorFondo: colorFondo),
        child: Text(
          texto,
          style: AppTextStyles.botonMayor(color: colorTexto), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearImgen(){
    return Opacity(
      opacity: 0.5, // Establece el nivel de opacidad (0.0 a 1.0)
      child: Image.asset('lib/custom/assets/images/bienvenida_1.png', fit: BoxFit.cover),
    );
  }
}
