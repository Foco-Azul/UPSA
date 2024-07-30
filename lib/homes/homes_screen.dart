import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutkit/custom/models/resultado.dart';
import 'package:flutkit/custom/screens/actividades/actividades_inicio.dart';
import 'package:flutkit/custom/screens/actividades/calendario_screen.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/campus/campus_inicio.dart';
import 'package:flutkit/custom/screens/campus/matriculate_screem.dart';
import 'package:flutkit/custom/screens/inicio/inicio_screen.dart';
import 'package:flutkit/custom/screens/inicio/notificaciones_screen.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/screens/noticias/noticias_inicio.dart';
import 'package:flutkit/custom/screens/perfil/perfil_screen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomesScreen extends StatefulWidget {
  final int indice;
  HomesScreen({Key? key, this.indice = 0}) : super(key: key);
  
  @override
  _HomesScreenState createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  List<Widget> bottomBarPages = [
    InicioScreen(),
    ActividadesScreen(),
    CampusScreen(),
    NoticiasScreen(),
    PerfilScreen(),
  ];
  late ThemeData theme;
  late CustomTheme customTheme;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool isDark = false;
  TextDirection textDirection = TextDirection.ltr;
  final TextEditingController _searchController = TextEditingController();
  bool _showPopup = false;
  List<Resultado> _resultados = [];
  bool _buscando =  false;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.indice;
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
            backgroundColor: AppColorStyles.verdeFondo,
            key: _drawerKey,
            appBar: _buildAppBarContent(selectedIndex),
            body: Stack(
              children: [
                bottomBarPages[selectedIndex],
                _crearPopupBusquedas(),
              ],
            ),
            bottomNavigationBar: FlashyTabBar(
              iconSize: 24,
              backgroundColor: AppColorStyles.blancoFondo,
              selectedIndex: selectedIndex,
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
                setState(() {
                  selectedIndex = index;
                  _searchController.clear();
                  _showPopup = false;
                  _buscando = false;
                });
              },
            ),
          ),
        );
      },
    );
  }
  Widget _crearPopupBusquedas(){
    return Visibility(
      visible: _showPopup,
      child: Dialog(
        insetPadding: EdgeInsets.zero, // Ocupa toda la pantalla
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColorStyles.verdeFondo,
          child: ListView(
            children: [
              if (_buscando)
              Container(
                margin: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
                child: LoadingEffect.getSearchLoadingScreen(
                  context,
                ),
              ),
              _crearListaTarjetas(),
              Visibility(
                visible: _resultados.isEmpty,
                child: Container (
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  child: Text (
                    "Sin resultados",
                    style: AppTextStyles.parrafo(color: AppColorStyles.gris2)
                  )
                )
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _crearListaTarjetas() {
    List<Widget> tarjetas = _resultados.map((item) => _crearTarjeta(item)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
      children: tarjetas,
    );
  }
  Widget _navegacion(String tipo) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alinea los elementos del Row al centro
        children: [
          MyText(
            tipo.toUpperCase(),
            style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
          ),
        ],
      ),
    );
  }
  Widget _crearTarjeta(Resultado item) {
    return GestureDetector(
      onTap: () {
        if(item.tipo == "evento"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: item.idContenido!,)));
        }
        if(item.tipo == "concurso"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: item.idContenido!,)));
        }        
        if(item.tipo == "club"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: item.idContenido!,)));
        }        
        if(item.tipo == "noticia"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: item.idContenido!,)));
        }
        if(item.tipo == "matriculate"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => MatriculateScreen()));
        }
      },
      child: Container(
        margin: EdgeInsets.all(15), // Añadir margen superior si es necesario
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColorStyles.blancoFondo, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          children: [
            _navegacion(item.palabrasClaves!),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item.titulo!,
                style: AppTitleStyles.tarjeta()
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item.descripcion!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.parrafo(),
              ),
            )
          ],
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBarContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          actions: [
            Expanded(
              child: Container (
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: AppDecorationStyle.tarjeta(borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.search, size: 30, color: AppColorStyles.gris2),
                    SizedBox(width: 15,),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar',
                          border: InputBorder.none,
                          labelStyle: AppTitleStyles.subtitulo(color: AppColorStyles.gris2),
                        ),
                        onChanged: (query) async {
                          if(query.length > 2){
                            setState(() {
                              _buscando = true;
                            });
                            _resultados = await ApiService().getBusquedas(query);
                            setState(() {
                              _showPopup = true; // Alterna la visibilidad del popup
                              _buscando = false;
                            });
                          }
                        },
                      ),
                    ),
                    if (_showPopup)
                    IconButton(
                      icon: Icon(Icons.close, size: 30, color: AppColorStyles.gris2),
                      onPressed: () {
                        setState(() {
                          _showPopup = false;
                          _searchController.clear(); // Limpia el campo de búsqueda
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.today, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarioScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_none_outlined, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificacionesScreen()),
                );
              },
            ),
          ],
        );
      case 1:
        return AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          title: Text('Actividades', style: AppTitleStyles.principal()),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.today, size: 30),
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => CalendarioScreen()),);
              },
            ),
          ],
        );
      case 2:
        return AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          title: Text('Campus', style: AppTitleStyles.principal()),
          centerTitle: true,
        );
      case 3:
        return AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          title: Text('Noticias', style: AppTitleStyles.principal()),
          centerTitle: true,
        );
      case 4:
        return AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          title: Text('Mi perfil', style: AppTitleStyles.principal()),
          centerTitle: true,
        );
      default:
        return AppBar(
          title: Text('', style: AppTitleStyles.principal()),
          // Otros elementos de la AppBar por defecto
        );
    }
  }
}
