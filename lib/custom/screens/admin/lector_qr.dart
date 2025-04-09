
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/funciones.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/custom/widgets/animacion_carga.dart';
import 'package:flutkit/custom/widgets/mensaje_temporal_inferior.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

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
  int selectedValue = 0;
  List<Map<String, dynamic>> _actividades = [];
  String _tipoSeleccionado = "";
  int _idSeleccionado = -1;
  String _error = "";
  late AnimacionCarga _animacionCarga;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    controller = ProfileController();
    _animacionCarga = AnimacionCarga(context: context);
    _cargarDatos();
  }
  void _cargarDatos() async{
    _actividades = await ApiService().getActividadesConInscripciones();
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _verificarQR(String codigo) async{
    _actividades = await ApiService().getActividadesConInscripciones();
    Navigator.of(context).pop();
    bool bandera = false;
    for (var actividad in _actividades) {
      if(_tipoSeleccionado == actividad["tipo"] && _idSeleccionado == actividad["id"] || true){
        for (var entrada in actividad["entradas"]) {
          if(entrada["qr"] == codigo){
            bandera = true;
            Map<String,dynamic> aux = await ApiService().pedirInscripcionPorId(entrada['id']);
            entrada["asistencia"] = aux["asistencia"];
            entrada["entradasEscaneadas"] = aux["entradasEscaneadas"];
            if (!entrada["asistencia"] && actividad["cantidadEscaneosMaximo"] > entrada["entradasEscaneadas"].length) {
              _datosDeLaEntrada("valido", actividad["titulo"], entrada, actividad["cantidadEscaneosMaximo"]);
            }else{
              _datosDeLaEntrada("escaneado", actividad["titulo"], entrada, actividad["cantidadEscaneosMaximo"]);
            }
          }
        }
      }
    }
    if(!bandera){
      _datosDeLaEntrada("noValido", codigo, {}, -1);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (controller.uiLoading) {
      return Scaffold(
        body: Container(
          margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
          child: LoadingEffect.getCouponLoadingScreen(
            context,
          ),
        ),
      );
    } else {
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
          centerTitle: true,
          title: MyText(
            "Escaner de entradas",
            style: AppTitleStyles.principal()
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.replay_outlined, size: 30),
              onPressed: () async{
                _animacionCarga.setMostrar(true);
                _actividades = await ApiService().getActividadesConInscripciones();
                MensajeTemporalInferior().mostrarMensaje(context,"Entradas actualizadas con éxito.", "exito");
                _animacionCarga.setMostrar(false);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //_crearSelectorActividades(),
              _crearBoton(),
            ],
          ),
        ),
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blanco,
          selectedIndex: 4,
          animationDuration: Duration(milliseconds: 500),
          showElevation: true,
          items: [
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.home_sharp),
              title: Text(
                'Inicio',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.emoji_events_sharp),
              title: Text(
                'Actividades',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.local_library_sharp),
              title: Text(
                'Campus',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
              icon: Icon(Icons.push_pin_sharp),
              title: Text(
                'Noticias',
                style: AppTextStyles.bottomMenu()
              ),
            ),
            FlashyTabBarItem(
              inactiveColor: AppColorStyles.altTexto1,
              activeColor: AppColorStyles.altTexto1,
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

  // Función que muestra el escáner dentro de un modal
  void _showScannerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8, // Ajusta la altura según necesites
          child: Column(
            children: [
              Expanded(
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.noDuplicates,
                    returnImage: true,
                  ),
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      String codigo = barcode.rawValue ?? "";
                      _verificarQR(codigo);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _datosDeLaEntrada(String caso, String titulo, Map<String, dynamic> entrada, int escaneosMaximos) {
    String texto = "";
    String texto2 = "";
    String texto3 = "";
    Color fondo = AppColorStyles.altFondo1;
    if (caso == "noValido") {
      texto = "Error, este QR no es valido";
      texto2 = 'Contenido de QR: $titulo';
      fondo = Colors.red;
    }
    if (caso == "escaneado") {
      texto = "Error, este QR ya fue escaneado";
      texto2 = 'Último registro: ${entrada['entradasEscaneadas'].isNotEmpty ? DateFormat('dd/MM/yyyy-HH:mm:ss').format((entrada['entradasEscaneadas'][0]).subtract(Duration(hours: 4))) : "N/A"}';
      texto3 = 'Veces registradas: ${entrada['entradasEscaneadas'].length} / $escaneosMaximos';
      fondo = Colors.red;
    }
    if (caso == "valido") {
      texto = "QR válido, registra la asistencia para continuar";
      texto2 = 'Último registro: ${entrada['entradasEscaneadas'].isNotEmpty ? DateFormat('dd/MM/yyyy-HH:mm:ss').format((entrada['entradasEscaneadas'][0]).subtract(Duration(hours: 4))) : "N/A"}';
      texto3 = 'Veces registradas: ${entrada['entradasEscaneadas'].length} / $escaneosMaximos';
      fondo = AppColorStyles.altTexto1;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
              color: fondo,
              width: double.infinity,
              //height: 450,
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      texto,
                      style: AppTitleStyles.tarjeta(color: AppColorStyles.blanco),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0),
                    child: Text(
                      texto2,
                      style: AppTitleStyles.tarjeta(color: AppColorStyles.blanco),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Text(
                      texto3,
                      style: AppTitleStyles.tarjeta(color: AppColorStyles.blanco),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (caso == "valido" || caso == "escaneado")
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          children: [
                            _buildInfoText("Actividad: ", titulo),
                            _buildInfoText("QR: ", entrada["qr"]),
                            _buildInfoText("Nombre completo: ",
                                "${entrada["nombres"]} ${entrada["apellidos"]}"),
                            _buildInfoText("Carnet: ", entrada["cedulaDeIdentidad"]),
                            _buildInfoText("Correo: ", entrada["email"]),
                          ],
                        )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorStyles.gris2,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text("Cancelar",
                            style: TextStyle(color: AppColorStyles.altTexto1, fontSize: 16)),
                      ),
                      if(caso == "valido")
                      ElevatedButton(
                        onPressed: () async{
                          entrada['asistencia'] = (escaneosMaximos - entrada['entradasEscaneadas'].length) == 1;
                          entrada['entradasEscaneadas'].add(DateTime.now());
                          List<String> fechas = FuncionUpsa.armarListaFechasHorasParaStrapi(entrada['entradasEscaneadas']);
                          await ApiService().marcarAsistencia(entrada, fechas);
                          Navigator.pop(context);
                          MensajeTemporalInferior().mostrarMensaje(context,"Registro exitoso.", "exito");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorStyles.verde2,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text("Registrar",
                            style: TextStyle(color: AppColorStyles.blanco, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ));
        });
  }

  Widget _buildInfoText(String label, String value) {
    return Column(
      children: [
        RichText(
          text: TextSpan(children: <TextSpan>[
            TextSpan(
                text: label,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColorStyles.altFondo1)),
            TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColorStyles.blanco)),
          ]),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _crearBoton(){
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () {
          if(_idSeleccionado != -1 && _tipoSeleccionado.isNotEmpty || true){
            _error = "";
            _showScannerModal();
          }else{
            _error = "Actividad no seleccionada.";
          }
          setState(() {});
        },
        style: AppDecorationStyle.botonBienvenida(),
        child: Text(
          'Escanear entrada',
          style: AppTextStyles.botonMayor(color: AppColorStyles.blanco), // Estilo del texto del botón
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
                  List<String> partes = selectedOptions[0].value!.toString().split(';');
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
              chipConfig: const ChipConfig(wrapType: WrapType.wrap, backgroundColor: AppColorStyles.altTexto1),
              selectedOptionIcon: const Icon(Icons.check_circle, color: AppColorStyles.altTexto1),
              selectedOptionTextColor: AppColorStyles.oscuro1,
              selectedOptionBackgroundColor: AppColorStyles.altFondo1,
              optionTextStyle: AppTextStyles.parrafo(color: AppColorStyles.altTexto1),
              borderRadius: 14,
              borderColor: AppColorStyles.blanco,
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
}