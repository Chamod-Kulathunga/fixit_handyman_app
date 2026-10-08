import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookings();

  Future<BookingModel> createBooking(BookingModel booking);

  Future<void> updateBooking(BookingModel booking);

  Future<bool> hasActiveBooking({
    required String providerId,
    required DateTime bookingDate,
    required String timeSlot,
  });
}
