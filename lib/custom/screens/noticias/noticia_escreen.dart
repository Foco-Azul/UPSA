import 'dart:async';
import 'package:flutkit/custom/controllers/profile_controller.dart';
import 'package:flutkit/custom/models/noticia.dart';
import 'package:flutkit/custom/models/user.dart';
import 'package:flutkit/custom/utils/server.dart';
import 'package:flutkit/helpers/widgets/my_button.dart';
import 'package:flutkit/loading_effect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutkit/custom/controllers/login_controller.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';


class NoticiaScreen extends StatefulWidget {
  const NoticiaScreen({Key? key, this.idNoticia=-1}) : super(key: key);
  final int idNoticia;
  @override
  _NoticiaScreenState createState() => _NoticiaScreenState();
}

class _NoticiaScreenState extends State<NoticiaScreen> {
  int _idNoticia = -1;
  late ThemeData theme;
  late CustomTheme customTheme;
  late ProfileController controller;
  late LoginController loginController;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late Timer timerAnimation;
  int _numPages = 1;
  
  String _backUrl = "";
  Noticia _noticia = Noticia();
  List<Noticia> _otrasNoticias = [];
  int _isExpanded = 0;
  int _lineCount = 0;
  
  @override
  void initState() {
    super.initState();
    _idNoticia = widget.idNoticia;
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
    controller = ProfileController();
    _cargarDatos();
  }
  void _cargarDatos() async {
    setState(() {
      controller.uiLoading = true;
    });
    _noticia = await ApiService().getNoticia(_idNoticia);
    _otrasNoticias = await ApiService().getOtrasNoticias(_idNoticia);
    await dotenv.load(fileName: ".env");
    _backUrl = dotenv.get('backUrl');
    _noticia.galeriaDeFotos!.insert(0, _noticia.foto!);
    _numPages = _noticia.galeriaDeFotos!.length;
    final double containerWidth = MediaQuery.of(context).size.width - 24;
    _lineCount = _computeLineCount(_noticia.descripcion!, containerWidth, TextStyle(fontSize: 14));
    setState(() {
      if(_lineCount <= 8){
        _isExpanded = -1;
      }
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
        appBar: AppBar(
          toolbarHeight: 50,
          title: Center(
            child: MyText(
              _noticia.titular!,
              style: TextStyle(
                fontSize: 18, // Tamaño del texto
                fontWeight: FontWeight.w600, // Peso del texto
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(LucideIcons.share),
              onPressed: () {
                // Acción al presionar el icono de compartir
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: MySpacing.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _breadcrumbs(),
                SizedBox(
                  height: 8,
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: PageView(
                        pageSnapping: true,
                        physics: ClampingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: _crearGaleria().map((widget) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: widget,
                          );
                        }).toList(),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicatorStatic(),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: MySpacing.only(top: 12, bottom: 12),
                  child:  MyText.titleLarge(
                    _noticia.titular!,
                    fontSize: 18,
                    fontWeight: 800,
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(),
                Container(
                  margin: MySpacing.top(12),
                  child: _expandableText(
                    _noticia.descripcion!
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 14, bottom: 22), // Margen alrededor de la columna
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyButton.medium(
                        borderRadiusAll: 14,
                        buttonType: MyButtonType.outlined,
                        borderColor: Color.fromRGBO(32, 104, 14, 1),
                        splashColor: theme.colorScheme.primary.withAlpha(60),
                        onPressed: () async {
                          if (!await launchUrl(
                              Uri.parse(_noticia.notaCompleta!),
                              mode: LaunchMode.externalApplication,
                            )) {
                              throw Exception('Could not launch '+_noticia.notaCompleta!);
                            }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.externalLink,
                              color: Color.fromRGBO(32, 104, 14, 1),
                            ),
                            SizedBox(width: 8), // Espacio entre el icono y el texto
                            MyText.bodyMedium(
                              "Ver nota completa",
                              color: Color.fromRGBO(32, 104, 14, 1),
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if(_otrasNoticias.length > 0)
                Divider(
                  thickness: 2, // Grosor de la línea en píxeles
                  color: Colors.black, // Color de la línea
                ),
                if(_otrasNoticias.length > 0)
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Más noticias",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if(_otrasNoticias.length > 0)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Column(
                        children: <Widget>[
                            Container(
                            padding: MySpacing.only(top: 12, bottom: 12),
                            child: Wrap(
                              children: _buildMasNoticias(),
                            ),
                          )
                        ]
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  _buildMasNoticias() {
    List<Widget> masNoticias = [];
    for (int index = 0; index < _otrasNoticias.length; index++) {
      Noticia noticia = _otrasNoticias[index];
      masNoticias.add(Container(
        margin: EdgeInsets.only(top: 8.0, bottom: 8, right: 16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.65, // 75% del ancho de la pantalla
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image: NetworkImage(_backUrl + noticia.foto!),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 150,
                width: MediaQuery.of(context).size.width * 0.65, // 60% del ancho de la pantalla
              ),
              SizedBox(height: 16),
              Text(
                noticia.titular!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
      ));
    }
    return masNoticias;
  }
  int _computeLineCount(String text, double containerWidth, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: containerWidth);

    int lines = 0;
    for (final line in textPainter.computeLineMetrics()) {
      lines++;
    }
    return lines;
  }
  Widget _expandableText(String text) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (_lineCount > 8 && _isExpanded == 0)
        ?MyText(
          _noticia.descripcion!,
          fontSize: 14,
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        )
        :MyText(
          _noticia.descripcion!,
          fontSize: 14,
        ),
        if(_isExpanded == 0)
        Container(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = 1;
              });
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
            ),
            child: Text(
              'Leer màs',
              style: TextStyle(
                color: Color.fromRGBO(32, 104, 14, 1),
                decoration: TextDecoration.underline, // Agrega subrayado al texto
              ),
            )
          ),
        ),
        if(_isExpanded == 1)
        Container(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = 0;
              });
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
            ),
            child: Text(
              'Ver menos',
              style: TextStyle(
                color: Color.fromRGBO(32, 104, 14, 1),
                decoration: TextDecoration.underline, // Agrega subrayado al texto
              ),
            )
          ),
        ),
      ],
    );
  }

  void showSnackBarWithFloating(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText.titleSmall(message, color: theme.colorScheme.onPrimary),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  List<Widget> _crearGaleria() {
    return _noticia.galeriaDeFotos!.map((url) {
      return Container(
        decoration: BoxDecoration(
          color: customTheme.card,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: customTheme.shadowColor.withAlpha(120),
                blurRadius: 24,
                spreadRadius: 4)
          ]),
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Image.network(
            _backUrl + url,
            height: 240.0,
            fit: BoxFit.fill,
          ),
        ),
      );
    }).toList();
  }
  List<Widget> _buildPageIndicatorStatic() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromRGBO(32, 104, 14, 1) : const Color.fromARGB(160, 156, 171, 1).withAlpha(140),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
  Widget _breadcrumbs() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos del Row al centro
        children: [
          MyText(
            "Noticia",
            fontSize: 14,
            fontWeight: 500,
          ),
          Icon(LucideIcons.dot),
          MyText(
            _noticia.categoria!,
            fontSize: 14,
            fontWeight: 500,
          ),
          Icon(LucideIcons.dot),
          MyText(
            _noticia.publicacion!,
            fontSize: 14,
            fontWeight: 500,
          ),
        ],
      ),
    );
  }
}
