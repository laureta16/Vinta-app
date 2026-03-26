import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinta/theme/app_theme.dart';
import 'package:vinta/core/providers/clothing_provider.dart';
import 'package:vinta/core/providers/auth_provider.dart';
import 'package:vinta/core/services/supabase_service.dart';
import 'package:vinta/features/auth/presentation/screens/login_screen.dart';
import 'package:vinta/features/common/presentation/screens/main_screen.dart';
import 'package:vinta/core/providers/order_provider.dart';
import 'package:vinta/core/providers/notification_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (safely)
  try {
    // You'll need to run 'flutterfire configure' to generate firebase_options.dart
    // For now, we initialize with default options or skip if not configured
    await Firebase.initializeApp();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(NotificationService.firebaseMessagingBackgroundHandler);

    // Initialize our service
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase not initialized: $e. Did you run flutterfire configure?');
  }

  // Initialize Supabase Production Engine
  // Note: App will function with placeholder keys, but REAL emails require project keys in supabase_service.dart
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization skipped: $e');
  }

  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    debugPrint('Deep Link received: $uri');
    // Implement custom routing here if needed
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClothingProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
          if (!auth.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

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
