import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/app_database.dart';
import 'providers/auth_provider.dart';
import 'repositories/user_repository.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Garante que o DB será criado
  await AppDatabase.instance.database;

  runApp(const AppPressaoApp());
}

class AppPressaoApp extends StatelessWidget {
  const AppPressaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(UserRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'App Pressão',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
