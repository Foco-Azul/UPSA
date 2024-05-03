import 'package:flutkit/custom/auth/registro_estudiante.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';

class ValidarEmail extends StatefulWidget {
  final ThemeData theme;
  final int estado;

  const ValidarEmail({Key? key, required this.theme, this.estado = 0}) : super(key: key);

  @override
  _ValidarEmailState createState() => _ValidarEmailState(estado: this.estado);
}
class _ValidarEmailState extends State<ValidarEmail> {
  final int estado;
  _ValidarEmailState({required this.estado});

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
      bool bandera = await ApiService().verificarCuenta(user.id!, _token);
      if(bandera){
        user.confirmed = bandera;
        Provider.of<AppNotifier>(context, listen: false).setUser(user);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4)),(Route<dynamic> route) => false);
        Navigator.push(context,MaterialPageRoute(builder: (context) => RegistroEstudiante()));
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
                          Icons.person_outline,
                          size: 40,
                          color: theme.colorScheme.onBackground.withAlpha(220),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 24, top: 8),
                        child: MyText.titleLarge(_titulo, fontWeight: 600),
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
                              margin: EdgeInsets.only(top: 16),
                              child: MyButton.block(
                                  elevation: 0,
                                  borderRadiusAll: 4,
                                  padding: MySpacing.y(20),
                                  onPressed: () => verificarCuenta(),
                                  child: MyText.labelMedium(
                                      "VERIFICAR CUENTA",
                                      fontSize: 12,
                                      fontWeight: 600,
                                      color: theme.colorScheme.onPrimary,
                                      letterSpacing: 0.5)),
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
                              text: "Reenviar código de verificación",
                              style: MyTextStyle.bodyMedium(
                                  fontWeight: 600,
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
