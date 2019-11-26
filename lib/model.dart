class Post {
    String idempresa;
    String titulo;
    String descripcion;
    String categoria;
    String ubicacion;
    String idhorario;
    String portada;
    String idgaleria;

    Post({
        this.idempresa,
        this.titulo,
        this.descripcion,
        this.categoria,
        this.ubicacion,
        this.idhorario,
        this.portada,
        this.idgaleria,
    });

    factory Post.fromJson(Map<String, dynamic> json) {
      return  Post(
        idempresa: json["idempresa"],
        titulo: json["titulo"],
        descripcion: json["descripcion"],
        categoria: json["categoria"],
        ubicacion: json["ubicacion"],
        idhorario: json["idhorario"],
        portada: json["portada"],
        idgaleria: json["idgaleria"],
      );
    } 

}