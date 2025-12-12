import 'package:arise2/repositories/auth_repository.dart';
import 'package:arise2/screens/auth_screen.dart';
import 'package:arise2/screens/main_screen.dart';
import 'package:arise2/screens/streak_viewmodel.dart';
import 'package:arise2/services/api_client.dart';
import 'package:arise2/services/auth_service.dart';
import 'package:arise2/view_models/auth_viewmodel.dart';
import 'package:arise2/viewmodels/auth_viewmodel.dart';
import 'package:arise2/view_models/game_viewmodel.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Instantiate Dependencies
  final apiClient = ApiClient(baseUrl: 'https://habit-rpg-tracker.onrender.com');
  final authService = AuthService(apiClient: apiClient);
  final authRepository = AuthRepository(authService: authService, apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameViewModel(apiClient: apiClient)),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(create: (_) => StreakViewModel(apiClient: apiClient)),
      ],
      child: const AriseApp(),
    ),
  );
}

class AriseApp extends StatelessWidget {
  const AriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arise2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
      ),
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          switch (authVM.status) {
            case AuthStatus.uninitialized:
            case AuthStatus.authenticating:
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case AuthStatus.authenticated:
              return const AuthenticatedRoot();
            case AuthStatus.unauthenticated:
              return const AuthScreen();
          }
        },
      ),
    );
  }
}

class AuthenticatedRoot extends StatefulWidget {
  const AuthenticatedRoot({super.key});

  @override
  State<AuthenticatedRoot> createState() => _AuthenticatedRootState();
}

class _AuthenticatedRootState extends State<AuthenticatedRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameViewModel>(context, listen: false).loadDashboardData();
      Provider.of<StreakViewModel>(context, listen: false).fetchStreakData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
