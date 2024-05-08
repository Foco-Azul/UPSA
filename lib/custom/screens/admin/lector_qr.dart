import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class LectorQRScreen extends StatefulWidget {
  const LectorQRScreen({Key? key}) : super(key: key);

  @override
  _LectorQRScreenState createState() => _LectorQRScreenState();
}

class _LectorQRScreenState extends State<LectorQRScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  TextEditingController _outputController = new TextEditingController();
  int selectedValue = 0;
  List<Evento> _eventos = [];
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    _cargarDatos();
  }
  void _cargarDatos()async{
    _eventos = await ApiService().getEventos();
    setState(() {
      selectedValue = int.parse(_eventos[0].id!);
    });
  }
  void _verificarQR(String codigo){
    Evento? evento = obtenerEventoPorId();
    if(evento != null){
      if(encontrarInscripcion(evento.inscripciones, codigo) != null){
        showSnackBarWithFloating("QR valido", Color.fromRGBO(32, 104, 14, 1));
      }else{
        showSnackBarWithFloating("QR no valido", Color.fromRGBO(255, 0, 0, 1));
      }
    }
  }
  Map<String, int>? encontrarInscripcion(List<Map<String, int>?>? inscripciones, String claveBuscada) {
    if (inscripciones == null) return null;
    for (var inscripcion in inscripciones) {
      if (inscripcion != null && inscripcion.containsKey(claveBuscada)) {
        _marcarAsistencia(inscripcion[claveBuscada]!);
        return inscripcion;
      }
    }

    return null;
  }
  void _marcarAsistencia(int inscripcionId) async{
    await ApiService().marcarAsistencia(inscripcionId);
  }
  Evento? obtenerEventoPorId() {
    try {
      return _eventos.firstWhere((evento) => int.parse(evento.id!) == selectedValue);
    } catch (e) {
      return null;
    }
  }


  Future _scan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      this._outputController.text = barcode;
      _verificarQR(this._outputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, value, child) {
        isDark = AppTheme.themeType == ThemeType.dark;
        textDirection = AppTheme.textDirection;
        theme = AppTheme.theme;
        customTheme = AppTheme.customTheme;
        return Theme(
          data: theme,
          child: Scaffold(
            key: _drawerKey,
            body: Container(
              padding: MySpacing.fromLTRB(20, 0, 20, 20),
              child: Center( // Centra el contenido verticalmente
                child: ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      child: DropdownButton<int>(
                        dropdownColor: Colors.white, // Establece el color de fondo de las opciones
                        value: selectedValue,
                        onChanged: (int? id) {
                          setState(() {
                            selectedValue = id!;
                          });
                        },
                        items: _eventos.map<DropdownMenuItem<int>>((Evento evento) {
                          return DropdownMenuItem<int>(
                            value: int.parse(evento.id!),
                            child: Text(evento.titulo!),
                          );
                        }).toList(),
                      )
                    ),

                    Container(
                      margin: const EdgeInsets.all(8.0),
                      child: MyButton.medium(
                        buttonType: MyButtonType.outlined,
                        borderColor: Colors.black,
                        borderRadiusAll: 16.0,
                        splashColor: Color.fromRGBO(32, 104, 14, 1).withAlpha(60),
                        onPressed: () {
                          _scan();
                        },
                        elevation: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido horizontalmente
                          children: [
                            Icon(LucideIcons.qrCode, color: Colors.black), // Icono antes del texto
                            SizedBox(width: 8.0), // Espacio entre el icono y el texto
                            MyText.bodyMedium(
                              'Escanear QR',
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void showSnackBarWithFloating(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(message, color: theme.colorScheme.onPrimary),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}