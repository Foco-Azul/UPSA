// lib/styles.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppTitleStyles {
  static TextStyle onboarding({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  static TextStyle principal({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  static TextStyle tarjeta({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  static TextStyle tarjetaMenor({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
  static TextStyle subtitulo({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}
class AppTextStyles {
  static TextStyle parrafo({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }
  static TextStyle menor({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }
  static TextStyle etiqueta({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
  static TextStyle botonMayor({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
  static TextStyle botonMenor({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
  static TextStyle botonSinFondo({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
  static TextStyle bottomMenu({
    Color color = AppColorStyles.oscuro1,
  }) {
    return TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}
class AppColorStyles {
  static const Color oscuro1 = Color(0xFF1C1B1F);
  static const Color oscuro2 = Color(0xFF464646);
  static const Color gris1 = Color(0xFF858585);
  static const Color gris2 = Color(0xFFA09CAB);
  static const Color verde1 = Color(0xFF003400);
  static const Color verde2 = Color(0xFF005A41);
  static const Color verdeFondo = Color(0xFFF4FBF9);
  static const Color blancoFondo = Color(0xFFFFFFFF);
}
class AppIconStyles {
  static IconData? icono({String nombre = "circle"}) {
    final Map<String, IconData?> iconMap = {
      "sin icono": null,
      "design_services_outlined": Icons.design_services_outlined,
      "straighten_outlined": Icons.straighten_outlined,
      "balance_outlined": Icons.balance_outlined,
      "payments_outlined": Icons.payments_outlined,
      "donut_small_outlined": Icons.donut_small_outlined,
      "install_desktop_outlined": Icons.install_desktop_outlined,
      "whatsapp": FontAwesomeIcons.whatsapp,
      "mobileScreen": FontAwesomeIcons.mobileScreen,
      "mail_outline_outlined": Icons.mail_outline_outlined,
      "facebook_outlined": Icons.facebook_outlined,
      "instagram": LucideIcons.instagram,
      "tiktok_outlined": Icons.tiktok_outlined,
      "rocket_launch_outlined": Icons.rocket_launch_outlined,
      "check": Icons.check,
      "save_as_outlined": Icons.save_as_outlined,
      "earthAmericas": FontAwesomeIcons.earthAmericas,
      "contact_support_outlined": Icons.contact_support_outlined,
      "sports_basketball_outlined": Icons.sports_basketball_outlined,
      "book_outlined": Icons.book_outlined,
      "psychology_outlined": Icons.psychology_outlined,
    };
    return iconMap[nombre];
  }
}
class AppBanderaStyles {
  static String bandera({String pais = "sin bandera"}) {
    final Map<String, String> banderaMap = {
      "sin bandera": "",
      "alemania": '🇩🇪 ',
      "argentina": '🇦🇷 ',
      "belgica": '🇧🇪 ',
      "brasil": '🇧🇷 ',
      "chile": '🇨🇱 ',
      // América del Norte
      "canada": '🇨🇦 ',
      "mexico": '🇲🇽 ',
      "estados unidos": '🇺🇸 ',
      // América Central
      "belice": '🇧🇿 ',
      "costa rica": '🇨🇷 ',
      "el salvador": '🇸🇻 ',
      "guatemala": '🇬🇹 ',
      "honduras": '🇭🇳 ',
      "nicaragua": '🇳🇮 ',
      "panama": '🇵🇦 ',
      // Caribe
      "bahamas": '🇧🇸 ',
      "cuba": '🇨🇺 ',
      "dominica": '🇩🇲 ',
      "republica dominicana": '🇩🇴 ',
      "granada": '🇬🇩 ',
      "haiti": '🇭🇹 ',
      "jamaica": '🇯🇲 ',
      "san cristobal y nieves": '🇰🇳 ',
      "santa lucia": '🇱🇨 ',
      "san vicente y las granadinas": '🇻🇨 ',
      "trinidad y tobago": '🇹🇹 ',
      // América del Sur
      "bolivia": '🇧🇴 ',
      "colombia": '🇨🇴 ',
      "ecuador": '🇪🇨 ',
      "guyana": '🇬🇾 ',
      "paraguay": '🇵🇾 ',
      "peru": '🇵🇪 ',
      "surinam": '🇸🇷 ',
      "uruguay": '🇺🇾 ',
      "venezuela": '🇻🇪 ',
      // Europa
      "albania": '🇦🇱 ',
      "andorra": '🇦🇩 ',
      "armenia": '🇦🇲 ',
      "austria": '🇦🇹 ',
      "azerbaiyan": '🇦🇿 ',
      "bielorrusia": '🇧🇾 ',
      "bosnia y herzegovina": '🇧🇦 ',
      "bulgaria": '🇧🇬 ',
      "croacia": '🇭🇷 ',
      "chipre": '🇨🇾 ',
      "dinamarca": '🇩🇰 ',
      "eslovaquia": '🇸🇰 ',
      "eslovenia": '🇸🇮 ',
      "espana": '🇪🇸 ',
      "estonia": '🇪🇪 ',
      "finlandia": '🇫🇮 ',
      "francia": '🇫🇷 ',
      "georgia": '🇬🇪 ',
      "grecia": '🇬🇷 ',
      "hungria": '🇭🇺 ',
      "islandia": '🇮🇸 ',
      "irlanda": '🇮🇪 ',
      "italia": '🇮🇹 ',
      "kazajistan": '🇰🇿 ',
      "letonia": '🇱🇻 ',
      "liechtenstein": '🇱🇮 ',
      "lituania": '🇱🇹 ',
      "luxemburgo": '🇱🇺 ',
      "malta": '🇲🇹 ',
      "moldavia": '🇲🇩 ',
      "monaco": '🇲🇨 ',
      "montenegro": '🇲🇪 ',
      "paises bajos": '🇳🇱 ',
      "macedonia del norte": '🇲🇰 ',
      "noruega": '🇳🇴 ',
      "polonia": '🇵🇱 ',
      "portugal": '🇵🇹 ',
      "reino unido": '🇬🇧 ',
      "republica checa": '🇨🇿 ',
      "rumania": '🇷🇴 ',
      "rusia": '🇷🇺 ',
      "san marino": '🇸🇲 ',
      "serbia": '🇷🇸 ',
      "suecia": '🇸🇪 ',
      "suiza": '🇨🇭 ',
      "ucrania": '🇺🇦 ',
      "ciudad del vaticano": '🇻🇦 ',
    };
    return banderaMap[pais.toLowerCase()] ?? "";
  }
}
class AppDecorationStyle {
  static BoxDecoration campoContainer({Color color = AppColorStyles.blancoFondo}) {
    return BoxDecoration(
      color: color,
      boxShadow: [
        AppSombra.campo(),
      ],
      border: Border.all(
        color: AppColorStyles.gris2, // Color del borde
        width: 0.1, // Ancho del borde
      ),
      borderRadius: BorderRadius.circular(5.0), // Bordes redondeados del Container
    );
  }
  static BoxDecoration campoContainerForm({Color color = AppColorStyles.blancoFondo}) {
    return BoxDecoration(
      color: color,
      boxShadow: [
        AppSombra.campo(),
      ],
      borderRadius: BorderRadius.circular(14.0), // Bordes redondeados del Container
    );
  }
  static BoxDecoration tarjeta({
    Color color = AppColorStyles.blancoFondo,
    BorderRadius? borderRadius,
    }) {
      return BoxDecoration(
        color: color, // Fondo blanco
        borderRadius: borderRadius ?? BorderRadius.circular(5), // Aplica el borderRadius del parámetro
        boxShadow: [
          AppSombra.tarjeta(),
        ],
      );
    }
  static BoxDecoration desplegable({Color color = AppColorStyles.blancoFondo}) {
    return BoxDecoration(
      color: color, // Fondo blanco
      borderRadius: BorderRadius.circular(12), // Bordes redondeados de 5
      boxShadow: [
        AppSombra.tarjeta(),
      ],
    );
  }
  static InputDecoration campoContacto({String hintText = 'Texto', String labelText = 'Texto'}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: AppColorStyles.verde2, // Color del borde
          width: 1.0, // Ancho del borde
        ),
      ),
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: AppColorStyles.verde2, // Color del borde cuando está enfocado
          width: 2.0, // Ancho del borde cuando está enfocado
        ),
      ),
    );
  }
  static InputDecoration campoTexto({String hintText = 'Texto', String labelText = 'Texto'}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: AppColorStyles.verde2, // Color del borde cuando está enfocado
          width: 2.0, // Ancho del borde cuando está enfocado
        ),
      ),
    );
  }
  static InputDecoration campoTextoForm({String hintText = 'Texto', String labelText = 'Texto'}) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(15),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColorStyles.blancoFondo),
      ),
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: AppTextStyles.parrafo(color: AppColorStyles.verde2),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(
          color: AppColorStyles.verde2, // Color del borde cuando está enfocado
          width: 2.0, // Ancho del borde cuando está enfocado
        ),
      ),
    );
  }
  static ButtonStyle botonContacto({Color color = AppColorStyles.verde2}) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(color), // Color de fondo del botón
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 9.0, horizontal: 15)), // Padding interno del botón
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Bordes redondeados del botón
        ),
      ),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }
  static ButtonStyle botonCursillo() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(AppColorStyles.verdeFondo), // Color de fondo del botón
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 9.0, horizontal: 15)), // Padding interno del botón
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0), // Bordes redondeados del botón
        ),
      ),
    );
  }
  static ButtonStyle botonBienvenida({colorFondo = AppColorStyles.verde1}) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(colorFondo), // Color de fondo del botón
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Bordes redondeados del botón
        ),
      ),
    );
  }
}
class AppColorsMensaje {
  static const Color errorTexto = Color(0xFFF03D3E);
  static const Color exitoTexto = Color(0xFF007B40);
  static const Color notificacionTexto = Color(0xFFD84910);
  static const Color errorFondo = Color(0xFFFDECEC);
  static const Color exitoFondo = Color(0xFFE6F2EC);
  static const Color notificacionFondo = Color(0xFFFCEDE8);
}
class AppSombra {
  static BoxShadow campo() {
    return 
      BoxShadow(
        color: Color(0x1A000000), // Color de la sombra con 10% de opacidad
        offset: Offset(0, 1), // Desplazamiento de la sombra en x e y
        blurRadius: 2, // Radio de desenfoque
        spreadRadius: 0, // Radio de expansión
      );
  }
  static BoxShadow tarjeta() {
    return 
      BoxShadow(
        color: Colors.black.withOpacity(0.05), // Color de la sombra con opacidad
        spreadRadius: 2, // Radio de propagación
        blurRadius: 5, // Radio de desenfoque
        offset: Offset(0, 4), // Desplazamiento de la sombra (horizontal, vertical)
      );
  }
  static BoxShadow categoria() {
    return 
      BoxShadow(
        color: Colors.black.withOpacity(0.03), // Color de la sombra con opacidad
        spreadRadius: 2, // Radio de propagación
        blurRadius: 5, // Radio de desenfoque
        offset: Offset(0, 4), // Desplazamiento de la sombra (horizontal, vertical)
      );
  }
}