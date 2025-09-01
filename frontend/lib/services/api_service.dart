import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change for production
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Map<String, String> _getHeaders([bool withAuth = false]) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (withAuth) {
      // Note: Token will be added dynamically in methods
    }
    
    return headers;
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['access_token']);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<User> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(),
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<void> logout() async {
    await removeToken();
  }

  // Expense methods
  Future<List<Expense>> getExpenses() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        ..._getHeaders(),
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Expense> createExpense(String title, double amount, String? description, int categoryId) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        ..._getHeaders(),
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'amount': amount,
        'description': description,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      return Expense.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create expense');
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: {
        ..._getHeaders(),
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }

  // Category methods
  Future<List<Category>> getCategories() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        ..._getHeaders(),
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> createCategory(String name, String color) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {
        ..._getHeaders(),
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'color': color,
      }),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }
}
