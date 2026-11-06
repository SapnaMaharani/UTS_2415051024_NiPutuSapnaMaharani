
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/destination_model.dart';

class ApiService {
  static const String baseUrl =
      'https://6aed61a0fc3b911e6fd6220d.mockapi.io/destinations';

  final http.Client client;

  ApiService({http.Client? client})
      : client = client ?? http.Client();

  /// Mengambil semua data destinasi dari MockAPI.
  Future<List<Destination>> fetchDestinations() async {
    try {
      final response = await client
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is! List) {
          throw const FormatException(
            'Format response API tidak valid. '
            'Data destinasi harus berbentuk List.',
          );
        }

        return responseData.map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Format salah satu data destinasi tidak valid.',
            );
          }

          return Destination.fromJson(
            Map<String, dynamic>.from(item),
          );
        }).toList();
      }

      throw Exception(
        'Gagal mengambil data destinasi. '
        'HTTP Status: ${response.statusCode}',
      );
    } on FormatException {
      rethrow;
    } on http.ClientException catch (e) {
      throw Exception('Kesalahan koneksi API: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Mengambil detail satu destinasi berdasarkan ID.
  Future<Destination> fetchDestinationById(String id) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/$id'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is! Map) {
          throw const FormatException(
            'Format detail destinasi tidak valid.',
          );
        }

        return Destination.fromJson(
          Map<String, dynamic>.from(responseData),
        );
      }

      if (response.statusCode == 404) {
        throw Exception('Destinasi dengan ID $id tidak ditemukan.');
      }

      throw Exception(
        'Gagal mengambil detail destinasi. '
        'HTTP Status: ${response.statusCode}',
      );
    } on FormatException {
      rethrow;
    } on http.ClientException catch (e) {
      throw Exception('Kesalahan koneksi API: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Menutup HTTP client.
  void dispose() {
    client.close();
  }
}
