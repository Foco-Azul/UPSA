import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/screens/noticias/noticia_escreen.dart';
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
      return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
          return ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.only(left: 30.0), // Puedes ajustar el valor según sea necesario
                child: Text(
                  'Feed',
                  style: TextStyle(
                    fontSize: 18.0, // Tamaño de la fuente
                    fontWeight: FontWeight.bold, // Grosor de la fuente
                  ),
                ),
              ),
              crearListaTarjetas(),
            ],
          );
        },
      );
    }
  }
  Widget crearListaTarjetas() {
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            )
          ),
          Icon(LucideIcons.dot),
          MyText(
            categoria.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            )
          ),
        ],
      ),
    );
  }
  Widget _crearTarjeta(Map<String,dynamic> item) {
    return GestureDetector(
      onTap: () {
        switch (item['tipo']) {
          case "Noticias":
            Navigator.push(context, MaterialPageRoute(builder: (context) => NoticiaScreen(idNoticia: item['id'],)));
            break;
          default:
            print("Error");
            break;
        }
      },
      child: Container(
        margin: EdgeInsets.all(15), // Añadir margen superior si es necesario
        padding: MySpacing.fromLTRB(15, 15, 15, 15),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255), // Fondo blanco
          borderRadius: BorderRadius.circular(5), // Bordes redondeados de 5
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Color de la sombra con opacidad
              spreadRadius: 2, // Radio de propagación
              blurRadius: 5, // Radio de desenfoque
              offset: Offset(0, 4), // Desplazamiento de la sombra (horizontal, vertical)
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16), // Bordes redondeados para la imagen
              child: SizedBox(
                width: double.infinity, // La imagen ocupará todo el ancho del contenedor
                height: 200,
                child: Image.network(
                  _backUrl+item['imagen'], // Reemplaza con la URL de tu imagen
                  fit: BoxFit.cover, // Asegúrate de que la imagen cubra todo el espacio disponible
                ),
              ),
            ),
            SizedBox(height: 10),
            _navegacion(item['tipo'], item['categoria']),
            Align(
              alignment: Alignment.centerLeft,
              child: MyText(
                item['titulo'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5), // Espacio entre el título y el texto
            MyText(
              item['descripcion'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
