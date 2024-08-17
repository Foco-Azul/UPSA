import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({Key? key}) : super(key: key);

  @override
  _NoticiasScreenState createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  User _user = User();
  bool _isLoggedIn = false;
  List<Noticia> _noticias = [];
  List<Noticia> _noticiasCategorizados = [];
  List<Categoria> _noticiasCategorias = [];

  String _backUrl = "";
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
  
    _noticias = await ApiService().getNoticias();
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      if(_user.rolCustom! == "estudiante"){
        _filtrarNoticias(_user.id!);
      }
    }else{
      _filtrarNoticias(-1);
    }
    _noticiasCategorizados = _noticias;
    _noticiasCategorias = _crearCategoriasContenido("Noticias");

    setState(() {
      controller.uiLoading = false;
    });
  }
  void _filtrarNoticias(int id){
    List<Noticia> aux = [];
    for (var item in _noticias) {
      if(item.usuariosPermitidos!.isNotEmpty){
        for (var item2 in item.usuariosPermitidos!) {
          if(item2 == id){
            aux.add(item);
          }
        }
      }else{
        aux.add(item);
      }
    }
    _noticias = aux;
  }  
  List<Categoria> _crearCategoriasContenido(String contenido) {
    List<Categoria> res = [];
    if (contenido == "Noticias") {
      for (var item in _noticias) {
        Categoria aux = item.categoria!;
        if (!res.any((element) => element.nombre == aux.nombre!)) {
          res.add(aux);
        }
      }
    }
    return res;
  }
  void _filtarPorCategoria(String contenido, String categoria){
    if(contenido == "Noticias"){
      if(categoria.isNotEmpty){
        _noticiasCategorizados = [];
        for (var item in _noticias) {
          Categoria aux = item.categoria!;
          if(aux.nombre == categoria){
            _noticiasCategorizados.add(item);
          }
        }
      }else{
        _noticiasCategorizados = _noticias;
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
        body: getTabContent('Noticias'),
      );
    }
  }
  Widget getTabContent(String contenido) {
    List<Categoria> categorias = [];
    List<dynamic> contenidos = [];
    if(contenido == "Noticias"){
      categorias = _noticiasCategorias;
      contenidos = _noticiasCategorizados;
    }
    return Scaffold(
          backgroundColor: AppColorStyles.verdeFondo,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _crearCategorias(contenido, categorias),
                ),
              ),
              generarContenidoApp(contenido, contenidos), // Muestra el contenido generado si `_cargando` es false
            ],
          ),
        );
  }
  Widget generarContenidoApp(String contenido, List<dynamic> contenidos) {
    if(contenidos.isNotEmpty){
      return Expanded(
        child: ListView.builder(
          itemCount: contenidos.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if(contenido == "Noticias"){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: contenidos[index].id!,)));
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
                        child: Image.network(_backUrl + contenidos[index].imagen!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contenidos[index].titulo!, 
                            style: AppTitleStyles.tarjetaMenor()
                          ),
                          Text(
                            contenidos[index].descripcion!.replaceAll('\n', ''),
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
          "En este momento no contamos con ninguna noticia",
          style: AppTextStyles.menor(color: AppColorStyles.gris1),
        ),
      );
    }  
  }
  _crearCategorias(String contenido, List<Categoria> categorias) {
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
            if(contenido == "Noticias"){
              if(_noticiasCategorias[index].activo! == false) {
                _noticiasCategorias[index].activo = true;
                for (var i = 0; i < _noticiasCategorias.length; i++) {
                  if (i != index) {
                    _noticiasCategorias[i].activo = false;
                  }
                }
                _filtarPorCategoria(contenido, item.nombre!);
              } else {
                _noticiasCategorias[index].activo = false;
                _filtarPorCategoria(contenido, "");
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
  Widget generarContenido(List<Noticia> data) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColorStyles.blancoFondo,
              borderRadius: BorderRadius.circular(5), 
              boxShadow: [
                AppSombra.categoria(),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                // Acción al hacer clic en el elemento
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: data[index].id!,)));
              },
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5), // Radio del borde
                      child: Image.network(_backUrl + data[index].imagen!, fit: BoxFit.cover),
                    ),
                  ),
                  // Espaciador
                  SizedBox(width: 16),
                  // Columna con el texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index].titulo!, style: AppTitleStyles.subtitulo(color: AppColorStyles.oscuro1)),
                        Text(
                          data[index].descripcion!.replaceAll('\n', ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.parrafo()
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
}
