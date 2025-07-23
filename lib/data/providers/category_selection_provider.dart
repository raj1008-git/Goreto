// // lib/providers/category_selection_provider.dart
//
// import 'package:flutter/material.dart';
//
// import '../datasources/remote/category_api_service.dart';
// import '../models/category/category_model.dart';
//
// class CategorySelectionProvider extends ChangeNotifier {
//   final CategoryApiService _apiService;
//
//   CategorySelectionProvider(this._apiService);
//
//   // State variables
//   List<CategoryModel> _allCategories = [];
//   List<String> _selectedCategories = [];
//   bool _isLoading = false;
//   bool _isLoadingMore = false;
//   bool _isSaving = false;
//   String? _error;
//   int _currentPage = 1;
//   bool _hasMorePages = true;
//
//   // Getters
//   List<CategoryModel> get allCategories => _allCategories;
//   List<String> get selectedCategories => _selectedCategories;
//   bool get isLoading => _isLoading;
//   bool get isLoadingMore => _isLoadingMore;
//   bool get isSaving => _isSaving;
//   String? get error => _error;
//   bool get hasMorePages => _hasMorePages;
//   int get selectedCount => _selectedCategories.length;
//
//   // Load initial categories
//   Future<void> loadCategories() async {
//     if (_isLoading) return;
//
//     _isLoading = true;
//     _error = null;
//     _currentPage = 1;
//     _allCategories.clear();
//     notifyListeners();
//
//     try {
//       final paginationData = await _apiService.getCategories(page: 1);
//       _allCategories = paginationData.data;
//       _hasMorePages = paginationData.currentPage < paginationData.lastPage;
//       _currentPage = paginationData.currentPage;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Load more categories (pagination)
//   Future<void> loadMoreCategories() async {
//     if (_isLoadingMore || !_hasMorePages) return;
//
//     _isLoadingMore = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final nextPage = _currentPage + 1;
//       final paginationData = await _apiService.getCategories(page: nextPage);
//
//       _allCategories.addAll(paginationData.data);
//       _hasMorePages = paginationData.currentPage < paginationData.lastPage;
//       _currentPage = paginationData.currentPage;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoadingMore = false;
//       notifyListeners();
//     }
//   }
//
//   // Toggle category selection
//   void toggleCategory(String categoryName) {
//     if (_selectedCategories.contains(categoryName)) {
//       _selectedCategories.remove(categoryName);
//     } else {
//       _selectedCategories.add(categoryName);
//     }
//     notifyListeners();
//   }
//
//   // Check if category is selected
//   bool isCategorySelected(String categoryName) {
//     return _selectedCategories.contains(categoryName);
//   }
//
//   // Clear all selections
//   void clearSelections() {
//     _selectedCategories.clear();
//     notifyListeners();
//   }
//
//   // Save selected categories
//   Future<bool> saveSelectedCategories() async {
//     if (_selectedCategories.isEmpty) {
//       _error = 'Please select at least one category';
//       notifyListeners();
//       return false;
//     }
//
//     _isSaving = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       await _apiService.saveUserCategories(_selectedCategories);
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }
//
//   // Reset provider state
//   void reset() {
//     _allCategories.clear();
//     _selectedCategories.clear();
//     _isLoading = false;
//     _isLoadingMore = false;
//     _isSaving = false;
//     _error = null;
//     _currentPage = 1;
//     _hasMorePages = true;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/remote/category_api_service.dart';
import '../models/category/category_model.dart';

class CategorySelectionProvider extends ChangeNotifier {
  final CategoryApiService _apiService;

  CategorySelectionProvider(this._apiService);

  // State variables
  List<CategoryModel> _allCategories = [];
  List<String> _selectedCategories = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSaving = false;

  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

  // Getters
  List<CategoryModel> get allCategories => _allCategories;
  List<String> get selectedCategories => _selectedCategories;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  int get selectedCount => _selectedCategories.length;

  // Load initial categories
  Future<void> loadCategories() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _allCategories.clear();

    notifyListeners();

    try {
      final paginationData = await _apiService.getCategories(page: 1);
      _allCategories = paginationData.data;
      _hasMorePages = paginationData.currentPage < paginationData.lastPage;
      _currentPage = paginationData.currentPage;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more categories (pagination)
  Future<void> loadMoreCategories() async {
    if (_isLoadingMore || !_hasMorePages) return;

    _isLoadingMore = true;
    _error = null;

    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final paginationData = await _apiService.getCategories(page: nextPage);
      _allCategories.addAll(paginationData.data);
      _hasMorePages = paginationData.currentPage < paginationData.lastPage;
      _currentPage = paginationData.currentPage;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Toggle category selection
  void toggleCategory(String categoryName) {
    if (_selectedCategories.contains(categoryName)) {
      _selectedCategories.remove(categoryName);
    } else {
      _selectedCategories.add(categoryName);
    }
    notifyListeners();
  }

  // Check if category is selected
  bool isCategorySelected(String categoryName) {
    return _selectedCategories.contains(categoryName);
  }

  // Clear all selections
  void clearSelections() {
    _selectedCategories.clear();
    notifyListeners();
  }

  // Save selected categories
  Future<bool> saveSelectedCategories() async {
    if (_selectedCategories.isEmpty) {
      _error = 'Please select at least one category';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.saveUserCategories(_selectedCategories);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_categories', _selectedCategories);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Load selected categories from SharedPreferences
  Future<void> loadSelectedCategoriesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList('selected_categories') ?? [];
    _selectedCategories = savedCategories;
    notifyListeners();
  }

  // Reset provider state
  void reset() async {
    _allCategories.clear();
    _selectedCategories.clear();
    _isLoading = false;
    _isLoadingMore = false;
    _isSaving = false;
    _error = null;
    _currentPage = 1;
    _hasMorePages = true;

    // Optionally clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_categories');

    notifyListeners();
  }
}
