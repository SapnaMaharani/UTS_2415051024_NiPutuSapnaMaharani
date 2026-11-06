
import '../models/destination_model.dart';
import '../models/itinerary_model.dart';
import '../services/api_service.dart';

class TravelRepository {
  final ApiService apiService;

  TravelRepository({
    required this.apiService,
  });

  // Mengambil seluruh destinasi dari REST API.
  Future<List<Destination>> getDestinations() async {
    try {
      return await apiService.fetchDestinations();
    } catch (e) {
      throw Exception('Repository gagal mengambil destinasi: $e');
    }
  }

  // Mengambil detail destinasi berdasarkan ID.
  Future<Destination> getDestinationById(String id) async {
    try {
      return await apiService.fetchDestinationById(id);
    } catch (e) {
      throw Exception('Repository gagal mengambil detail destinasi: $e');
    }
  }

  // Konversi data itinerary ke JSON.
  Map<String, dynamic> prepareItineraryData(
    Itinerary itinerary,
  ) {
    return itinerary.toJson();
  }
}
