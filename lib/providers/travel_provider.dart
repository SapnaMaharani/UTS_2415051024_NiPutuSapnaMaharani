
import 'package:flutter/foundation.dart';

import '../models/destination_model.dart';
import '../models/itinerary_model.dart';
import '../repositories/travel_repository.dart';

class TravelProvider extends ChangeNotifier {
  final TravelRepository repository;

  TravelProvider({
    required this.repository,
  });

  // ==========================================
  // DESTINATION STATE
  // ==========================================

  List<Destination> _destinations = [];

  bool _isLoading = false;

  String? _errorMessage;

  // ==========================================
  // ITINERARY STATE
  // ==========================================

  List<Itinerary> _itineraries = [];

  bool _isItineraryLoading = false;

  bool _isSaving = false;

  String? _itineraryError;

  // ==========================================
  // FAVORITE STATE
  // ==========================================

  final Set<String> _favoriteIds = {};

  // ==========================================
  // GETTERS
  // ==========================================

  List<Destination> get destinations => _destinations;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<Itinerary> get itineraries => _itineraries;

  bool get isItineraryLoading => _isItineraryLoading;

  bool get isSaving => _isSaving;

  String? get itineraryError => _itineraryError;

  Set<String> get favoriteIds =>
      Set.unmodifiable(_favoriteIds);

  List<Destination> get favoriteDestinations {
    return _destinations
        .where(
          (destination) => _favoriteIds.contains(destination.id),
        )
        .toList();
  }

  // ==========================================
  // DESTINATION METHODS
  // ==========================================

  // Mengambil destinasi dari MockAPI.
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destinations = await repository.getDestinations();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh destinasi.
  Future<void> refreshDestinations() async {
    await fetchDestinations();
  }

  // Mencari destinasi berdasarkan ID.
  Destination? findDestinationById(String id) {
    try {
      return _destinations.firstWhere(
        (destination) => destination.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // Menghapus pesan error destinasi.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==========================================
  // FAVORITE METHODS
  // ==========================================

  bool isFavorite(String destinationId) {
    return _favoriteIds.contains(destinationId);
  }

  void toggleFavorite(String destinationId) {
    if (_favoriteIds.contains(destinationId)) {
      _favoriteIds.remove(destinationId);
    } else {
      _favoriteIds.add(destinationId);
    }

    notifyListeners();
  }

  // ==========================================
  // ITINERARY METHODS - SUPABASE
  // ==========================================

  // READ: Mengambil seluruh itinerary.
  Future<void> fetchItineraries() async {
    _isItineraryLoading = true;
    _itineraryError = null;
    notifyListeners();

    try {
      _itineraries = await repository.getItineraries();
    } catch (e) {
      _itineraryError = e.toString();
    } finally {
      _isItineraryLoading = false;
      notifyListeners();
    }
  }

  // CREATE: Menambahkan itinerary baru.
  Future<bool> addItinerary(Itinerary itinerary) async {
    _isSaving = true;
    _itineraryError = null;
    notifyListeners();

    try {
      final newItinerary = await repository.addItinerary(itinerary);

      _itineraries.add(newItinerary);

      _itineraries.sort(
        (a, b) => a.visitDate.compareTo(b.visitDate),
      );

      return true;
    } catch (e) {
      _itineraryError = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // UPDATE: Memperbarui itinerary.
  Future<bool> updateItinerary(
    String id,
    Itinerary itinerary,
  ) async {
    _isSaving = true;
    _itineraryError = null;
    notifyListeners();

    try {
      final updatedItinerary = await repository.updateItinerary(
        id,
        itinerary,
      );

      final index = _itineraries.indexWhere(
        (item) => item.id == id,
      );

      if (index != -1) {
        _itineraries[index] = updatedItinerary;
      }

      _itineraries.sort(
        (a, b) => a.visitDate.compareTo(b.visitDate),
      );

      return true;
    } catch (e) {
      _itineraryError = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // DELETE: Menghapus itinerary.
  Future<bool> deleteItinerary(String id) async {
    _isSaving = true;
    _itineraryError = null;
    notifyListeners();

    try {
      await repository.deleteItinerary(id);

      _itineraries.removeWhere(
        (item) => item.id == id,
      );

      return true;
    } catch (e) {
      _itineraryError = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Menghapus pesan error itinerary.
  void clearItineraryError() {
    _itineraryError = null;
    notifyListeners();
  }
}
