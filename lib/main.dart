import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_providers.dart';
import 'screens/home_screen.dart';
import 'services/save_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style (dark immersive)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0E17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline persistence (Hive & SharedPreferences)
  await SaveService.init();
  final savedPlayer = await SaveService.loadPlayer();

  runApp(
    ProviderScope(
      overrides: [
        playerProvider.overrideWith(() => PlayerNotifier(savedPlayer)),
      ],
      child: const TacticalRpgApp(),
    ),
  );
}

class TacticalRpgApp extends StatelessWidget {
  const TacticalRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tactical Idle RPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        primaryColor: Colors.amberAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.amberAccent,
          secondary: Colors.orangeAccent,
          surface: Color(0xFF161520),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF161520),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
