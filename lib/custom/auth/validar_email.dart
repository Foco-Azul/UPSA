//import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/custom/auth/registro_perfil.dart';
import 'package:flutkit/custom/widgets/efectoCarga.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';

class ValidarEmail extends StatefulWidget {
  final ThemeData theme;
  final int estado;

  const ValidarEmail({Key? key, required this.theme, this.estado = 0}) : super(key: key);

  @override
  _ValidarEmailState createState() => _ValidarEmailState(estado: estado);
}
class _ValidarEmailState extends State<ValidarEmail> {
  final int estado;
  _ValidarEmailState({required this.estado});

  String _titulo = "", _texto1 = "", _token = "";
  String _errorToken = "";
  User _user = User();
  bool _seReenvio = false;
  bool _errorVerificacion = false;
  @override
  void initState() {
    super.initState();
    _user = Provider.of<AppNotifier>(context, listen: false).user;
    armarInformacion();
  }
  void armarInformacion(){
      _titulo = "Verifiquemos que no sos un robot";
      _texto1 = "Verifica tu correo ingresando el código enviado a: ";
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
    //int userId=39;
    //String email = "carlosvargasbazoalto@gmail.com";
    bool bandera = await ApiService().reenviarToken(_user.id!, _user.email!);
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
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 30,
            right: 30,
            top: MediaQuery.of(context).size.height * 0.2,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                MyContainer.bordered(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Icon(
                          LucideIcons.shieldCheck,
                          size: 40,
                          color: theme.colorScheme.onBackground.withAlpha(220),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: MyText.titleLarge(
                            _titulo,
                            fontWeight: 700,
                            fontSize: 20,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: MySpacing.top(16),
                              child: Center(
                                child: MyText.bodySmall(
                                  _texto1,
                                  fontWeight: 400,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Container(
                              margin: MySpacing.top(8),
                              child: Center(
                                child: MyText.bodySmall(
                                  _user.email!,
                                  fontWeight: 700,
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
                                numberOfFields: 5,
                                showFieldAsBox: true,
                                fieldWidth: 50.0,
                                borderRadius: BorderRadius.circular(14), // Ajusta el radio de borde para que sea más cuadrado
                                keyboardType: TextInputType.number,
                                focusedBorderColor: Color.fromRGBO(32, 104, 14, 1), 
                                onSubmit: (String verificationCode) {
                                  verificarCodigo(verificationCode);
                                },
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 26),
                              child: CupertinoButton(
                                color: Color.fromRGBO(32, 104, 14, 1),
                                onPressed: () {
                                  verificarCuenta();
                                },
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                padding: MySpacing.xy(100, 16),
                                pressedOpacity: 0.5,
                                child: MyText.bodyMedium(
                                  "Continuar",
                                  color: theme.colorScheme.onSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if(_seReenvio)
                Center(
                  child: MyText.bodySmall(
                    "Correo enviado satisfactoriamente.",
                    fontWeight: 500,
                    height: 1.15,
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    reenviarToken();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: "¿No recibiste un código? ",
                              style: MyTextStyle.bodyMedium(fontWeight: 400, fontSize: 14)),
                          TextSpan(
                              text: " Envialo de nuevo",
                              style: MyTextStyle.bodyMedium(
                                  fontWeight: 600,
                                  fontSize: 14,
                                  color: theme.colorScheme.primary)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MySpacing.safeAreaTop(context) + 12,
            left: 16,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                LucideIcons.chevronLeft,
                color: theme.colorScheme.onBackground,
              ),
            ),
          )
        ],
      )
    );
  }
}
