import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinta/theme/app_theme.dart';
import 'package:vinta/core/providers/clothing_provider.dart';
import 'package:vinta/core/providers/auth_provider.dart';
import 'package:vinta/core/services/supabase_service.dart';
import 'package:vinta/features/auth/presentation/screens/login_screen.dart';
import 'package:vinta/features/common/presentation/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase Production Engine
  // Note: App will function with placeholder keys, but REAL emails require project keys in supabase_service.dart
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization skipped: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClothingProvider()),
      ],
      child: const VintaApp(),
    ),
  );
}

class VintaApp extends StatelessWidget {
  const VintaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
