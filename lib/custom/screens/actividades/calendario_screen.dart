import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    setState(() {
      controller.uiLoading = false;
    });
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
          title: Text(
            "Calendario de Actividades",
            style: AppTitleStyles.principal()
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
        bottomNavigationBar: FlashyTabBar(
          iconSize: 24,
          backgroundColor: AppColorStyles.blancoFondo,
          selectedIndex: 1,
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
  Widget _construirActividadesMes() {
    // Filtra las actividades para el mes actual
    List<Map<String, dynamic>> actividadesFiltradas = _actividades.where((actividad) {
      return DateTime.parse(actividad["fecha"]).month == _focusedDay.month;
    }).toList();

    return Expanded(
      child: ListView.builder(
        itemCount: actividadesFiltradas.length,
        itemBuilder: (context, index) {
          Categoria categoria = actividadesFiltradas[index]["categoria"];
          return Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(15),
            decoration: AppDecorationStyle.tarjeta(),
            child: GestureDetector(
              onTap: () {
                if(_actividades[index]["tipo"] == "Evento"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: _actividades[index]["id"],)));
                }
                if(_actividades[index]["tipo"] == "Concurso"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: _actividades[index]['id'],)));
                }
                if(_actividades[index]["tipo"] == "Club"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: _actividades[index]['id'],)));
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    padding: EdgeInsets.all(5), 
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: actividadesFiltradas[index]["color"],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        (DateTime.parse(actividadesFiltradas[index]["fecha"]).day).toString(),
                        style: TextStyle(
                          color: AppColorStyles.blancoFondo,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actividadesFiltradas[index]["titulo"],
                          style: AppTitleStyles.tarjetaMenor()
                        ),
                        Row(
                          children: [
                            Text(
                              actividadesFiltradas[index]["tipo"],
                              style: AppTextStyles.parrafo(color: AppColorStyles.gris2)
                            ),
                            Icon(LucideIcons.dot, color: AppColorStyles.gris2),// Espacio entre el icono y el segundo texto
                            Text(
                              categoria.nombre!,
                              style: AppTextStyles.parrafo(color: AppColorStyles.gris2)
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
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15), 
      decoration: AppDecorationStyle.tarjeta(),
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
                    style: TextStyle(color: AppColorStyles.oscuro1),
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
                border: Border.all(color: AppColorStyles.oscuro1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(color: AppColorStyles.oscuro1),
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
