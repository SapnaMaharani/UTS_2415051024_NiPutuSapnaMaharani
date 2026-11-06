
import '../models/destination_model.dart';
import '../models/itinerary_model.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class TravelRepository {
  final ApiService apiService;
  final SupabaseService supabaseService;

  TravelRepository({
    required this.apiService,
    required this.supabaseService,
  });

  // ==========================================
  // DESTINATION - REST API MOCKAPI
  // ==========================================

  // Mengambil seluruh destinasi.
  Future<List<Destination>> getDestinations() async {
    try {
      return await apiService.fetchDestinations();
    } catch (e) {
      throw Exception('Gagal mengambil destinasi: $e');
    }
  }

  // Mengambil detail destinasi berdasarkan ID.
  Future<Destination> getDestinationById(String id) async {
    try {
      return await apiService.fetchDestinationById(id);
    } catch (e) {
      throw Exception('Gagal mengambil detail destinasi: $e');
    }
  }

  // ==========================================
  // ITINERARY - SUPABASE DATABASE
  // ==========================================

  // CREATE: Menambahkan itinerary.
  Future<Itinerary> addItinerary(
    Itinerary itinerary,
  ) async {
    try {
      return await supabaseService.addItinerary(itinerary);
    } catch (e) {
      throw Exception('Gagal menambahkan itinerary: $e');
    }
  }

  // READ: Mengambil semua itinerary.
  Future<List<Itinerary>> getItineraries() async {
    try {
      return await supabaseService.fetchItineraries();
    } catch (e) {
      throw Exception('Gagal mengambil itinerary: $e');
    }
  }

  // READ: Mengambil detail itinerary.
  Future<Itinerary> getItineraryById(String id) async {
    try {
      return await supabaseService.fetchItineraryById(id);
    } catch (e) {
      throw Exception('Gagal mengambil detail itinerary: $e');
    }
  }

  // UPDATE: Mengubah itinerary.
  Future<Itinerary> updateItinerary(
    String id,
    Itinerary itinerary,
  ) async {
    try {
      return await supabaseService.updateItinerary(
        id,
        itinerary,
      );
    } catch (e) {
      throw Exception('Gagal memperbarui itinerary: $e');
    }
  }

  // DELETE: Menghapus itinerary.
  Future<void> deleteItinerary(String id) async {
    try {
      await supabaseService.deleteItinerary(id);
    } catch (e) {
      throw Exception('Gagal menghapus itinerary: $e');
    }
  }
}
