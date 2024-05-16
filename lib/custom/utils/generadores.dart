import 'dart:math';

class Generador{

  String generarUsername(String email) {
    // Obtener la fecha actual
    DateTime now = DateTime.now();
    String formattedDate = "${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year}";

    // Dividir el correo electrónico en partes
    List<String> parts = email.split('@');

    // Combinar el nombre de usuario y la fecha actual
    String username = "${parts[0]}$formattedDate";

    return username;
  }

  String generarToken() {
    // Generar un número aleatorio de 5 dígitos
    Random random = new Random();
    int randomNumber = random.nextInt(99999 - 10000) + 10000;

    // Convertir el número en una cadena de 5 dígitos
    String token = randomNumber.toString();

    return token;
  }
}