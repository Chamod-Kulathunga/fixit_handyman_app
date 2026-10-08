import '../../core/enums/booking_status.dart';

class BookingModel {
  final String id;
  final String providerId;
  final String providerName;
  final String service;
  final String customerName;
  final String phone;
  final String address;
  final String jobDescription;
  final DateTime bookingDate;
  final String timeSlot;
  final int estimatedHours;
  final double hourlyRate;
  final double labourCost;
  final double visitingCharge;
  final double weekendSurcharge;
  final double totalCost;
  final BookingStatus status;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.jobDescription,
    required this.bookingDate,
    required this.timeSlot,
    required this.estimatedHours,
    required this.hourlyRate,
    required this.labourCost,
    required this.visitingCharge,
    required this.weekendSurcharge,
    required this.totalCost,
    required this.status,
    required this.createdAt,
  });

  BookingModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? service,
    String? customerName,
    String? phone,
    String? address,
    String? jobDescription,
    DateTime? bookingDate,
    String? timeSlot,
    int? estimatedHours,
    double? hourlyRate,
    double? labourCost,
    double? visitingCharge,
    double? weekendSurcharge,
    double? totalCost,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      service: service ?? this.service,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      jobDescription: jobDescription ?? this.jobDescription,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      labourCost: labourCost ?? this.labourCost,
      visitingCharge: visitingCharge ?? this.visitingCharge,
      weekendSurcharge: weekendSurcharge ?? this.weekendSurcharge,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'service': service,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'jobDescription': jobDescription,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'estimatedHours': estimatedHours,
      'hourlyRate': hourlyRate,
      'labourCost': labourCost,
      'visitingCharge': visitingCharge,
      'weekendSurcharge': weekendSurcharge,
      'totalCost': totalCost,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      service: json['service'] as String,
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      jobDescription: json['jobDescription'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      timeSlot: json['timeSlot'] as String,
      estimatedHours: json['estimatedHours'] as int,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      labourCost: (json['labourCost'] as num).toDouble(),
      visitingCharge: (json['visitingCharge'] as num).toDouble(),
      weekendSurcharge: (json['weekendSurcharge'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (value) => value.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
