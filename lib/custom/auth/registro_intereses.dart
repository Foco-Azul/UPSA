import 'package:flutkit/custom/models/interes.dart';
import 'package:flutkit/custom/utils/validaciones.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/custom/widgets/progress_custom.dart';
import 'package:flutkit/helpers/extensions/extensions.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_container.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/helpers/widgets/my_text_style.dart';
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
  UserMeta _userMeta = UserMeta();
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
        MensajeTemporalInferior().mostrarMensaje(context,"Completaste tu cuenta con exito.",Color.fromRGBO(32, 104, 14, 1), Color.fromRGBO(255, 255, 255, 1));
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
      }
    } on Exception catch (e) {
      setState(() {
        _errores["error"] = e.toString().substring(11);
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
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              LucideIcons.chevronLeft,
              size: 20,
              color: theme.colorScheme.onBackground,
            ).autoDirection(),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  MyContainer.bordered(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    //margin: EdgeInsets.only(top: 100,),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(     
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: const <Widget>[
                              Icon(FontAwesomeIcons.addressCard, size: 40, color: Color.fromRGBO(215, 215, 215, 1),), // Icono a la izquierda
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[// Espacio entre el icono y el texto
                            MyText.titleLarge(
                              "👨‍🎨 ¿Cuáles son tus intereses?",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8), // Espacio entre el título y el texto
                        MyText.bodyMedium(
                          'Así podremos mejorar nuestra oferta de actividades para todos nuestros bachilleres.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(),
                        Wrap(
                          children: _buildChoiceList(),
                        ),
                        MySpacing.height(20),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              color: Color.fromRGBO(32, 104, 14, 1),
                              onPressed: () {
                                _validarCampos();
                              },
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              padding: MySpacing.xy(100, 16),
                              pressedOpacity: 0.5,
                              child: MyText.bodyMedium(
                                "Finalizar llenado",
                                color: theme.colorScheme.onSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        MySpacing.height(20),
                      ]
                    )
                  )
                ]
              ),
              if (_isInProgress == 0)
              Positioned.fill(
                child: ProgressEspera(
                  theme: theme, // Pasar el tema como argumento
                ),
              ),
            ]
          )
        )
      );
    } 
  }
 _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in _intereses) {
      choices.add(Container(
        padding: MySpacing.only(left: 0, right: 8, bottom: 16),
        child: ChoiceChip(
          checkmarkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selectedColor: Color.fromRGBO(32, 104, 14, 1),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText.bodyMedium(item.nombre!,
                color: _userMeta.intereses!.contains(item.id!)
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onBackground),
            ],
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
              color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
              width: 1.0, // Ancho del borde
            ),
            borderRadius: BorderRadius.circular(14), // Radio de borde
          ),
        ),
      ));
    }
    return choices;
  }
}