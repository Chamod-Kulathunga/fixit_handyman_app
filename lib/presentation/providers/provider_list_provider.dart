import 'package:flutter/foundation.dart';

import '../../data/models/provider_model.dart';
import '../../domain/repositories/provider_repository.dart';

enum ProviderListStatus { initial, loading, success, loadingMore, error }

class ProviderListProvider extends ChangeNotifier {
  final ProviderRepository _repository;

  ProviderListProvider({required this._repository});

  final List<ProviderModel> _providers = [];

  ProviderListStatus _status = ProviderListStatus.initial;

  String? _errorMessage;

  int _currentPage = 1;

  bool _hasMore = true;

  String? _categoryId;

  String _searchQuery = '';

  bool _availableOnly = false;

  String _sortBy = 'rating';

  bool _descending = true;

  List<ProviderModel> get providers => List.unmodifiable(_providers);

  ProviderListStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get hasMore => _hasMore;

  String? get categoryId => _categoryId;

  String get searchQuery => _searchQuery;

  bool get availableOnly => _availableOnly;

  String get sortBy => _sortBy;

  bool get descending => _descending;

  Future<void> loadProviders() async {
    _currentPage = 1;
    _hasMore = true;
    _providers.clear();

    _status = ProviderListStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final results = await _repository.getProviders(
        page: _currentPage,
        categoryId: _categoryId,
        searchQuery: _searchQuery,
        availableOnly: _availableOnly,
        sortBy: _sortBy,
        descending: _descending,
      );

      _providers.addAll(results);

      _hasMore = results.length == 10;

      _status = ProviderListStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = ProviderListStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore ||
        _status == ProviderListStatus.loading ||
        _status == ProviderListStatus.loadingMore) {
      return;
    }

    _status = ProviderListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      final results = await _repository.getProviders(
        page: nextPage,
        categoryId: _categoryId,
        searchQuery: _searchQuery,
        availableOnly: _availableOnly,
        sortBy: _sortBy,
        descending: _descending,
      );

      _providers.addAll(results);

      _currentPage = nextPage;

      _hasMore = results.length == 10;

      _status = ProviderListStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = ProviderListStatus.success;
    }

    notifyListeners();
  }

  Future<void> setCategory(String? categoryId) async {
    _categoryId = categoryId;
    await loadProviders();
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadProviders();
  }

  Future<void> setAvailableOnly(bool value) async {
    _availableOnly = value;
    await loadProviders();
  }

  Future<void> setSorting({
    required String sortBy,
    required bool descending,
  }) async {
    _sortBy = sortBy;
    _descending = descending;

    await loadProviders();
  }

  Future<void> retry() async {
    await loadProviders();
  }
}
