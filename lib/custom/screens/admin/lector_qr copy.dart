import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _outputController = TextEditingController();
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
      selectedValue = _eventos[0].id!;
    });
  }
  void _verificarQR(String codigo){
    Evento? evento = obtenerEventoPorId();
    if(evento != null){
      /*
      int estado = encontrarInscripcion(evento.inscripciones!, codigo);
      if(estado == 1){
        showSnackBarWithFloating("QR valido", Color.fromRGBO(32, 104, 14, 1));
      }else{
        if(estado == 0){
          showSnackBarWithFloating("QR ya escaneado", Color.fromRGBO(255, 0, 0, 1));
        }else{
          showSnackBarWithFloating("QR no valido", Color.fromRGBO(255, 0, 0, 1));
        }
      }
      */
    }
  }
  int encontrarInscripcion(List<Map<String, String>> inscripciones, String claveBuscada) {
    int res = -1;
    for (var inscripcion in inscripciones) {
      if (inscripcion["qr"]! ==claveBuscada) {
        if(inscripcion["asistencia"]! == "false"){
          _marcarAsistencia(int.parse(inscripcion["id"]!));
          res = 1;
        }else{
          res = 0;
        }
      }
    }
    return res;
  }
  void _marcarAsistencia(int inscripcionId) async{
    await ApiService().marcarAsistencia(inscripcionId);
  }
  Evento? obtenerEventoPorId() {
    try {
      return _eventos.firstWhere((evento) => evento.id! == selectedValue);
    } catch (e) {
      return null;
    }
  }


  Future _scan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    //String? barcode = "sdsadadsa";
    _outputController.text = barcode ?? "";
    _verificarQR(_outputController.text);
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
            body: Center( // Centra el contenido verticalmente
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
                          value: evento.id!,
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