class ProviderModel {
  final String id;
  final String name;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final int completedJobs;
  final int experienceYears;
  final double hourlyRate;
  final String location;
  final bool isAvailable;
  final String description;
  final List<String> skills;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.rating,
    required this.reviewCount,
    required this.completedJobs,
    required this.experienceYears,
    required this.hourlyRate,
    required this.location,
    required this.isAvailable,
    required this.description,
    required this.skills,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      completedJobs: json['completedJobs'] as int,
      experienceYears: json['experienceYears'] as int,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      location: json['location'] as String,
      isAvailable: json['isAvailable'] as bool,
      description: json['description'] as String,
      skills: List<String>.from(json['skills'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'rating': rating,
      'reviewCount': reviewCount,
      'completedJobs': completedJobs,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'location': location,
      'isAvailable': isAvailable,
      'description': description,
      'skills': skills,
    };
  }

  ProviderModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? rating,
    int? reviewCount,
    int? completedJobs,
    int? experienceYears,
    double? hourlyRate,
    String? location,
    bool? isAvailable,
    String? description,
    List<String>? skills,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedJobs: completedJobs ?? this.completedJobs,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      skills: skills ?? this.skills,
    );
  }
}
