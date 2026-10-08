import 'package:flutter/material.dart';

import '../../data/models/provider_model.dart';
import 'booking_form_screen.dart';

class ProviderDetailScreen extends StatelessWidget {
  final ProviderModel provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            _buildStats(),
            const SizedBox(height: 24),

            _buildSectionTitle('About'),
            const SizedBox(height: 8),
            Text(
              provider.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Skills'),
            const SizedBox(height: 10),
            _buildSkills(),

            const SizedBox(height: 24),

            _buildSectionTitle('Service Information'),
            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: provider.location,
            ),

            _buildInfoRow(
              icon: Icons.work_outline,
              title: 'Experience',
              value: '${provider.experienceYears} years',
            ),

            _buildInfoRow(
              icon: Icons.payments_outlined,
              title: 'Hourly Rate',
              value: 'LKR ${provider.hourlyRate.toStringAsFixed(0)}/hour',
            ),

            _buildInfoRow(
              icon: Icons.check_circle_outline,
              title: 'Completed Jobs',
              value: '${provider.completedJobs}',
            ),

            _buildInfoRow(
              icon: Icons.circle,
              title: 'Availability',
              value: provider.isAvailable ? 'Available' : 'Currently Busy',
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: provider.isAvailable
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingFormScreen(provider: provider),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.calendar_month),
                label: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            child: Text(
              provider.name.isNotEmpty ? provider.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            provider.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            _formatCategoryName(provider.categoryId),
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 22),
              const SizedBox(width: 4),
              Text(
                provider.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text('(${provider.reviewCount} reviews)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.work_outline,
            value: '${provider.completedJobs}',
            label: 'Jobs',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            value: provider.rating.toStringAsFixed(1),
            label: 'Rating',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.workspace_premium_outlined,
            value: '${provider.experienceYears}y',
            label: 'Experience',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSkills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: provider.skills
          .map((skill) => Chip(label: Text(skill)))
          .toList(),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
}
