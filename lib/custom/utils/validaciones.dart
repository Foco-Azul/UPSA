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
  bool validarTextos(String? value, bool? esObligatorio){
    bool esValido = false;
    if(esObligatorio!){
      esValido = value != null && value.isNotEmpty && RegExp(r'^[a-zA-Z]+$').hasMatch(value);
    }else{
      if(value != null && value.isNotEmpty){
        esValido = RegExp(r'^[a-zA-Z]+$').hasMatch(value);
      }else{
        esValido = true;
      }
    }
    return esValido;
  }
  bool validarNumeros(String? value, bool? esObligatorio, bool? esEntero){
    bool esValido = false;
    if(esObligatorio!){
      if(value != null && value.isNotEmpty){
        if(esEntero!){
          esValido = int.tryParse(value ?? '') != null;
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
  bool validarNumerosPositivos(String? value, bool? esObligatorio, bool? esEntero){
    bool esValido = false;
    if(esObligatorio!){
      if(esEntero!){

      }else{

      }
    }else{
      if(esEntero!){

      }else{

      }
    }
    return esValido;
  }
  bool validarAlfanumericos(String? value, bool? esObligatorio){
    bool esValido = false;
    if(esObligatorio!){

    }else{

    }
    return esValido;
  }
  bool validarCorreo(String? value, bool? esObligatorio){
    bool esValido = false;
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
        esValido = regex.hasMatch(value);
      }else{
        esValido = false;
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
        esValido = regex.hasMatch(value);
      }else{
        esValido = true;
      }
    }
    return esValido;
  }
}