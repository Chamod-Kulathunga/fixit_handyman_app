import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/provider_model.dart';
import '../providers/category_list_provider.dart';
import '../providers/provider_list_provider.dart';
import 'provider_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderListProvider>().loadProviders();
      context.read<CategoryListProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    setState(() {});

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<ProviderListProvider>().setSearchQuery(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {});

    context.read<ProviderListProvider>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final providerState = context.watch<ProviderListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FixIt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildFilterBar(),
          Expanded(child: _buildBody(providerState)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Search
  // ------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search providers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Category Filter
  // ------------------------------------------------------------

  Widget _buildCategoryFilter() {
    final categoryState = context.watch<CategoryListProvider>();

    if (categoryState.status == CategoryListStatus.initial ||
        categoryState.status == CategoryListStatus.loading) {
      return const SizedBox(
        height: 52,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (categoryState.status == CategoryListStatus.error) {
      return SizedBox(
        height: 52,
        child: Center(
          child: TextButton.icon(
            onPressed: categoryState.retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry categories'),
          ),
        ),
      );
    }

    final providerState = context.watch<ProviderListProvider>();

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: providerState.categoryId == null,
              onSelected: (_) {
                context.read<ProviderListProvider>().setCategory(null);
              },
            ),
          ),
          ...categoryState.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_formatCategoryName(category.name)),
                selected: providerState.categoryId == category.id,
                onSelected: (_) {
                  context.read<ProviderListProvider>().setCategory(category.id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatCategoryName(String categoryName) {
    switch (categoryName) {
      case 'ac_repair':
        return 'AC Repair';

      case 'plumbing':
        return 'Plumbing';

      case 'electrical':
        return 'Electrical';

      case 'carpentry':
        return 'Carpentry';

      case 'painting':
        return 'Painting';

      case 'cleaning':
        return 'Cleaning';

      default:
        return categoryName
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}'
                        '${word.substring(1)}',
            )
            .join(' ');
    }
  }

  // ------------------------------------------------------------
  // Available + Sort Filter Bar
  // ------------------------------------------------------------

  Widget _buildFilterBar() {
    final providerState = context.watch<ProviderListProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Available only'),
            selected: providerState.availableOnly,
            onSelected: (value) {
              context.read<ProviderListProvider>().setAvailableOnly(value);
            },
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort),
            label: Text(_getSortLabel(providerState)),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(ProviderListProvider providerState) {
    switch (providerState.sortBy) {
      case 'price':
        return providerState.descending ? 'Price ↓' : 'Price ↑';

      case 'experience':
        return providerState.descending ? 'Experience ↓' : 'Experience ↑';

      case 'reviews':
        return providerState.descending ? 'Reviews ↓' : 'Reviews ↑';

      case 'rating':
      default:
        return providerState.descending ? 'Rating ↓' : 'Rating ↑';
    }
  }

  // ------------------------------------------------------------
  // Sort Bottom Sheet
  // ------------------------------------------------------------

  void _showSortOptions() {
    final providerState = context.read<ProviderListProvider>();

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort Providers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildSortOption(
                  title: 'Rating',
                  sortBy: 'rating',
                  providerState: providerState,
                ),

                _buildSortOption(
                  title: 'Price',
                  sortBy: 'price',
                  providerState: providerState,
                ),

                _buildSortOption(
                  title: 'Experience',
                  sortBy: 'experience',
                  providerState: providerState,
                ),

                _buildSortOption(
                  title: 'Reviews',
                  sortBy: 'reviews',
                  providerState: providerState,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required String sortBy,
    required ProviderListProvider providerState,
  }) {
    final isSelected = providerState.sortBy == sortBy;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
      ),
      title: Text(title),
      subtitle: isSelected
          ? Text(providerState.descending ? 'Highest first' : 'Lowest first')
          : null,
      onTap: () {
        final newDescending = isSelected ? !providerState.descending : true;

        context.read<ProviderListProvider>().setSorting(
          sortBy: sortBy,
          descending: newDescending,
        );

        Navigator.of(context).pop();
      },
    );
  }

  // ------------------------------------------------------------
  // Main Body
  // ------------------------------------------------------------

  Widget _buildBody(ProviderListProvider providerState) {
    switch (providerState.status) {
      case ProviderListStatus.initial:
      case ProviderListStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ProviderListStatus.error:
        return _buildErrorState(providerState);

      case ProviderListStatus.success:
      case ProviderListStatus.loadingMore:
        if (providerState.providers.isEmpty) {
          return const Center(
            child: Text('No providers found.', style: TextStyle(fontSize: 16)),
          );
        }

        return _buildProviderList(providerState);
    }
  }

  // ------------------------------------------------------------
  // Error State
  // ------------------------------------------------------------

  Widget _buildErrorState(ProviderListProvider providerState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              providerState.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: providerState.retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Provider List
  // ------------------------------------------------------------

  Widget _buildProviderList(ProviderListProvider providerState) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount:
          providerState.providers.length + (providerState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == providerState.providers.length) {
          return _buildLoadMoreButton(providerState);
        }

        final provider = providerState.providers[index];

        return _buildProviderCard(provider);
      },
    );
  }

  // ------------------------------------------------------------
  // Provider Card
  // ------------------------------------------------------------

  Widget _buildProviderCard(ProviderModel provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(provider: provider),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: Text(
                      provider.name.isNotEmpty
                          ? provider.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.location,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  _buildAvailabilityBadge(provider),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.star, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text('(${provider.reviewCount} reviews)'),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                '${provider.experienceYears} years experience • '
                'LKR ${provider.hourlyRate.toStringAsFixed(0)}/hr',
              ),

              const SizedBox(height: 10),

              Text(
                provider.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: provider.skills
                    .take(3)
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Availability Badge
  // ------------------------------------------------------------

  Widget _buildAvailabilityBadge(ProviderModel provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Text(
        provider.isAvailable ? 'Available' : 'Busy',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ------------------------------------------------------------
  // Load More
  // ------------------------------------------------------------

  Widget _buildLoadMoreButton(ProviderListProvider providerState) {
    if (providerState.status == ProviderListStatus.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: OutlinedButton(
          onPressed: providerState.loadMore,
          child: const Text('Load More'),
        ),
      ),
    );
  }
}
