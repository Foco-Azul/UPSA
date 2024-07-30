
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/categoria.dart';
import 'package:flutkit/custom/screens/actividades/club_screen.dart';
import 'package:flutkit/custom/screens/actividades/concurso_escreen.dart';
import 'package:flutkit/custom/screens/actividades/evento_escreen.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
import 'package:flutkit/custom/theme/styles.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EtiquetasScreen extends StatefulWidget {
  const EtiquetasScreen({Key? key, this.etiqueta = ""}) : super(key: key);
  final String etiqueta;
  @override
  _EtiquetasScreenState createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  String _etiqueta = "";
  late ThemeData theme;
  late ProfileController controller;
  List<Map<String,dynamic>> _contenidos = [];
  @override
  void initState() {
    super.initState();
    _etiqueta = widget.etiqueta;
    theme = AppTheme.theme;
    controller = ProfileController();
    cargarDatos();
  }

  void cargarDatos() async{
    setState(() {
      controller.uiLoading = true;
    });
    _contenidos = await ApiService().getContenidosPorEtiquetas(_etiqueta);
    setState(() {
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
        backgroundColor: AppColorStyles.verdeFondo,
        appBar: AppBar(
          backgroundColor: AppColorStyles.verdeFondo,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
          '#$_etiqueta',
            style: AppTitleStyles.principal()
          ),
        ),
        body: ListView(
          children: [
            _crearListaTarjetas(), 
          ],
        )
      );
    }
  }
  Widget _crearListaTarjetas() {
    List<Widget> tarjetas = _contenidos.map((item) => _crearTarjeta(item)).toList();
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
            style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
          ),
          Icon(LucideIcons.dot, color: AppColorStyles.verde1),
          MyText(
            categoria.toUpperCase(),
            style: AppTextStyles.etiqueta(color: AppColorStyles.verde1)
          ),
        ],
      ), 
    );
  }
  Widget _crearTarjeta(Map<String, dynamic> item) {
    Categoria categoria = item["categoria"];
    return GestureDetector(
      onTap: () {
        if(item["tipo"] == "eventos"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventoScreen(id: item['id'],)));
        }
        if(item["tipo"] == "concursos"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConcursoScreen(id: item['id'],)));
        }
        if(item["tipo"] == "clubes"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClubScreen(id: item['id'],)));
        }
        if(item["tipo"] == "noticias"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: item['id'],)));
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
            _navegacion(item["tipo"]!, categoria.nombre!),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item["titulo"]!,
                style: AppTitleStyles.tarjeta()
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item["descripcion"]!,
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
}
