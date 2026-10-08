import 'dart:math';

import '../../domain/repositories/provider_repository.dart';
import '../models/category_model.dart';
import '../models/provider_model.dart';
import '../services/local_data_service.dart';

class MockProviderRepository implements ProviderRepository {
  final LocalDataService _dataService;

  MockProviderRepository({LocalDataService? dataService})
    : _dataService = dataService ?? LocalDataService();

  final Random _random = Random();

  static const int _pageSize = 10;

  Future<void> _simulateNetwork() async {
    final delayMilliseconds = 800 + _random.nextInt(701);

    await Future.delayed(Duration(milliseconds: delayMilliseconds));

    if (_random.nextDouble() < 0.2) {
      throw Exception('Unable to load providers. Please try again.');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await _simulateNetwork();

    final data = await _dataService.loadProvidersData();

    final categories = data['categories'] as List;

    return categories
        .map(
          (category) =>
              CategoryModel.fromJson(category as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<ProviderModel>> getProviders({
    required int page,
    String? categoryId,
    String? searchQuery,
    bool? availableOnly,
    String sortBy = 'rating',
    bool descending = true,
  }) async {
    await _simulateNetwork();

    final data = await _dataService.loadProvidersData();

    List<ProviderModel> providers = (data['providers'] as List)
        .map(
          (provider) =>
              ProviderModel.fromJson(provider as Map<String, dynamic>),
        )
        .toList();

    // Category filter
    if (categoryId != null && categoryId.isNotEmpty) {
      providers = providers
          .where((provider) => provider.categoryId == categoryId)
          .toList();
    }

    // Search filter
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();

      providers = providers.where((provider) {
        final nameMatches = provider.name.toLowerCase().contains(query);

        final locationMatches = provider.location.toLowerCase().contains(query);

        final descriptionMatches = provider.description.toLowerCase().contains(
          query,
        );

        final skillMatches = provider.skills.any(
          (skill) => skill.toLowerCase().contains(query),
        );

        return nameMatches ||
            locationMatches ||
            descriptionMatches ||
            skillMatches;
      }).toList();
    }

    // Availability filter
    if (availableOnly == true) {
      providers = providers.where((provider) => provider.isAvailable).toList();
    }
    // Sorting
    providers.sort((a, b) {
      int result;

      switch (sortBy) {
        case 'rating':
          result = a.rating.compareTo(b.rating);
          break;

        case 'price':
          result = a.hourlyRate.compareTo(b.hourlyRate);
          break;

        case 'experience':
          result = a.experienceYears.compareTo(b.experienceYears);
          break;

        case 'reviews':
          result = a.reviewCount.compareTo(b.reviewCount);
          break;

        default:
          result = a.rating.compareTo(b.rating);
      }

      return descending ? -result : result;
    });
    // Pagination
    final startIndex = (page - 1) * _pageSize;

    if (startIndex >= providers.length) {
      return [];
    }

    final endIndex = min(startIndex + _pageSize, providers.length);

    return providers.sublist(startIndex, endIndex);
  }
}
