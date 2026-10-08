import 'dart:math';

class BookingIdGenerator {
  static final Random _random = Random();

  static String generate(DateTime date) {
    final datePart =
        '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';

    final randomPart = _random.nextInt(10000).toString().padLeft(4, '0');

    return 'FX-$datePart-$randomPart';
  }
}
