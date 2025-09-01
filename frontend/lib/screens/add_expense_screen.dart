import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../models/category.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      // If no categories exist, create a default one
      await _createDefaultCategory();
    }
  }

  Future<void> _createDefaultCategory() async {
    try {
      final category = await _apiService.createCategory('General', '#6366f1');
      setState(() {
        _categories = [category];
        _selectedCategory = category;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating default category: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoadingCategories
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    if (_categories.isNotEmpty)
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Add Expense'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.createExpense(
          _titleController.text,
          double.parse(_amountController.text),
          _descriptionController.text.isEmpty ? null : _descriptionController.text,
          _selectedCategory!.id,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense added successfully')),
        );

        context.pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
