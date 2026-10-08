import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/booking_status.dart';
import '../../data/models/booking_model.dart';
import '../../domain/business_logic/booking_status_logic.dart';
import '../providers/booking_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final provider = context.read<BookingProvider>();

      if (provider.status == BookingListStatus.initial) {
        provider.loadBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    await context.read<BookingProvider>().loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.status == BookingListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.status == BookingListStatus.error) {
            return _buildErrorState(bookingProvider.errorMessage);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(
                bookingProvider.upcomingBookings,
                isUpcoming: true,
              ),
              _buildBookingList(
                bookingProvider.historyBookings,
                isUpcoming: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingModel> bookings, {
    required bool isUpcoming,
  }) {
    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming: isUpcoming);
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _BookingCard(booking: bookings[index], isUpcoming: isUpcoming);
        },
      ),
    );
  }

  Widget _buildEmptyState({required bool isUpcoming}) {
    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.30),
          Icon(
            isUpcoming ? Icons.calendar_today_outlined : Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              isUpcoming ? 'No upcoming bookings' : 'No booking history',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isUpcoming
                  ? 'Your upcoming bookings will appear here.'
                  : 'Completed, cancelled, or rejected bookings '
                        'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Unable to load bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshBookings,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final BookingModel booking;
  final bool isUpcoming;

  const _BookingCard({required this.booking, required this.isUpcoming});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isCancelling = false;

  bool get _canCancel {
    return widget.isUpcoming &&
        BookingStatusLogic.canCancel(widget.booking.status);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Text(
              widget.booking.providerName,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: _formatDate(widget.booking.bookingDate),
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.access_time, text: widget.booking.timeSlot),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.schedule,
              text:
                  '${widget.booking.estimatedHours} hour'
                  '${widget.booking.estimatedHours == 1 ? '' : 's'}',
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'LKR ${widget.booking.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (_canCancel) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isCancelling
                      ? null
                      : () => _showCancelConfirmation(context),
                  child: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cancel Booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.booking.service,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        _StatusChip(status: widget.booking.status),
      ],
    );
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Keep Booking'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !context.mounted) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    final provider = context.read<BookingProvider>();

    final success = await provider.cancelBooking(widget.booking);

    if (!context.mounted) {
      return;
    }

    setState(() {
      _isCancelling = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Booking cancelled successfully.'
              : provider.errorMessage ?? 'Unable to cancel booking.',
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _formatStatus(status),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';

      case BookingStatus.confirmed:
        return 'Confirmed';

      case BookingStatus.inProgress:
        return 'In Progress';

      case BookingStatus.completed:
        return 'Completed';

      case BookingStatus.cancelled:
        return 'Cancelled';

      case BookingStatus.rejected:
        return 'Rejected';
    }
  }
}
