
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/itinerary_model.dart';

class SupabaseService {
  // Supabase client
  final SupabaseClient? client;

  SupabaseService({
    this.client,
  });

  // Memeriksa apakah Supabase sudah dikonfigurasi
  bool get isConfigured => client != null;

  // Mendapatkan Supabase client
  SupabaseClient get _supabase {
    if (client == null) {
      throw StateError(
        'Supabase belum dikonfigurasi. '
        'Periksa URL dan Publishable Key.',
      );
    }

    return client!;
  }

  // CREATE: Menambahkan itinerary baru
  Future<Itinerary> addItinerary(
    Itinerary itinerary,
  ) async {
    try {
      final data = itinerary.toJson();

      // ID dibuat otomatis oleh database
      data.remove('id');

      final response = await _supabase
          .from('my_itinerary')
          .insert(data)
          .select()
          .single();

      return Itinerary.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal menambahkan itinerary: $e',
      );
    }
  }

  // READ: Mengambil seluruh itinerary
  Future<List<Itinerary>> fetchItineraries() async {
    try {
      final response = await _supabase
          .from('my_itinerary')
          .select()
          .order('visit_date', ascending: true);

      return response
          .map<Itinerary>(
            (item) => Itinerary.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Gagal mengambil data itinerary: $e',
      );
    }
  }

  // READ: Mengambil itinerary berdasarkan ID
  Future<Itinerary> fetchItineraryById(
    String id,
  ) async {
    try {
      final response = await _supabase
          .from('my_itinerary')
          .select()
          .eq('id', id)
          .single();

      return Itinerary.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal mengambil detail itinerary: $e',
      );
    }
  }

  // UPDATE: Memperbarui itinerary
  Future<Itinerary> updateItinerary(
    String id,
    Itinerary itinerary,
  ) async {
    try {
      final data = itinerary.toJson();

      // ID tidak perlu diperbarui
      data.remove('id');

      final response = await _supabase
          .from('my_itinerary')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Itinerary.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal memperbarui itinerary: $e',
      );
    }
  }

  // DELETE: Menghapus itinerary
  Future<void> deleteItinerary(String id) async {
    try {
      await _supabase
          .from('my_itinerary')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception(
        'Gagal menghapus itinerary: $e',
      );
    }
  }
}
