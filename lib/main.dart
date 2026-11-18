import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SiGempaMalutApp());
}

class SiGempaMalutApp extends StatelessWidget {
  const SiGempaMalutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Edukasi Bencana Gempa Bumi Bagi Siswa SD di Maluku Utara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), 
    );
  }
}
