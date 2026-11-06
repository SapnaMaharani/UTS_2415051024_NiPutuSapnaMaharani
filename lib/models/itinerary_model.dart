
class Itinerary {
  final String? id;
  final String spotName;
  final DateTime visitDate;
  final double budget;
  final String status;
  final String notes;

  const Itinerary({
    this.id,
    required this.spotName,
    required this.visitDate,
    required this.budget,
    required this.status,
    required this.notes,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id']?.toString(),
      spotName: (json['spot_name'] ?? '').toString(),
      visitDate: DateTime.tryParse(
            (json['visit_date'] ?? '').toString(),
          ) ??
          DateTime.now(),
      budget: double.tryParse(
            (json['budget'] ?? 0).toString(),
          ) ??
          0.0,
      status: (json['status'] ?? 'Planned').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'spot_name': spotName,
      'visit_date': visitDate.toIso8601String().split('T').first,
      'budget': budget,
      'status': status,
      'notes': notes,
    };
  }

  Itinerary copyWith({
    String? id,
    String? spotName,
    DateTime? visitDate,
    double? budget,
    String? status,
    String? notes,
  }) {
    return Itinerary(
      id: id ?? this.id,
      spotName: spotName ?? this.spotName,
      visitDate: visitDate ?? this.visitDate,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
