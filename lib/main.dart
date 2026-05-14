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
import 'firebase_options.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/plant_repository.dart';
import 'data/repositories/alert_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }

  _setupDependencies();

  if (!kIsWeb) {
    await sl<NotificationService>().initialize();
  }

  runApp(const PlantCareApp());
}

void _setupDependencies() {
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
      ],
      child: MaterialApp.router(
        title: 'PlantCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}