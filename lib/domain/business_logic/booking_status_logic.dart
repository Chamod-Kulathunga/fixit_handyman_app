import '../../core/enums/booking_status.dart';

class BookingStatusLogic {
  static bool isActive(BookingStatus status) {
    return status == BookingStatus.pending ||
        status == BookingStatus.confirmed ||
        status == BookingStatus.inProgress;
  }

  static bool canCancel(BookingStatus status) {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }

  static bool canAccept(BookingStatus status) {
    return status == BookingStatus.pending;
  }

  static bool canReject(BookingStatus status) {
    return status == BookingStatus.pending;
  }

  static bool canStartJob(BookingStatus status) {
    return status == BookingStatus.confirmed;
  }

  static bool canComplete(BookingStatus status) {
    return status == BookingStatus.inProgress;
  }

  static BookingStatus? accept(BookingStatus status) {
    if (!canAccept(status)) {
      return null;
    }

    return BookingStatus.confirmed;
  }

  static BookingStatus? reject(BookingStatus status) {
    if (!canReject(status)) {
      return null;
    }

    return BookingStatus.rejected;
  }

  static BookingStatus? startJob(BookingStatus status) {
    if (!canStartJob(status)) {
      return null;
    }

    return BookingStatus.inProgress;
  }

  static BookingStatus? complete(BookingStatus status) {
    if (!canComplete(status)) {
      return null;
    }

    return BookingStatus.completed;
  }
}
