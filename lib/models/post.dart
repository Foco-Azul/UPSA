List<Post> postFromJson(List<dynamic> post) =>
      List<Post>.from(post.map((x) => Post.fromJson(x)));
    
    class Post {
      Post({
       required this.title,
       required this.description,
       required this.createdAt,
       required this.updatedAt,
       required this.id,
      });
    
      String title;
      DateTime createdAt;
      String description;
      int id;
      DateTime updatedAt;
    
      factory Post.fromJson(Map<dynamic, dynamic> json) {
       return Post(
         title: json['attributes']['title'],
         description: json['attributes']['description'],
         createdAt: DateTime.parse(json['attributes']['createdAt']),
         id: json['id'],
         updatedAt: DateTime.parse(json['attributes']['updatedAt']));
      }
    }