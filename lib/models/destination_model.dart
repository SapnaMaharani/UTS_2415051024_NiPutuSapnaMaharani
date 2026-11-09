
class Destination {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;

  final double? entranceFee;
  final double? transportCost;
  final double? mealCost;
  final double? activityCost;

  final double? rating;
  final int? reviewCount;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.entranceFee,
    this.transportCost,
    this.mealCost,
    this.activityCost,
    this.rating,
    this.reviewCount,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    double? parseCost(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return null;
      }

      if (value is num) return value.toDouble();

      return double.tryParse(value.toString());
    }

    int? parseCount(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return null;
      }

      if (value is num) return value.toInt();

      return int.tryParse(value.toString());
    }

    return Destination(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      entranceFee: parseCost(json['entrance_fee']),
      transportCost: parseCost(json['transport_cost']),
      mealCost: parseCost(json['meal_cost']),
      activityCost: parseCost(json['activity_cost']),
      rating: parseCost(json['rating']),
      reviewCount: parseCount(json['review_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image_url': imageUrl,
      'entrance_fee': entranceFee,
      'transport_cost': transportCost,
      'meal_cost': mealCost,
      'activity_cost': activityCost,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  double? get totalTripCostPerPerson {
    if (entranceFee == null ||
        transportCost == null ||
        mealCost == null ||
        activityCost == null) {
      return null;
    }

    return entranceFee! +
        transportCost! +
        mealCost! +
        activityCost!;
  }
}
