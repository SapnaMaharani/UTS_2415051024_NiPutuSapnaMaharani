import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_penida_travel_buddy/main.dart';

void main() {
  test('Aplikasi Nusa Penida Travel Buddy dapat dibuat', () {
    expect(const NusaPenidaApp(), isA<NusaPenidaApp>());
  });
}