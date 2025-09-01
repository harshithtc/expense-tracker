import 'category.dart';

class Expense {
  final int id;
  final String title;
  final double amount;
  final String? description;
  final DateTime date;
  final int userId;
  final int categoryId;
  final Category? category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    this.description,
    required this.date,
    required this.userId,
    required this.categoryId,
    this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      userId: json['user_id'],
      categoryId: json['category_id'],
      category: json['category'] != null 
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'user_id': userId,
      'category_id': categoryId,
    };
  }
}
