import 'package:flutter/foundation.dart';

import '../../core/enums/booking_status.dart';
import '../../data/models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/business_logic/booking_status_logic.dart';

enum BookingListStatus { initial, loading, success, error }

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;

  BookingProvider({required this._repository});

  List<BookingModel> _bookings = [];

  BookingListStatus _status = BookingListStatus.initial;

  String? _errorMessage;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  BookingListStatus get status => _status;

  String? get errorMessage => _errorMessage;

  List<BookingModel> get upcomingBookings {
    return _bookings.where((booking) {
      return BookingStatusLogic.isActive(booking.status);
    }).toList();
  }

  List<BookingModel> get historyBookings {
    return _bookings.where((booking) {
      return booking.status == BookingStatus.completed ||
          booking.status == BookingStatus.cancelled ||
          booking.status == BookingStatus.rejected;
    }).toList();
  }

  Future<void> loadBookings() async {
    _status = BookingListStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      _bookings = await _repository.getBookings();

      _status = BookingListStatus.success;
    } catch (error) {
      _errorMessage = error.toString();
      _status = BookingListStatus.error;
    }

    notifyListeners();
  }

  Future<bool> createBooking(BookingModel booking) async {
    try {
      final hasConflict = await _repository.hasActiveBooking(
        providerId: booking.providerId,
        bookingDate: booking.bookingDate,
        timeSlot: booking.timeSlot,
      );

      if (hasConflict) {
        _errorMessage =
            'This provider is already booked for this date and time slot.';
        notifyListeners();
        return false;
      }

      final createdBooking = await _repository.createBooking(booking);

      _bookings = [..._bookings, createdBooking];

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateBooking(BookingModel booking) async {
    try {
      await _repository.updateBooking(booking);

      final index = _bookings.indexWhere((item) => item.id == booking.id);

      if (index != -1) {
        _bookings[index] = booking;
        notifyListeners();
      }

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> acceptBooking(BookingModel booking) async {
    final nextStatus = BookingStatusLogic.accept(booking.status);

    if (nextStatus == null) {
      return false;
    }

    return updateBooking(booking.copyWith(status: nextStatus));
  }

  Future<bool> rejectBooking(BookingModel booking) async {
    final nextStatus = BookingStatusLogic.reject(booking.status);

    if (nextStatus == null) {
      return false;
    }

    return updateBooking(booking.copyWith(status: nextStatus));
  }

  Future<bool> startJob(BookingModel booking) async {
    final nextStatus = BookingStatusLogic.startJob(booking.status);

    if (nextStatus == null) {
      return false;
    }

    return updateBooking(booking.copyWith(status: nextStatus));
  }

  Future<bool> completeJob(BookingModel booking) async {
    final nextStatus = BookingStatusLogic.complete(booking.status);

    if (nextStatus == null) {
      return false;
    }

    return updateBooking(booking.copyWith(status: nextStatus));
  }

  Future<bool> cancelBooking(BookingModel booking) async {
    if (!BookingStatusLogic.canCancel(booking.status)) {
      return false;
    }

    return updateBooking(booking.copyWith(status: BookingStatus.cancelled));
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
