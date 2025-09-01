class Category {
  final int id;
  final String name;
  final String color;
  final int userId;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'user_id': userId,
    };
  }
}
