class Validacion{

  bool validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value) ? false : true;
  }
  bool validateOnlyLetters(String? value) {
    const pattern = r'^[a-zA-Z]+$';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value) ? false : true;
  }
  String validarNombres(String? value, bool? esObligatorio) {
    String error = "";
    // Modificar la expresión regular para incluir caracteres con acentos y diéresis
    RegExp regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]+$');
    
    if (esObligatorio!) {
      if (value != null && value.isNotEmpty) {
        if (!regex.hasMatch(value)) {
          error = "Solo se permiten letras y caracteres válidos";
        }
      } else {
        error = "Este campo es requerido";
      }
    } else {
      if (value != null && value.isNotEmpty) {
        if (!regex.hasMatch(value)) {
          error = "Solo se permiten letras y caracteres válidos";
        }
      }
    }
    
    return error;
  }

  bool validarNumeros(String? value, bool? esObligatorio, bool? esEntero){
    bool esValido = false;
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        if(esEntero!){
          esValido = int.tryParse(value) != null;
        }else{
          esValido = true;
        }
      }else{
        esValido = false;
      }
    }else{
      if(esEntero!){
        esValido = value == null || value.isEmpty || int.tryParse(value) != null;
      }else{
        esValido = true;
      }
    }
    return esValido;
  }
  String validarNumerosPositivos(String? value, bool? esObligatorio, bool? esEntero){
    String error = "";
    if(esObligatorio!){
      if(esEntero!){
        if(value != null && value.isNotEmpty){
          if(int.tryParse(value) == null ||  (int.tryParse(value)! < 0 || int.tryParse(value).toString() != value)){
            error = "Campo no valido";
          }
        }else{
          error = "Este campo es requerido";
        }
      }else{
        if(value != null && value.isNotEmpty){
          if(int.tryParse(value) == null ||  !(int.tryParse(value)! < 0 && double.tryParse(value).toString() != value)){
            error = "Campo no valido";
          }
        }else{
          error = "Este campo es requerido";
        }
      }
    }else{
      if(esEntero!){
        if(value != null && value.isNotEmpty){
          if(int.tryParse(value) == null ||  (int.tryParse(value)! < 0 || int.tryParse(value).toString() != value)){
            error = "Campo no valido";
          }
        }
      }else{
        if(value != null && value.isNotEmpty){
          if(int.tryParse(value) == null ||  !(int.tryParse(value)! < 0 && double.tryParse(value).toString() != value)){
            error = "Campo no valido";
          }
        }
      }
    }
    return error;
  }
  String validarAlfanumericos(String? value, bool? esObligatorio){
    String error = "";
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        if(!RegExp(r'^[a-zA-Z0-9\.\-_]+$').hasMatch(value)){
          error = "Campo no valido";
        }
      }else{
        error = "Este campo es requerido";
      }
    }else{
      if(value != null && value.isNotEmpty){
        if(!RegExp(r'^[a-zA-Z]+$').hasMatch(value)){
          error = "Campo no valido";
        }
      }
    }
    return error;
  }
  String validarCorreo(String? value, bool? esObligatorio){
    String error = "";
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
        final regex = RegExp(pattern);
        if(!regex.hasMatch(value)){
          error = "El correo no es valido";
        }
      }else{
        error = "El correo es requerido";
      }
    }else{
      if(value != null && value.isNotEmpty){
        const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
         final regex = RegExp(pattern);
        if(!regex.hasMatch(value)){
          error = "El correo no es valido";
        }
      }
    }
    return error;
  }
  String validarContrasenia(String? value, bool? esObligatorio){
    String error = "";
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        if(value.length < 6 || value.length > 16){
          error = "La contraseña debe tener entre 6 a 16 caracteres";
        }
      }else{
        error = "La contraseña es requerida";
      }
    }else{
      if(value != null && value.isNotEmpty){
        if(value.length < 6 || value.length > 12){
          error = "La contraseña debe tener entre 6 a 16 caracteres";
        }
      }
    }
    return error;
  }
  String validarCelular(String? value, bool? esObligatorio){
    String error = "";
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        if(int.tryParse(value) == null ||  (int.tryParse(value)! < 60000000 || int.tryParse(value)! > 80000000 || int.tryParse(value).toString() != value)){
          error = "Campo no valido";
        }
      }else{
        error = "Este campo es requerido";
      }
    }else{
      if(value != null && value.isNotEmpty){
        if(int.tryParse(value) == null ||  (int.tryParse(value)! < 60000000 || int.tryParse(value)! > 80000000 || int.tryParse(value).toString() != value)){
          error = "Campo no valido";
        }
      }
    }
    return error;
  }
  String validarCodigoDeVerificacion(String? value, bool? esObligatorio){
    String error = "";
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        if(int.tryParse(value) == null ||  (int.tryParse(value)! < 9999 || int.tryParse(value)! > 99999 || int.tryParse(value).toString() != value)){
          error = "Campo no valido";
        }
      }else{
        error = "Este campo es requerido";
      }
    }else{
      if(value != null && value.isNotEmpty){
        if(int.tryParse(value) == null ||  (int.tryParse(value)! < 9999 || int.tryParse(value)! > 99999 || int.tryParse(value).toString() != value)){
          error = "Campo no valido";
        }
      }
    }
    return error;
  }
}