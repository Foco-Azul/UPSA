import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/widgets/efecto_carga.dart';
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
  @override
  void initState() {
    super.initState();
    _user = Provider.of<AppNotifier>(context, listen: false).user;
    armarInformacion();
  }
  void armarInformacion(){
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
    bool bandera = await ApiService().reenviarToken(_user.id!, _user.email!);
    if(bandera){
      MensajeTemporalInferior().mostrarMensaje(context,"Correo enviado satisfactoriamente.", "exito");
    }
    setState(() {
    });
  }
  void verificarCuenta() async{
    if(_token.isEmpty){
      setState(() {
        _errorToken = "El código es requerido.";
      });
    }else{
      EfectoCarga.showPopup(context);
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.verdeFondo,
      appBar: AppBar(
        backgroundColor: AppColorStyles.verdeFondo,
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
        margin: EdgeInsets.only(right: 15, left: 15, bottom: 50),
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
                text: " Envialo de nuevo",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColorStyles.verde2)),
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
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Continuar',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
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
        focusedBorderColor: AppColorStyles.verde2, 
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
            child: MyText.bodySmall(
              "Verificá tu correo ingresando el código enviado a: ",
              style: AppTextStyles.parrafo(),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: MyText.bodySmall(
              _user.email!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
          style: AppTitleStyles.onboarding(color: AppColorStyles.verde1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
