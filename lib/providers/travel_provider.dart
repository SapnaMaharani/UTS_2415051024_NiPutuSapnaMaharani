
import 'package:flutter/foundation.dart';

import '../models/destination_model.dart';
import '../repositories/travel_repository.dart';

class TravelProvider extends ChangeNotifier {
  final TravelRepository repository;

  TravelProvider({
    required this.repository,
  });

  // State data destinasi
  List<Destination> _destinations = [];

  // State loading
  bool _isLoading = false;

  // State error
  String? _errorMessage;

  // Shared state: daftar favorite
  final Set<String> _favoriteIds = {};

  // Getter agar state dapat dibaca oleh halaman UI
  List<Destination> get destinations => _destinations;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  Set<String> get favoriteIds =>
      Set.unmodifiable(_favoriteIds);

  List<Destination> get favoriteDestinations {
    return _destinations
        .where((destination) => _favoriteIds.contains(destination.id))
        .toList();
  }

  // Mengecek apakah destinasi merupakan favorite
  bool isFavorite(String destinationId) {
    return _favoriteIds.contains(destinationId);
  }

  // Menambah atau menghapus favorite
  void toggleFavorite(String destinationId) {
    if (_favoriteIds.contains(destinationId)) {
      _favoriteIds.remove(destinationId);
    } else {
      _favoriteIds.add(destinationId);
    }

    notifyListeners();
  }

  // Mengambil data destinasi dari REST API
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destinations = await repository.getDestinations();
    } catch (e) {
      _errorMessage = e.toString();
      _destinations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Memuat ulang data destinasi
  Future<void> refreshDestinations() async {
    await fetchDestinations();
  }

  // Menghapus pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Mengambil detail destinasi dari data yang sudah tersedia
  Destination? findDestinationById(String id) {
    try {
      return _destinations.firstWhere(
        (destination) => destination.id == id,
      );
    } catch (_) {
      return null;
    }
  }
}
