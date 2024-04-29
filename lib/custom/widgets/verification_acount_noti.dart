import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/perfil/account_setting_screen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';

class VerificationDialog extends StatefulWidget {
  final ThemeData theme;
  final int estado;

  const VerificationDialog({Key? key, required this.theme, this.estado = 0}) : super(key: key);

  @override
  _VerificationDialogState createState() => _VerificationDialogState(estado: this.estado);
}
class _VerificationDialogState extends State<VerificationDialog> with SingleTickerProviderStateMixin {
  final int estado;
  _VerificationDialogState({required this.estado});

  String _titulo = "", _texto1 = "", _texto2 = "", _token = "";
  String _errorToken = "";

  bool _seReenvio = false;
  bool _errorVerificacion = false;
  @override
  void initState() {
    super.initState();
    armarInformacion();
  }
  void armarInformacion(){
    if(estado == 1){
      _titulo = "¡Gracias!";
      _texto1 = "Tu cuenta se ha creado satisfactoriamente.";
      _texto2 = "Por favor, revisa tu bandeja de entrada, se ha enviado un código de verificación a tu correo electrónico.";
    }else{
      _titulo = "¡Hola!";
      _texto1 = "Tu cuenta no esta verificada.";
      _texto2 = "Ingresa el código de verificación que enviamos a tu correo electronico.";
    }
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
    User user = Provider.of<AppNotifier>(context, listen: false).user;
    //int userId=39;
    //String email = "carlosvargasbazoalto@gmail.com";
    bool bandera = await ApiService().reenviarToken(user.id!, user.email!);
    setState(() {
      _seReenvio = bandera;
    });
  }
  void verificarCuenta() async{
    if(_token.isEmpty){
      setState(() {
        _errorToken = "El código es requerido.";
      });
    }else{
      User user = Provider.of<AppNotifier>(context, listen: false).user;
      //int userId=39;
      bool bandera = await ApiService().verificarCuenta(user.id!, _token);
      if(bandera){
        Navigator.popUntil(context, ModalRoute.withName('/'));
        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingScreen()));
        //Navigator.pop(context);
      }else{
        setState(() {
          _errorVerificacion = true;
          _errorToken = "Algo salio mal, intentalo más tarde.";
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), // Color semi-transparente
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              padding: MySpacing.xy(24, 16),
              margin: MySpacing.x(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: theme.colorScheme.onBackground.withAlpha(220),
                    ),
                  ),
                  Container(
                    margin: MySpacing.top(16),
                    child: Center(child: MyText.titleMedium(_titulo, fontWeight: 700)),
                  ),
                  Container(
                    margin: MySpacing.top(16),
                    child: Center(
                      child: MyText.bodySmall(
                        _texto1,
                        fontWeight: 600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Container(
                    margin: MySpacing.top(16),
                    child: Center(
                      child: MyText.bodySmall(
                        _texto2,
                        fontWeight: 500,
                        height: 1.15,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if(_errorToken.isNotEmpty || _errorVerificacion)
                  Container(
                    margin: MySpacing.top(16),
                    child: Center(
                      child: MyText.bodySmall(
                        _errorToken,
                        fontWeight: 500,
                        height: 1.15,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                  Container(
                    margin: MySpacing.top(16),
                    child: OtpTextField(
                      numberOfFields: 6,
                      borderColor: Color(0xFF512DA8),
                      showFieldAsBox: true,
                      keyboardType: TextInputType.number,
                      onSubmit: (String verificationCode) {
                        verificarCodigo(verificationCode);
                      },
                    ),
                  ),
                  Container(
                    margin: MySpacing.top(16),
                    child: Center(
                      child: MyButton(
                        backgroundColor: theme.colorScheme.primary,
                        borderRadiusAll: 4,
                        elevation: 0,
                        onPressed: () {
                          verificarCuenta();
                        },
                        padding: MySpacing.xy(18, 16),
                        child: MyText.bodySmall(
                          "VERIFICAR CUENTA",
                          fontWeight: 600,
                          letterSpacing: 0.3,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  if(!_seReenvio)
                  GestureDetector(
                    onTap: () {
                      reenviarToken();
                    },
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: "Reenviar código de verificación",
                              style: MyTextStyle.bodyMedium(
                                fontWeight: 600,
                                color: theme.colorScheme.primary
                              )
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  if(_seReenvio)
                  Container(
                    margin: MySpacing.top(16),
                    child: Center(
                      child: MyText.bodySmall(
                        "Correo enviado satisfactoriamente.",
                        fontWeight: 500,
                        height: 1.15,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
