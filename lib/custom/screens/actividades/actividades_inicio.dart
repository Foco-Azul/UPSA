import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/evento.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
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
  List<Categoria> _categorias = [];
  late ProfileController controller;
  int _selectedChoiceIndex = -1;
  List<Evento> _eventos =  [];
  String _backUrl = "";
  bool _cargando = false;
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarCategorias();
  }
  void _cargarCategorias() async{
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    List<Categoria> categoriasActual = await ApiService().getCategorias();
    _eventos = await ApiService().getEventos();
    setState(() {
      _categorias = categoriasActual;
      controller.uiLoading = false;
    });
  }  
  void _cargarEventosCategoria() async{
    setState(() {
      _cargando = true;
    });
    if(_selectedChoiceIndex == -1){
      _eventos = await ApiService().getEventos();
    }else{
      _eventos = await ApiService().getEventosPorIds(_categorias[_selectedChoiceIndex].idsContenido!);
    }
    setState(() {
      _cargando = false;
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
      body: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /*-------------- Build Tabs here ------------------*/
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(child: MyText.titleMedium("Eventos", fontWeight: 600, fontSize: 14,)),
                    Tab(child: MyText.titleMedium("Clubes", fontWeight: 600, fontSize: 14,)),
                    Tab(child: MyText.titleMedium("Concursos", fontWeight: 600, fontSize: 14,)),
                    Tab(child: MyText.titleMedium("Quiz", fontWeight: 600, fontSize: 14,)),
                  ],
                  tabAlignment: TabAlignment.start,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: Color.fromRGBO(32, 104, 14, 1), width: 2.0),
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

Widget getTabContent(String text) {
  if(text != "Eventos"){
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: MyText.titleMedium(text, fontWeight: 600),
      ),
    );
  }else{
    return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                child: Column(
                  children: <Widget>[
                      Container(
                      padding: MySpacing.only(top: 12, bottom: 12),
                      child: Wrap(
                        children: _buildChoiceList(),
                      ),
                    )
                  ]
                )
              ),
            ],
          ),
        ),
        _cargando
        ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(32, 104, 14, 1)),
          ),
        )
          // Muestra el indicador de carga si `_cargando` es true
        : generarContenido(_eventos), // Muestra el contenido generado si `_cargando` es false
      ],
    ),
  );
  }
}
  Widget generarContenido(List<Evento> data) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Acción al hacer clic en el elemento
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(idEvento: int.parse(data[index].id!,))));
              },
              child: Row(
                children: [
                  // Imagen a la izquierda
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Image.network(_backUrl+data[index].fotoPrincipal!),
                  ),
                  // Espaciador
                  SizedBox(width: 16),
                  // Columna con el texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyLarge(data[index].titulo!, fontSize: 14, fontWeight: 600,),
                        SizedBox(height: 8), // Espacio de 8 de alto entre los textos
                        Text(
                          data[index].cuerpo!.replaceAll('\n', ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
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
  _buildChoiceList() {
    List<Widget> choices = [];
    for (int index = 0; index < _categorias.length; index++) {
      var item = _categorias[index];
      choices.add(Container(
        padding: MySpacing.all(8),
        child: ChoiceChip(
          checkmarkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selectedColor: Color.fromRGBO(32, 104, 14, 1),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText.bodyMedium(item.nombre!,
                fontSize: 8,
                color: _selectedChoiceIndex == index
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onBackground),
            ],
          ),
          selected: _selectedChoiceIndex == index, // Verifica si este chip está seleccionado
          onSelected: (selected) {
            setState(() {
              if (_selectedChoiceIndex != index) {
                _selectedChoiceIndex = selected ? index : -1; // Actualiza el índice seleccionado solo si es diferente
                _cargarEventosCategoria();
              } else {
                _selectedChoiceIndex = -1; // Deselecciona si se pulsa el mismo item
                _cargarEventosCategoria();
              }
            });
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color.fromRGBO(32, 104, 14, 1), // Color del borde
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
