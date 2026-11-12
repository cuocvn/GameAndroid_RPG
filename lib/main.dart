import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_providers.dart';
import 'screens/splash_screen.dart';
import 'services/save_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Set dark immersive system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 3. Initialize offline persistence (Hive & SharedPreferences)
  await SaveService.init();
  final savedPlayer = await SaveService.loadPlayer();

  runApp(
    ProviderScope(
      overrides: [
        playerProvider.overrideWith(() => PlayerNotifier(savedPlayer)),
      ],
      child: const VoAnhChienKyApp(),
    ),
  );
}

class VoAnhChienKyApp extends StatelessWidget {
  const VoAnhChienKyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vô Ảnh Chiến Ký',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
