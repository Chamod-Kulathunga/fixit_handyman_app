import '../../data/models/category_model.dart';
import '../../data/models/provider_model.dart';

abstract class ProviderRepository {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProviderModel>> getProviders({
    required int page,
    String? categoryId,
    String? searchQuery,
    bool? availableOnly,
    String sortBy = 'rating',
    bool descending = true,
  });
}
