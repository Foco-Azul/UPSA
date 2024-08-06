 
class Notificacion {
  Notificacion({
    this.tipoNotificacion,
    this.tipoContenido,
    this.titulo,
    this.descripcion,
    this.id,
    this.estadoNotificacion,
    
  });

  String? tipoNotificacion;
  String? tipoContenido;
  String? titulo;
  String? descripcion;
  int? id;
  String? estadoNotificacion;
  bool? visto;

  static Notificacion armarNotificacion(Map<String, dynamic> json) {
    return Notificacion(
      tipoNotificacion: json['tipoNotificacion'],
      tipoContenido: json['tipoContenido'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      id: int.parse(json['id']),
      estadoNotificacion: json['estadoNotificacion'],
    );
  }

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      tipoNotificacion: json['tipoNotificacion'],
      tipoContenido: json['tipoContenido'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      id: int.parse(json['id']),
      estadoNotificacion: json['estadoNotificacion'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    "tipoNotificacion": tipoNotificacion,
    "tipoContenido": tipoContenido,
    "titulo": titulo,
    "descripcion": descripcion,
    "id": id,
    "estadoNotificacion": estadoNotificacion,
  };

  @override
  String toString() {
    return 'Notificacion{tipoNotificacion: $tipoNotificacion, tipoContenido: $tipoContenido, titulo: $titulo, descripcion: $descripcion, id: $id, estadoNotificacion: $estadoNotificacion}';
  }
}