import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/concurso.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
// Define la extensión para String
extension StringCasingExtension on String {
  String capitalize() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({Key? key}) : super(key: key);

  @override
  _CalendarioScreenState createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  late ThemeData theme;
  final Map<DateTime, Color> _highlightedDays = {
    DateTime.utc(2024, 5, 1): Colors.red,
    DateTime.utc(2024, 5, 5): Colors.green,
    DateTime.utc(2024, 5, 26): Colors.blue,
  };
  List<Map<String, dynamic>> _actividades = [];
  DateTime _focusedDay = DateTime.now();
  late ProfileController controller;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    controller = ProfileController();
    _cargarDatos();
  }
  void _cargarDatos() async{
    _actividades = await ApiService().getActividades();
    controller.uiLoading = false;
    setState(() {});
  }
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    }); 
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
          title: Text(
            'Calendario de actividades',
            style: TextStyle(
              fontSize: 18, // Tamaño del texto
              fontWeight: FontWeight.w600, // Peso del texto
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              _contruirCalendario(),
              _construirActividadesMes(),
            ],
          ),
        ),
      );
    }
  }
  Widget _construirActividadesMes() {
    // Filtra las actividades para el mes actual
    List<Map<String, dynamic>> actividadesFiltradas = _actividades.where((actividad) {
      return DateTime.parse(actividad["fecha"]).month == _focusedDay.month;
    }).toList();

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: actividadesFiltradas.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(8.0), // Margen de 8 en todos los lados
            child: GestureDetector(
              onTap: () {
                switch (_actividades[index]["tipo"]) {
                case "Evento":
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(idEvento: _actividades[index]["id"],)));
                  break;
                case "Concurso":
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(idConcurso: _actividades[index]['id'],)));
                  break;
                default:
                  print('Otro tipo de actividad pulsada');
              }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: actividadesFiltradas[index]["color"],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        (DateTime.parse(actividadesFiltradas[index]["fecha"]).day).toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0), // Espacio entre el número y el contenido
                  // Título y contenido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actividadesFiltradas[index]["titulo"],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              actividadesFiltradas[index]["tipo"],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8.0), // Espacio entre el texto y el icono
                            Container(
                              width: 6, // Tamaño del círculo
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey, // Color del círculo
                              ),
                            ),
                            SizedBox(width: 8.0), // Espacio entre el icono y el segundo texto
                            Text(
                              actividadesFiltradas[index]["categoria"],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _contruirCalendario(){
    return Container(
      margin: EdgeInsets.only(right: 32, left: 32), // Padding del container
      decoration: BoxDecoration(
        color: Color.fromRGBO(252, 252, 252, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color.fromRGBO(246, 246, 246, 1),
          width: 3,
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2014, 01, 01),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        locale: 'es_ES',
        startingDayOfWeek: StartingDayOfWeek.monday, // Comienza la semana en lunes
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month', // Solo muestra el formato mensual
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false, // Oculta el botón de formato
          titleCentered: true, // Centra el título del mes
          titleTextFormatter: (date, locale) =>DateFormat.yMMMM(locale).format(date).capitalize(), // Capitaliza el mes
        ),
        daysOfWeekHeight: 40.0, // Ajusta la altura de los nombres de los días
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date).capitalize(), // Capitaliza los días
        ),
        calendarStyle: CalendarStyle(
          cellMargin: EdgeInsets.symmetric(vertical: 8.0), // Aumenta el espacio entre los días y el calendario
        ),
        onPageChanged: _onPageChanged,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            List<Widget> eventosDelDia = [];
            for (var evento in _actividades) {
              DateTime fechaEvento = DateTime.parse(evento["fecha"]);
              if (fechaEvento.year == day.year &&
                  fechaEvento.month == day.month &&
                  fechaEvento.day == day.day) {
                eventosDelDia.add(
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      color: evento["color"],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
            }
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(color: Colors.black),
                  ),
                  if (eventosDelDia.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: eventosDelDia,
                    ),
                ],
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            List<Widget> eventosDelDia = [];
            for (var evento in _actividades) {
              DateTime fechaEvento = DateTime.parse(evento["fecha"]);
              if (fechaEvento.year == day.year &&
                  fechaEvento.month == day.month &&
                  fechaEvento.day == day.day) {
                eventosDelDia.add(
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      color: evento["color"],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
            }
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(color: Colors.black),
                  ),
                  if (eventosDelDia.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: eventosDelDia,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );             
  }
}
