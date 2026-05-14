import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/plant/plant_detail_screen.dart';
import '../screens/plant/add_plant_screen.dart';
import '../screens/plant/edit_plant_screen.dart';
import '../screens/plant_health_detail_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/splash',
        debugLogDiagnostics: false,
        redirect: (context, state) {
          final authRepo = context.read<AuthRepository>();
          final isLoggedIn = authRepo.isAuthenticated;
          final isSplash = state.matchedLocation == '/splash';
          final isAuthRoute = state.matchedLocation.startsWith('/auth');

          if (isSplash) return null;
          if (!isLoggedIn && !isAuthRoute) return '/auth/login';
          if (isLoggedIn && isAuthRoute) return '/home';

          return null;
        },
        routes: [
          GoRoute(
            path: '/splash',
            builder: (_, __) => const SplashScreen(),
          ),
          GoRoute(
            path: '/auth/login',
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: '/auth/register',
            builder: (_, __) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/plant/add',
            builder: (_, __) => const AddPlantScreen(),
          ),
          GoRoute(
            path: '/plant/:id',
            builder: (_, state) => PlantDetailScreen(
              plantId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/plant/:id/edit',
            builder: (_, state) => EditPlantScreen(
              plantId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/plant/:id/health',
            builder: (_, state) {
              // Note: Esta é uma rota simplificada
              // Em produção, você buscaria a planta do banco de dados
              // Por enquanto, retorna um placeholder
              return Scaffold(
                appBar: AppBar(title: const Text('Saúde da Planta')),
                body: const Center(
                  child: Text('Tela de saúde da planta'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/alerts',
            builder: (_, __) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text('Página não encontrada: ${state.error}'),
          ),
        ),
      );
}