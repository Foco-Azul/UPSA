// ignore_for_file: avoid_print

import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late ThemeData theme;
  late ProfileController controller;
  List<Map<String,dynamic>> _contenido = [];
  String _backUrl = "";
  User _user = User();
  bool _isLoggedIn = false;
  
  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    controller = ProfileController();
    cargarDatos();
  }

  void cargarDatos() async{
    setState(() {
      controller.uiLoading = true;
    });
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _contenido = await ApiService().getContenido();
    _isLoggedIn = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    if (_isLoggedIn) {
      _user = Provider.of<AppNotifier>(context, listen: false).user;
      if(_user.rolCustom! == "estudiante"){
        _filtrarNoticias(_user.id!);
      }
    }else{
      _filtrarNoticias(-1);
    }
    setState(() {
      controller.uiLoading = false;
    });
  }
  void _filtrarNoticias(int id){
    List<Map<String,dynamic>> aux = [];
    for (var item in _contenido) {
      if(item["tipo"] == "Noticias"){
        if(item["usuariosPermitidos"].isNotEmpty){
            for (var item2 in item["usuariosPermitidos"]) {
              if(item2 == id){
                aux.add(item);
              }
            }
        }else{
          aux.add(item);
        }
      }else{
        aux.add(item);
      }
    }
    _contenido = aux;
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
        backgroundColor: AppColorStyles.altFondo1,
        body: ListView(
          children: [
            _crearListaTarjetas(), 
          ],
        )
      );
    }
  }

  Widget _crearListaTarjetas() {
    List<Widget> tarjetas = _contenido.map((item) => _crearTarjeta(item)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // Para que el Column se ajuste al tamaño de su contenido
      children: tarjetas,
    );
  }
  Widget _navegacion(String tipo, String categoria) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alinea los elementos del Row al centro
        children: [
          MyText(
            tipo.toUpperCase(),
            style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
          ),
          Icon(LucideIcons.dot, color: AppColorStyles.altTexto1),
          MyText(
            categoria.toUpperCase(),
            style: AppTextStyles.etiqueta(color: AppColorStyles.altTexto1)
          ),
        ],
      ),
    );
  }
  Widget _crearTarjeta(Map<String,dynamic> item) {
    return GestureDetector(
      onTap: () {
        if(item['tipo'] == "Eventos"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: item['id'],)));
        }
        if(item['tipo'] == "Concursos"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: item['id'],)));
        }        
        if(item['tipo'] == "Clubes"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: item['id'],)));
        }        
        if(item['tipo'] == "Noticias"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: item['id'],)));
        }
      },
      child: Container(
        margin: EdgeInsets.all(15), // Añadir margen superior si es necesario
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColorStyles.blanco, // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            AppSombra.tarjeta(),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5), // Bordes redondeados para la imagen
              child: SizedBox(
                width: double.infinity, // La imagen ocupará todo el ancho del contenedor
                height: 200,
                child: Image.network(
                  _backUrl+item['imagen'], // Reemplaza con la URL de tu imagen
                  fit: BoxFit.cover, // Asegúrate de que la imagen cubra todo el espacio disponible
                ),
              ),
            ),
            SizedBox(height: 15),
            _navegacion(item['tipo'], item['categoria']),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item['titulo'],
                style: AppTitleStyles.tarjeta()
              ),
            ),
            Text(
              item['descripcion'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.parrafo()
            ),
          ],
        ),
      ),
    );
  }
}
