import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_providers.dart';
import 'screens/home_screen.dart';
import 'services/save_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style (dark immersive)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
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
      theme: AppTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
