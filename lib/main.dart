import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/cart_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/routing/app_router.dart';
import 'shared/themes/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  try {
    final firebaseService = FirebaseService();
    await firebaseService.init();
    await firebaseService.initMessaging();
    await NotificationService().init();
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    // Continue without Firebase if initialization fails
  }
  
  // Initialize other services
  await StorageService().init();
  ApiService().init();
  await AuthService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Foodie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: AppRouter.getRoutes(),
          );
        },
      ),
    );
  }
}

