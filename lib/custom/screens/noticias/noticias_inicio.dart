import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({Key? key}) : super(key: key);

  @override
  _NoticiasScreenState createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  List<Categoria> _categorias = [];
  late ProfileController controller;
  int _selectedChoiceIndex = -1;
  List<Noticia> _noticias =  [];
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
    List<Categoria> categoriasActual = await ApiService().getCategoriasNoticias();
    _noticias = await ApiService().getNoticias();
    setState(() {
      _categorias = categoriasActual;
      controller.uiLoading = false;
    });
  }  
  void _cargarNoticiasCategoria() async{
    setState(() {
      _cargando = true;
    });
    if(_selectedChoiceIndex == -1){
      _noticias = await ApiService().getNoticias();
    }else{
      _noticias = await ApiService().getNoticiasPorIdsCategoria(_categorias[_selectedChoiceIndex].idsContenido!);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Column(
                    children: <Widget>[
                        Container(
                        padding: MySpacing.only(top: 12, bottom: 12),
                        child: Wrap(
                          children: _buildChoiceList(),
                        ),
                      )
                    ]
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
            : generarContenido(_noticias), // Muestra el contenido generado si `_cargando` es false
          ],
        ),
      );
    }
  }
  Widget generarContenido(List<Noticia> data) {
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: data[index].id!,)));
              },
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_backUrl+data[index].foto!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: MediaQuery.of(context).size.width * 0.25, // 60% del ancho de la pantalla
                  ),
                  // Espaciador
                  SizedBox(width: 16),
                  // Columna con el texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyLarge(data[index].titular!, fontSize: 14, fontWeight: 600,),
                        SizedBox(height: 8), // Espacio de 8 de alto entre los textos
                        Text(
                          data[index].descripcion!.replaceAll('\n', ''),
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
                _cargarNoticiasCategoria();
              } else {
                _selectedChoiceIndex = -1; // Deselecciona si se pulsa el mismo item
                _cargarNoticiasCategoria();
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
