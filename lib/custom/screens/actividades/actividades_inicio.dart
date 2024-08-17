import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/club.dart';
import 'package:flutkit/custom/models/concurso.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({Key? key}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  String _backUrl = "";

  List<Evento> _eventos =  [];
  List<Evento> _eventosCategorizados = [];
  List<Categoria> _eventosCategorias = [];

  List<Club> _clubes = [];
  List<Club> _clubesCategorizados = [];
  List<Categoria> _clubesCategorias = [];

  List<Concurso> _concursos =  [];
  List<Concurso> _concursosCategorizados = [];
  List<Categoria> _concursosCategorias = [];
  
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
  }
  
  void _cargarDatos() async{
    setState(() {
      controller.uiLoading = true;
    });

    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');

    _clubes = await ApiService().getClubes();
    _clubesCategorizados = _clubes;
    _clubesCategorias = _crearCategoriasActividad("Clubes");

    _eventos = await ApiService().getEventos();
    _eventosCategorizados = _eventos;
    _eventosCategorias = _crearCategoriasActividad("Eventos");

    _concursos = await ApiService().getConcursos();
    _concursosCategorizados = _concursos;
    _concursosCategorias = _crearCategoriasActividad("Concursos");
    
    setState(() {
      controller.uiLoading = false;
    });
  }
  List<Categoria> _crearCategoriasActividad(String actividad) {
    List<Categoria> res = [];
    if (actividad == "Eventos") {
      for (var item in _eventos) {
        Categoria aux = item.categoria!;
        if (!res.any((element) => element.nombre == aux.nombre!)) {
          res.add(aux);
        }
      }
    }
    if (actividad == "Clubes") {
      for (var item in _clubes) {
        Categoria aux = item.categoria!;
        if (!res.any((element) => element.nombre == aux.nombre!)) {
          res.add(aux);
        }
      }
    }
    if (actividad == "Concursos") {
      for (var item in _concursos) {
        Categoria aux = item.categoria!;
        if (!res.any((element) => element.nombre == aux.nombre!)) {
          res.add(aux);
        }
      }
    }
    return res;
  }
  void _filtarPorCategoria(String actividad, String categoria){
    if(actividad == "Eventos"){
      if(categoria.isNotEmpty){
        _eventosCategorizados = [];
        for (var item in _eventos) {
          Categoria aux = item.categoria!;
          if(aux.nombre == categoria){
            _eventosCategorizados.add(item);
          }
        }
      }else{
        _eventosCategorizados = _eventos;
      }
    }
    if(actividad == "Clubes"){
      if(categoria.isNotEmpty){
        _clubesCategorizados = [];
        for (var item in _clubes) {
          Categoria aux = item.categoria!;
          if(aux.nombre == categoria){
            _clubesCategorizados.add(item);
          }
        }
      }else{
        _clubesCategorizados = _clubes;
      }
    }
    if(actividad == "Concursos"){
      if(categoria.isNotEmpty){
        _concursosCategorizados = [];
        for (var item in _concursos) {
          Categoria aux = item.categoria!;
          if(aux.nombre == categoria){
            _concursosCategorizados.add(item);
          }
        }
      }else{
        _concursosCategorizados = _concursos;
      }
    }
    setState(() {});
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
      body: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColorStyles.verdeFondo,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  isScrollable: true,
                   tabs: [
                    Tab(
                      child: Text(
                        "Eventos",
                        style: AppTextStyles.botonMayor(color: AppColorStyles.verde1)
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Clubes",
                        style: AppTextStyles.botonMayor(color: AppColorStyles.verde1)
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Concursos",
                        style: AppTextStyles.botonMayor(color: AppColorStyles.verde1)
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Quiz",
                        style: AppTextStyles.botonMayor(color: AppColorStyles.verde1)
                      ),
                    ),
                  ],
                  tabAlignment: TabAlignment.start,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: AppColorStyles.verde1, width: 2.0),
                  ),
                )
              ],
            ),
          ),
          /*--------------- Build Tab body here -------------------*/
          body: TabBarView(
            children: <Widget>[
              getTabContent('Eventos'),
              getTabContent('Clubes'),
              getTabContent('Concursos'),
              getTabContent('Quiz'),
            ],
          ),
        ),
      ),
    );
    }
  }
  
  Widget getTabContent(String actividad) {
    List<Categoria> categorias = [];
    List<dynamic> actividades = [];
    if(actividad == "Eventos"){
      categorias = _eventosCategorias;
      actividades = _eventosCategorizados;
    }
    if(actividad == "Clubes"){
      categorias = _clubesCategorias;
      actividades = _clubesCategorizados;
    }
    if(actividad == "Concursos"){
      categorias = _concursosCategorias;
      actividades = _concursosCategorizados;
    }
    return Scaffold(
          backgroundColor: AppColorStyles.verdeFondo,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _crearCategorias(actividad, categorias),
                ),
              ),
              generarContenidoActividad(actividad, actividades), // Muestra el contenido generado si `_cargando` es false
            ],
          ),
        );
  }
  Widget generarContenidoActividad(String actividad, List<dynamic> actividades) {
    if(actividades.isNotEmpty){
      return Expanded(
        child: ListView.builder(
          itemCount: actividades.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if(actividad == "Eventos"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: actividades[index].id!,)));
                }
                if(actividad == "Clubes"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: actividades[index].id!,)));
                }
                if(actividad == "Concursos"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: actividades[index].id!,)));
                }
              },
              child: Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(15),
                decoration: AppDecorationStyle.tarjeta(),
                child: Row(
                  children: [
                    // Imagen a la izquierda
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5), // Radio del borde
                        child: Image.network(_backUrl + actividades[index].imagen!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actividades[index].titulo!, 
                            style: AppTitleStyles.tarjetaMenor()
                          ),
                          Text(
                            actividades[index].descripcion!.replaceAll('\n', ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.menor(color: AppColorStyles.oscuro2)
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
    }else{
      return Container(
        decoration: AppDecorationStyle.tarjeta(),
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        alignment: Alignment.center,
        child: Text(
          "En este momento no contamos con ninguna actividad",
          style: AppTextStyles.menor(color: AppColorStyles.gris1),
        ),
      );
    }
  }
  _crearCategorias(String actividad, List<Categoria> categorias) {
    List<Widget> choices = [];
    for (int index = 0; index < categorias.length; index++) {
      var item = categorias[index];
      choices.add(Container(
        padding: MySpacing.all(8),
        decoration: BoxDecoration(
          boxShadow: [
            AppSombra.categoria(),
          ],
        ),
        child: ChoiceChip(
          showCheckmark: false,
          avatar: Icon(
            AppIconStyles.icono(nombre: categorias[index].icono!), 
            color: categorias[index].activo! ? AppColorStyles.blancoFondo : AppColorStyles.gris1
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selectedColor: AppColorStyles.verde2, 
          backgroundColor: AppColorStyles.blancoFondo,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(categorias[index].nombre!,
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: FontWeight.bold,
                  color: categorias[index].activo! ? AppColorStyles.blancoFondo : AppColorStyles.gris1
                ),
              )
            ],
          ),
          selected: categorias[index].activo!, // Verifica si este chip está seleccionado
          onSelected: (selected) {
            if(actividad == "Eventos"){
              if(_eventosCategorias[index].activo! == false) {
                _eventosCategorias[index].activo = true;
                for (var i = 0; i < _eventosCategorias.length; i++) {
                  if (i != index) {
                    _eventosCategorias[i].activo = false;
                  }
                }
                _filtarPorCategoria(actividad, item.nombre!);
              } else {
                _eventosCategorias[index].activo = false;
                _filtarPorCategoria(actividad, "");
              }
            }
            if(actividad == "Clubes"){
              if(_clubesCategorias[index].activo! == false) {
                _clubesCategorias[index].activo = true;
                for (var i = 0; i < _clubesCategorias.length; i++) {
                  if (i != index) {
                    _clubesCategorias[i].activo = false;
                  }
                }
                _filtarPorCategoria(actividad, item.nombre!);
              } else {
                _clubesCategorias[index].activo = false;
                _filtarPorCategoria(actividad, "");
              }
            }
            if(actividad == "Concursos"){
              if(_concursosCategorias[index].activo! == false) {
                _concursosCategorias[index].activo = true;
                for (var i = 0; i < _concursosCategorias.length; i++) {
                  if (i != index) {
                    _concursosCategorias[i].activo = false;
                  }
                }
                _filtarPorCategoria(actividad, item.nombre!);
              } else {
                _concursosCategorias[index].activo = false;
                _filtarPorCategoria(actividad, "");
              }
            }
            setState(() {});
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColorStyles.blancoFondo, // Color del borde
              width: 1.0, // Ancho del borde
            ),
            borderRadius: BorderRadius.circular(4), // Radio de borde
          ),
        ),
      ));
    }
    return choices;
  }
}