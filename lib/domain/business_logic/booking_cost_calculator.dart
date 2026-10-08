class BookingCostBreakdown {
  final double labourCost;
  final double visitingCharge;
  final double weekendSurcharge;
  final double totalCost;

  const BookingCostBreakdown({
    required this.labourCost,
    required this.visitingCharge,
    required this.weekendSurcharge,
    required this.totalCost,
  });
}

class BookingCostCalculator {
  static const double visitingCharge = 500.0;
  static const double weekendSurchargeRate = 0.15;

  BookingCostBreakdown calculate({
    required double hourlyRate,
    required int estimatedHours,
    required DateTime bookingDate,
  }) {
    final double labourCost = hourlyRate * estimatedHours;

    final bool isSaturday = bookingDate.weekday == DateTime.saturday;

    final double weekendSurcharge = isSaturday
        ? labourCost * weekendSurchargeRate
        : 0.0;

    final double totalCost = labourCost + visitingCharge + weekendSurcharge;

    return BookingCostBreakdown(
      labourCost: labourCost,
      visitingCharge: visitingCharge,
      weekendSurcharge: weekendSurcharge,
      totalCost: totalCost,
    );
  }
}
