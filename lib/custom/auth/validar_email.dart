import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';

class ValidarEmail extends StatefulWidget {
  const ValidarEmail({Key? key}) : super(key: key);

  @override
  _ValidarEmailState createState() => _ValidarEmailState();
}
class _ValidarEmailState extends State<ValidarEmail> {
  String _token = "";
  String _errorToken = "";
  User _user = User();
  bool _errorVerificacion = false;
  late AnimacionCarga _animacionCarga;

  @override
  void initState() {
    super.initState();
    _animacionCarga = AnimacionCarga(context: context);
    _user = Provider.of<AppNotifier>(context, listen: false).user;
  }
  
  void verificarCodigo(String verificationCode){
    if (RegExp(r'[a-zA-Z]').hasMatch(verificationCode)) {
      setState(() {
        _errorToken = "El código de verificación solo puede contener números.";
      });
    }else{
      _token = verificationCode;
    }
  }
  void reenviarToken() async{  
    _animacionCarga.setMostrar(true);
    bool bandera = await ApiService().reenviarToken(_user.id!, _user.email!);
    if(bandera){
      MensajeTemporalInferior().mostrarMensaje(context,"Correo enviado satisfactoriamente.", "exito");
    }
    setState(() {
    });
    _animacionCarga.setMostrar(false);
  }
  void verificarCuenta() async{
    _animacionCarga.setMostrar(true);
    if(_token.isEmpty){
      setState(() {
        _errorToken = "El código es requerido.";
      });
    }else{
      User user = Provider.of<AppNotifier>(context, listen: false).user;
      bool bandera = await ApiService().verificarCuenta(user.id!, _token);
      if(bandera){
        user.confirmed = bandera;
        user.estado = "Verificado";
        Provider.of<AppNotifier>(context, listen: false).setUser(user);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4)),(Route<dynamic> route) => false);
        Navigator.push(context,MaterialPageRoute(builder: (context) => RegistroPerfil()));
      }else{
        Navigator.of(context).pop();
        setState(() {
          _errorVerificacion = true;
          _errorToken = "Codigo incorrecto.";
        });
      }
    }
    _animacionCarga.setMostrar(false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.altFondo1,
      appBar: AppBar(
        backgroundColor: AppColorStyles.altFondo1,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: AppColorStyles.oscuro1
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(right: 15, left: 15, bottom: 80),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _crearTitulo(),
            _crearDescripcion(),
            _crearCamposCodigo(),
            _crearBoton(),
            _textoFooter(),
          ],
        ),
      ),
    );
  }
  
  Widget _textoFooter(){
    return GestureDetector(
      onTap: () {
        reenviarToken();
      },
      child: Center(
        child: RichText(
          text: TextSpan(children: const <TextSpan>[
            TextSpan(
                text: "¿No recibiste un código? ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColorStyles.gris1)),
            TextSpan(
                text: "Envialo de nuevo",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColorStyles.altTexto1)),
          ]),
        ),
      ),
    );
  }
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: () {
          verificarCuenta();
        },
        style: AppDecorationStyle.botonBienvenida(colorFondo: AppColorStyles.altVerde1),
        child: Text(
          'Continuar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.oscuro1),  // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearCamposCodigo(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: OtpTextField(
        numberOfFields: 5,
        showFieldAsBox: true,
        fieldWidth: 50.0,
        borderRadius: BorderRadius.circular(14), // Ajusta el radio de borde para que sea más cuadrado
        keyboardType: TextInputType.number,
        focusedBorderColor: AppColorStyles.altTexto1, 
        onSubmit: (String verificationCode) {
          verificarCodigo(verificationCode);
        },
      ),
    );
  }
  Widget _crearDescripcion(){
    return Container(
      margin: MySpacing.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              "Verificá tu correo ingresando el código enviado a: ",
              style: AppTextStyles.parrafo(),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              _user.email!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColorStyles.altTexto1
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if(_errorToken.isNotEmpty || _errorVerificacion)
          Center(
            child: MyText.bodySmall(
              _errorToken,
              fontWeight: 500,
              height: 1.15,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ]
      )
    );
  }
  Widget _crearTitulo(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: MyText.titleLarge(
          "Verifiquemos que no sos un robot",
          style: AppTitleStyles.onboarding(color: AppColorStyles.altTexto1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
