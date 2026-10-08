import 'package:flutter/material.dart';

import '../../data/models/booking_model.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              _buildSuccessHeader(),

              const SizedBox(height: 24),

              _buildBookingIdCard(),

              const SizedBox(height: 16),

              _buildBookingSummary(),

              const SizedBox(height: 16),

              _buildCostSummary(),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text(
                    'View My Bookings',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withValues(alpha: 0.12),
          ),
          child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
        ),

        const SizedBox(height: 20),

        const Text(
          'Booking Created Successfully',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          'Your handyman service booking has been submitted.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBookingIdCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Booking ID',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 8),

            SelectableText(
              booking.id,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.person_outline,
              'Provider',
              booking.providerName,
            ),

            const Divider(height: 24),

            _buildInfoRow(
              Icons.home_repair_service_outlined,
              'Service',
              booking.service,
            ),

            const Divider(height: 24),

            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Date',
              _formatDate(booking.bookingDate),
            ),

            const Divider(height: 24),

            _buildInfoRow(
              Icons.access_time_outlined,
              'Time Slot',
              booking.timeSlot,
            ),

            const Divider(height: 24),

            _buildInfoRow(
              Icons.schedule_outlined,
              'Estimated Hours',
              '${booking.estimatedHours} hour(s)',
            ),

            const Divider(height: 24),

            _buildInfoRow(
              Icons.info_outline,
              'Status',
              _formatStatus(booking.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _buildCostRow('Total', booking.totalCost, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade700),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'LKR ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatStatus(dynamic status) {
    final value = status.toString().split('.').last;

    if (value.isEmpty) {
      return 'Pending';
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
