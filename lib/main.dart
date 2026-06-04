import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/plant_knowledge_base.dart';
import 'core/services/mock_sensor_service.dart';
import 'core/services/plant_health_analyzer.dart';
import 'core/services/alert_generator_service.dart';
import 'core/services/theme_service.dart';
import 'firebase_options.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/plant_repository.dart';
import 'data/repositories/alert_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 PlantCare iniciando...');

  // Configurar orientação apenas se não for web
  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      debugPrint('✅ Orientação configurada');
    } catch (e) {
      debugPrint('❌ Erro ao configurar orientação: $e');
    }
  }

  // Inicializar Firebase
  try {
    debugPrint('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar Firebase: $e');
    if (kIsWeb) {
      debugPrint('ℹ️ Continuando sem Firebase (web pode estar offline)');
    }
  }

  if (!kIsWeb) {
    try {
      debugPrint('🔐 Ativando Firebase App Check...');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      debugPrint('✅ Firebase App Check ativado');
    } catch (e) {
      debugPrint('⚠️ Firebase App Check erro (não crítico): $e');
    }
  }

  debugPrint('🎨 Inicializando ThemeService...');
  final themeService = ThemeService();
  await themeService.initialize();
  debugPrint('✅ ThemeService inicializado');

  debugPrint('📦 Configurando dependências...');
  _setupDependencies(themeService);
  debugPrint('✅ Dependências configuradas');

  if (!kIsWeb) {
    try {
      debugPrint('🔔 Inicializando NotificationService...');
      await sl<NotificationService>().initialize();
      debugPrint('✅ NotificationService inicializado');
    } catch (e) {
      debugPrint('⚠️ NotificationService erro: $e');
    }
  }

  debugPrint('🎨 Iniciando aplicativo...');
  runApp(const PlantCareApp());
}

void _setupDependencies(ThemeService themeService) {
  // Theme service
  sl.registerSingleton<ThemeService>(themeService);

  // Core services
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Plant analysis services
  sl.registerLazySingleton<PlantKnowledgeBase>(() => PlantKnowledgeBase());
  sl.registerLazySingleton<MockSensorService>(
    () => MockSensorService(sl<PlantKnowledgeBase>()),
  );
  sl.registerLazySingleton<PlantHealthAnalyzer>(
    () => PlantHealthAnalyzer(
      sl<PlantKnowledgeBase>(),
      sl<MockSensorService>(),
    ),
  );
  sl.registerLazySingleton<AlertGeneratorService>(
    () => AlertGeneratorService(
      analyzer: sl<PlantHealthAnalyzer>(),
      knowledgeBase: sl<PlantKnowledgeBase>(),
      sensorService: sl<MockSensorService>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<AuthService>()),
  );
  sl.registerLazySingleton<PlantRepository>(
    () => PlantRepository(
      sl<FirestoreService>(),
      sl<StorageService>(),
    ),
  );
  sl.registerLazySingleton<AlertRepository>(
    () => AlertRepository(sl<FirestoreService>()),
  );
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => sl<AuthService>()),
        Provider(create: (_) => sl<StorageService>()),
        ChangeNotifierProvider(create: (_) => sl<AuthRepository>()),
        ChangeNotifierProvider(create: (_) => sl<PlantRepository>()),
        ChangeNotifierProvider(create: (_) => sl<AlertRepository>()),
        ChangeNotifierProvider(create: (_) => sl<ThemeService>()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
            title: 'PlantCare',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}