import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/booking_status.dart';
import '../../core/validators/booking_validators.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/provider_model.dart';
import '../../domain/business_logic/booking_cost_calculator.dart';
import '../../domain/business_logic/booking_id_generator.dart';
import '../providers/booking_provider.dart';
import 'booking_confirmation_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final ProviderModel provider;

  const BookingFormScreen({super.key, required this.provider});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final BookingCostCalculator _costCalculator = BookingCostCalculator();

  DateTime? _selectedDate;
  int _estimatedHours = 1;
  String _selectedTimeSlot = '09:00 AM - 11:00 AM';

  BookingCostBreakdown? _costBreakdown;

  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  @override
  void initState() {
    super.initState();

    _descriptionController.addListener(_updateCost);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateCost() {
    if (_selectedDate == null || !mounted) {
      return;
    }

    setState(_calculateCost);
  }

  void _calculateCost() {
    if (_selectedDate == null) {
      _costBreakdown = null;
      return;
    }

    _costBreakdown = _costCalculator.calculate(
      hourlyRate: widget.provider.hourlyRate,
      estimatedHours: _estimatedHours,
      bookingDate: _selectedDate!,
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 365)),
      initialDate: _selectedDate ?? now,
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
      _calculateCost();
    });
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Please select a booking date.');
      return;
    }

    final cost = _costBreakdown;

    if (cost == null) {
      _showMessage('Unable to calculate booking cost.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final booking = BookingModel(
      id: BookingIdGenerator.generate(_selectedDate!),
      providerId: widget.provider.id,
      providerName: widget.provider.name,
      service: _formatServiceName(widget.provider.categoryId),
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      jobDescription: _descriptionController.text.trim(),
      bookingDate: _selectedDate!,
      timeSlot: _selectedTimeSlot,
      estimatedHours: _estimatedHours,
      hourlyRate: widget.provider.hourlyRate,
      labourCost: cost.labourCost,
      visitingCharge: cost.visitingCharge,
      weekendSurcharge: cost.weekendSurcharge,
      totalCost: cost.totalCost,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final bookingProvider = context.read<BookingProvider>();

      final success = await bookingProvider.createBooking(booking);

      if (!mounted) {
        return;
      }

      if (!success) {
        setState(() {
          _isSubmitting = false;
        });

        final message =
            bookingProvider.errorMessage ?? 'Unable to create booking.';

        _showMessage(message);
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(booking: booking),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage('Something went wrong while creating the booking.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatServiceName(String categoryId) {
    switch (categoryId) {
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
        return categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final descriptionLength = _descriptionController.text.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProviderHeader(),

            const SizedBox(height: 24),

            _buildSectionTitle('Customer Details'),

            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: BookingValidators.validateName,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              validator: BookingValidators.validatePhone,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              enabled: !_isSubmitting,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: BookingValidators.validateAddress,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Booking Details'),

            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !_isSubmitting,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Booking Date'),
              subtitle: Text(
                _selectedDate == null
                    ? 'Select a date'
                    : _formatDate(_selectedDate!),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _isSubmitting ? null : _selectDate,
            ),

            const Divider(),

            DropdownButtonFormField<String>(
              initialValue: _selectedTimeSlot,
              decoration: const InputDecoration(
                labelText: 'Time Slot',
                border: OutlineInputBorder(),
              ),
              items: _timeSlots
                  .map(
                    (slot) => DropdownMenuItem(value: slot, child: Text(slot)),
                  )
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedTimeSlot = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _estimatedHours,
              decoration: const InputDecoration(
                labelText: 'Estimated Hours',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                8,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                    '${index + 1} hour'
                    '${index == 0 ? '' : 's'}',
                  ),
                ),
              ),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _estimatedHours = value;
                        _calculateCost();
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              maxLines: 5,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: 'Job Description',
                hintText: 'Describe the work you need...',
                border: const OutlineInputBorder(),
                counterText: '$descriptionLength/300',
              ),
              validator: BookingValidators.validateJobDescription,
            ),

            const SizedBox(height: 24),

            _buildCostBreakdown(),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text(
                        'Continue Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                widget.provider.name.isEmpty
                    ? '?'
                    : widget.provider.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.provider.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LKR ${widget.provider.hourlyRate.toStringAsFixed(0)}/hour',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBreakdown() {
    if (_costBreakdown == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select a booking date to calculate '
            'the total cost.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      );
    }

    final cost = _costBreakdown!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _buildCostRow('Labour', cost.labourCost),

            _buildCostRow('Visiting Charge', cost.visitingCharge),

            if (cost.weekendSurcharge > 0)
              _buildCostRow('Weekend Surcharge (15%)', cost.weekendSurcharge),

            const Divider(height: 24),

            _buildCostRow('Total', cost.totalCost, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 17 : 15,
            ),
          ),
          Text(
            'LKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
