import 'package:flutkit/custom/models/interes.dart';
import 'package:flutkit/custom/models/user_meta.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutkit/loading_effect.dart';

class RegistroIntereses extends StatefulWidget {
  @override
  _RegistroInteresesState createState() => _RegistroInteresesState();
}
 
class _RegistroInteresesState extends State<RegistroIntereses> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late ProfileController controller;
  Validacion validacion = Validacion();
  final UserMeta _userMeta = UserMeta();
  User _user = User();
  int _isInProgress = -1;
  final Map<String, String> _errores = {
    "intereses": "",
  };
  List<String> selectedChoices = [];
  List<Interes> _intereses = [];
  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    controller = ProfileController();
    cargarDatos();
  }
  void cargarDatos() async{
     _user = Provider.of<AppNotifier>(context, listen: false).user;
    _intereses = await ApiService().getIntereses();
    _userMeta.intereses = [];
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _validarCampos(){
    setState(() {
    });

    if (_errores["intereses"]!.isEmpty) {
      _registrarIntereses();
    }
  }
  void _registrarIntereses() async {
    try {
      setState(() {
        _isInProgress = 0;
      });
      bool bandera = await ApiService().registrarIntereses(_userMeta, _user.id!);
      if(!bandera) {
        setState(() {
          _errores["error"] = "Algo salio mal, intentalo màs tarde";
          _isInProgress = -1;
        });
      } else {
        _user.estado = "Completado";
        Provider.of<AppNotifier>(context, listen: false).setUser(_user);
        setState(() {
          _isInProgress = -1;
        });
        MensajeTemporalInferior().mostrarMensaje(context,"Completaste tu cuenta con exito.", "exito");
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
      }
    } on Exception catch (e) {
      setState(() {
        _errores["error"] = e.toString().substring(11);
        print(e);
        _isInProgress = -1;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getSearchLoadingScreen(
            context,
          ),
        ),
      );
    } else {
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
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(15),
                child: Column(     
                  children: <Widget>[
                    _crearTitulo(),
                    _crearDescripcion(),
                    _crearIntereses(),
                    _crearBoton(),
                  ]
                )
              ),
              if (_isInProgress == 0)
              Positioned.fill(
                child: ProgressEspera(
                  theme: theme, // Pasar el tema como argumento
                ),
              ),
            ]
          ),
        )
      );
    } 
  }
  Widget _crearIntereses(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Wrap(
        children: _buildChoiceList(),
      )
    );
  }
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        onPressed: () {
         _validarCampos();
        },
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Finalizar llenado',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
        ),
      ),
    );
  }
  Widget _crearDescripcion(){
    return Text(
      'Juramos, es la última pantalla.',
      style: TextStyle(
        color: AppColorStyles.oscuro1,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ),
    );
  }
  Widget _crearTitulo() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        "¿Cuáles son tus intereses?",
        style: AppTitleStyles.onboarding(color: AppColorStyles.verde1),
      ),
    );
  }
 _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in _intereses) {
      choices.add(Container(
        padding: MySpacing.only(left: 0, right: 8, bottom: 16),
        child: ChoiceChip(
          backgroundColor: AppColorStyles.blancoFondo,
          avatar: _userMeta.intereses!.contains(item.id!) ? Icon(Icons.check_circle_outline) : Icon(Icons.circle_outlined),
          checkmarkColor: AppColorStyles.blancoFondo,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selectedColor: AppColorStyles.verde2,
          label: Text(
            item.nombre!,
            style: TextStyle(
              color: _userMeta.intereses!.contains(item.id!)
              ? AppColorStyles.blancoFondo
              : AppColorStyles.verde2
            ),
          ),
          selected: _userMeta.intereses!.contains(item.id!),
          onSelected: (selected) {
            setState(() {
              _userMeta.intereses!.contains(item.id!)
                ? _userMeta.intereses!.remove(item.id!)
                : _userMeta.intereses!.add(item.id!);
            });
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColorStyles.verde2, // Color del borde
              width: 1.0, // Ancho del borde
            ),
            borderRadius: BorderRadius.circular(5), // Radio de borde
          ),
        ),
      ));
    }
    return choices;
  }
}