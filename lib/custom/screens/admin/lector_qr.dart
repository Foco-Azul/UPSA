import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class LectorQRScreen extends StatefulWidget {
  const LectorQRScreen({Key? key}) : super(key: key);

  @override
  _LectorQRScreenState createState() => _LectorQRScreenState();
}

class _LectorQRScreenState extends State<LectorQRScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  final TextEditingController _outputController = TextEditingController();
  int selectedValue = 0;
  List<Map<String, dynamic>> _actividades = [];
  String _tipoSeleccionado = "";
  int _idSeleccionado = -1;
  String _error = "";
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    controller = ProfileController();
    _cargarDatos();
  }
  void _cargarDatos() async{
    _actividades = await ApiService().getActividadesConInscripciones();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _verificarQR(String codigo) async{
    bool bandera = false;
    for (var item in _actividades) {
      if(_tipoSeleccionado == item["tipo"] && _idSeleccionado == item["id"]){
        for (var item2 in item["entradas"]) {
          if(item2["qr"] == codigo){
            bandera = true;
            if(!item2["asistencia"]){
              await ApiService().marcarAsistencia(item2["id"]);
              item2["asistencia"] = true;
              _datosDeLaEntrada("valido", item["titulo"], item2);
            }else{
              _datosDeLaEntrada("escaneado", item["titulo"], item2);
            }
          }
        }
      }
    }
    if(!bandera){
      _datosDeLaEntrada("noValido", "", {});
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

  void _escanearEntrada() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    _outputController.text = barcode ?? "";
    _verificarQR(_outputController.text);
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
          centerTitle: true,
          title: MyText(
            "Escaner de entradas",
            style: AppTitleStyles.principal()
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _crearSelectorActividades(),
              _crearBoton(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blancoFondo,
          selectedIndex: 4,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.verde1,
              activeColor: AppColorStyles.verde1,
              icon: Icon(Icons.account_circle_sharp),
              title: Text(
                'Mi perfil',
                style: AppTextStyles.bottomMenu()
              ),
            ),
          ],
          onItemSelected: (index) {
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen(indice: index,)),(Route<dynamic> route) => false);
          },
        ),
      );
    }
  }
  
  void _datosDeLaEntrada(String caso, String titulo, Map<String, dynamic> entrada) {
    String texto = "";
    Color fondo = AppColorStyles.verdeFondo;
    if(caso == "noValido"){
      texto = "Error, este QR no es valido"; 
      fondo = Colors.red;
    }
    if(caso == "escaneado"){
      texto = "Error, este QR ya fue escaneado"; 
      fondo = Colors.red;
    }
    if(caso == "valido"){
      texto = "Exito, el QR se escaneo correctamente"; 
      fondo = AppColorStyles.verde2;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext buildContext) {
        return Container(
          color: fondo,
          width: double.infinity,
          height: 400,
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  texto,
                  style: AppTitleStyles.tarjeta(color: AppColorStyles.blancoFondo),
                ),
              ),
              if(caso == "valido" || caso == "escaneado")
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "Actividad: ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorStyles.verdeFondo)),
                        TextSpan(
                            text: titulo,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.blancoFondo)),
                      ]),
                    ),
                    SizedBox(height: 10,),
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "QR: ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorStyles.verdeFondo)),
                        TextSpan(
                            text: entrada["qr"],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.blancoFondo)),
                      ]),
                    ),
                    SizedBox(height: 10,),
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "Nombre completo: ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorStyles.verdeFondo)),
                        TextSpan(
                            text: entrada["nombres"]+" "+entrada["apellidos"],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.blancoFondo)),
                      ]),
                    ),
                    SizedBox(height: 10,),
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "Carnet: ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorStyles.verdeFondo)),
                        TextSpan(
                            text: entrada["cedulaDeIdentidad"],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.blancoFondo)),
                      ]),
                    ),
                    SizedBox(height: 10,),
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "Correo: ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorStyles.verdeFondo)),
                        TextSpan(
                            text: entrada["email"],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorStyles.blancoFondo)),
                      ]),
                    ),
                  ],
                )
              )
            ],
          )
        );
      }
    );
  }
  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () {
          if(_idSeleccionado != -1 && _tipoSeleccionado.isNotEmpty){
            _error = "";
            _escanearEntrada();
          }else{
            _error = "Actividad no seleccionada.";
          }
          setState(() {});
        },
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Escanear entrada',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blancoFondo), // Estilo del texto del botón
        ),
      ),
    );
  }
  
  Widget _crearSelectorActividades(){
    List<ValueItem> opciones = [];
    for (var item in _actividades) {
      opciones.add(
        ValueItem(
          label: item["titulo"],
          value: '${item['id']};${item['tipo']}',
        )
      );
    }
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Seleccioná la actividad para escanear las entradas",
            style: TextStyle(
              color: AppColorStyles.gris1,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorationStyle.campoContainerForm(),
            child: MultiSelectDropDown(
              onOptionSelected: (selectedOptions) {
                if (selectedOptions.isNotEmpty) {
                  List<String> partes = selectedOptions[0].value!.split(';');
                  if (partes.length >= 2) {
                    _idSeleccionado = int.parse(partes[0]);
                    _tipoSeleccionado = partes[1];
                  }
                  setState(() {});
                } else {
                  setState(() {
                    _idSeleccionado = -1;
                    _tipoSeleccionado = "";
                  });
                }
              },
              options: opciones,
              hint: "- Seleccionar -",
              selectionType: SelectionType.single,
              chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: AppColorStyles.verde2),
              selectedOptionIcon: const Icon(Icons.check_circle, color: AppColorStyles.verde2),
              selectedOptionTextColor: AppColorStyles.oscuro1,
              selectedOptionBackgroundColor: AppColorStyles.verdeFondo,
              optionTextStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
              borderRadius: 14,
              borderColor: AppColorStyles.blancoFondo,
            ),
          ),
          if (_error.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              _error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
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