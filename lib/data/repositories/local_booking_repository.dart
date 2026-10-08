import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class LocalBookingRepository implements BookingRepository {
  static const String _bookingsKey = 'bookings';

  final SharedPreferences _preferences;

  LocalBookingRepository({required this._preferences});

  @override
  Future<List<BookingModel>> getBookings() async {
    final savedBookings = _preferences.getStringList(_bookingsKey) ?? [];

    return savedBookings
        .map(
          (bookingJson) => BookingModel.fromJson(
            jsonDecode(bookingJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final bookings = await getBookings();

    bookings.add(booking);

    await _saveBookings(bookings);

    return booking;
  }

  @override
  Future<void> updateBooking(BookingModel booking) async {
    final bookings = await getBookings();

    final index = bookings.indexWhere((item) => item.id == booking.id);

    if (index == -1) {
      throw Exception('Booking not found.');
    }

    bookings[index] = booking;

    await _saveBookings(bookings);
  }

  @override
  Future<bool> hasActiveBooking({
    required String providerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) async {
    final bookings = await getBookings();

    return bookings.any(
      (booking) =>
          booking.providerId == providerId &&
          _isSameDate(booking.bookingDate, bookingDate) &&
          booking.timeSlot == timeSlot &&
          _isActiveBooking(booking),
    );
  }

  Future<void> _saveBookings(List<BookingModel> bookings) async {
    final encodedBookings = bookings
        .map((booking) => jsonEncode(booking.toJson()))
        .toList();

    await _preferences.setStringList(_bookingsKey, encodedBookings);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _isActiveBooking(BookingModel booking) {
    return booking.status.name == 'pending' ||
        booking.status.name == 'confirmed' ||
        booking.status.name == 'inProgress';
  }
}
