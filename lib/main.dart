
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/travel_provider.dart';
import 'repositories/travel_repository.dart';
import 'screens/main_navigation_screen.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final apiService = ApiService();

  final supabaseService = SupabaseService(
    client: Supabase.instance.client,
  );

  final repository = TravelRepository(
    apiService: apiService,
    supabaseService: supabaseService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TravelProvider(
            repository: repository,
          ),
        ),
      ],
      child: const NusaPenidaApp(),
    ),
  );
}

class NusaPenidaApp extends StatelessWidget {
  const NusaPenidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nusa Penida Travel Buddy',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F8C),
          primary: const Color(0xFF087F8C),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}
