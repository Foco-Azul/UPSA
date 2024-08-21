import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecuperarContraseniaScreen extends StatefulWidget {
  static const namedRoute = "login2-screen";
  @override
  _RecuperarContraseniaScreenState createState() => _RecuperarContraseniaScreenState();
}

class _RecuperarContraseniaScreenState extends State<RecuperarContraseniaScreen> {
  bool? _passwordVisible = true;
  late CustomTheme customTheme;
  late ThemeData theme;
  String _email = "";
  String _codigoDeVerificacion = "";
  String _password = "";
  String _errorEmail = "";
  String _errorCodigoDeVerificacion = "";
  String _errorPassword = "";
  Validacion validacion = Validacion();
  String _paso = "email";
  User _user = User();
  
  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  void _verificarCuentaPorEmail() async{
    _errorEmail = validacion.validarCorreo(_email, true);
    if(_errorEmail.isEmpty){
      _user = await ApiService().getUserPorEmail(_email);
      if(_user.id! == -1){
        _errorEmail = "No se encontró la cuenta";
      }else{
        _errorEmail = "";
        _paso = "codigoDeVerificacion";
      }
    }
    setState(() {});
  }
  void _verificarCodigo() async{
    _errorCodigoDeVerificacion = validacion.validarCodigoDeVerificacion(_codigoDeVerificacion, true);
    if(_errorCodigoDeVerificacion.isEmpty){
      User usuario = await ApiService().getUserPorEmail(_user.email!);
      if(usuario.id! == -1){
        _errorCodigoDeVerificacion = "Código incorrecto";
      }else{
        _errorCodigoDeVerificacion = "";
        _paso = "password";
      }
    }
    setState(() {});
  }
  void _actualizarContrasenia() async{
    _errorPassword = validacion.validarContrasenia(_password, true);
    if(_errorPassword.isEmpty){
      User usuario = await ApiService().setActualizarContrasenia(_user.id!, _password);
      _errorPassword = "";
      if(usuario.id! == -1){
        MensajeTemporalInferior().mostrarMensaje(context,"Algo salió mal.", "error");
      }else{
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: 4,)),(Route<dynamic> route) => false);
        MensajeTemporalInferior().mostrarMensaje(context,"Se actualizó tu contraseña con exito.", "exito");
      }
    }
    setState(() {});
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
        margin: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _crearTituloConError(),
              _crearCampoConErrorOpcional(_errorEmail, "Email", "Email", "email", _paso == "email"),
              _crearCampoConErrorOpcional(_errorCodigoDeVerificacion, "Código de verificación", "Código de verificación", "codigoDeVerificacion", _paso == "codigoDeVerificacion"),
              _crearCampoPassConErrorOpcional(_paso == "password"),
              _crearBoton(),
            ],
          ),
        )
      ),
    );
  }
  Widget _crearTituloConError(){
    return Column(
      children: <Widget>[ // Espacio entre el icono y el texto
        Container(
          alignment: Alignment.centerLeft, 
          child: Text(
            "Cambia tu contraseña",
            style: AppTitleStyles.onboarding(color: AppColorStyles.altTexto1),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
  Widget _crearBoton(){
    String texto = "";
    if(_paso == "email" || _paso == "codigoDeVerificacion"){
      texto = "Continuar";
    }
    if(_paso == "codigoDeVerificacion"){
      texto = "Continuar";
    }
    if(_paso == "password"){
      texto = "Finalizar";
    }
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: () {
          if(_paso == "email"){
            _verificarCuentaPorEmail();
          }
          if(_paso == "codigoDeVerificacion"){
            _verificarCodigo();
          }
          if(_paso == "password"){
            _actualizarContrasenia();
          }
        },
        style: AppDecorationStyle.botonBienvenida(colorFondo: AppColorStyles.altVerde1),
        child: Text(
          texto,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.oscuro1), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearCampoConErrorOpcional(String error, String labelText, String hintText, String campo, bool condicion){
    return Visibility(
      visible: condicion,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: AppDecorationStyle.campoContainer(),
              child: TextField(
                onChanged: (value) {
                  if(campo == "email"){
                    _email = value;
                  }
                  if(campo == "codigoDeVerificacion"){
                    _codigoDeVerificacion = value;
                  }
                  setState(() {});
                },
                decoration: AppDecorationStyle.campoTexto(hintText: hintText, labelText: labelText),
                style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
              ),
            ),
            if (error.isNotEmpty)
            Text(
              error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ) 
    );
  }
  Widget _crearCampoPassConErrorOpcional(bool condicion){
    return Visibility(
      visible: condicion,
      child: Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: AppDecorationStyle.campoContainer(),
            child: TextField(
              onChanged: (value) {
                _password = value;
                setState(() {});
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Contraseña",
                labelText:  "Contraseña",
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: AppTextStyles.parrafo(color: AppColorStyles.altTexto1),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: AppColorStyles.altTexto1, // Color del borde cuando está enfocado
                    width: 2.0, // Ancho del borde cuando está enfocado
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible! ? LucideIcons.eyeOff : LucideIcons.eye),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible!;
                    });
                  },
                ),
              ),
              obscureText: _passwordVisible!,
              style: AppTextStyles.parrafo(color: AppColorStyles.gris1)
            ),
          ),
          if (_errorPassword.isNotEmpty)
          Text(
            _errorPassword,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    )
      
    );
  }
}