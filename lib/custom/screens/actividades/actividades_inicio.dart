import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({Key? key}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class Item {
  final int id;
  final String imageUrl;
  final String title;
  final String description1;
  final String description2;

  Item({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description1,
    required this.description2,
  });
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  List<Categoria> _categorias = [];
  late ProfileController controller;
  List<Item> _data = [
    Item(
      id: 1,
      imageUrl: 'https://upsa.focoazul.com/uploads/Captura_de_pantalla_2023_09_19_213839_84c8b91a78.png',
      title: 'Title 1',
      description1: 'Description 1',
      description2: 'Description 2',
    ),
    Item(
      id: 1,
      imageUrl: 'https://upsa.focoazul.com/uploads/Captura_de_pantalla_2023_09_19_213839_84c8b91a78.png',
      title: 'Title 2',
      description1: 'Description 3',
      description2: 'Description 4',
    ),
    // Agrega más elementos según sea necesario
  ];
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarCategorias();
  }
  void _cargarCategorias() async{
     List<Categoria> _categoriasActual = await ApiService().getCategorias();
    setState(() {
      _categorias = _categoriasActual;
      controller.uiLoading = false;
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
                    Tab(child: MyText.titleMedium("Eventos", fontWeight: 600)),
                    Tab(child: MyText.titleMedium("Clubes", fontWeight: 600)),
                    Tab(child: MyText.titleMedium("Concursos", fontWeight: 600)),
                    Tab(child: MyText.titleMedium("Quiz", fontWeight: 600)),
                  ],
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
              generarBotones(text),
            ],
          ),
        ),
        generarContenido(_data),
      ],
    ),
  );
  }
}
  Widget generarContenido(List<Item> data) {
    return Expanded(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Acción al hacer clic en el elemento
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(idEvento: data[index].id,)));
              },
              child: Row(
                children: [
                  // Imagen a la izquierda
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Image.network(data[index].imageUrl),
                  ),
                  // Espaciador
                  SizedBox(width: 16),
                  // Columna con el texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index].title),
                        Text(data[index].description1),
                        Text(data[index].description2),
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

  Widget generarBotones(String actividad) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _categorias.length,
          (index) => Container(
            margin: EdgeInsets.all(8.0),
            child: MyButton.small(
              onPressed: () {},
              elevation: 0,
              splashColor: theme.colorScheme.onPrimary.withAlpha(60),
              backgroundColor: theme.primaryColor,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.dribbble,
                    color: theme.colorScheme.onPrimary,
                  ),
                  SizedBox(width: 8), // Espacio entre el ícono y el texto
                  MyText.bodyMedium(
                    _categorias[index].nombre!,
                    color: theme.colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
