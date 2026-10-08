import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../domain/repositories/provider_repository.dart';

enum CategoryListStatus { initial, loading, success, error }

class CategoryListProvider extends ChangeNotifier {
  final ProviderRepository _repository;

  CategoryListProvider({required this._repository});

  List<CategoryModel> _categories = [];

  CategoryListStatus _status = CategoryListStatus.initial;

  String? _errorMessage;

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  CategoryListStatus get status => _status;

  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _status = CategoryListStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final results = await _repository.getCategories();

      _categories = results;
      _status = CategoryListStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = CategoryListStatus.error;
    }

    notifyListeners();
  }

  Future<void> retry() async {
    await loadCategories();
  }
}
