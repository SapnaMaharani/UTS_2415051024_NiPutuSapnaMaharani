
class Destination {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;

  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['spot_name'] ?? 'Unnamed Destination')
          .toString(),
      location: (json['location'] ?? 'Nusa Penida, Bali').toString(),
      description: (json['description'] ?? 'No description available.')
          .toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
