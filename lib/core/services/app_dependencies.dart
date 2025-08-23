// import 'package:get_it/get_it.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:tabea/core/database/cache/app_preferences.dart';
// import 'package:tabea/core/services/app_shared_preferences.dart';
// import 'package:tabea/core/services/hive_storage_service.dart';
// import 'package:tabea/core/services/secure_storage_service.dart';

// final getIt = GetIt.instance;

// Future<void> setupDI() async {
//   await Hive.initFlutter();

//   // Open Hive box
//   final box = await Hive.openBox('myBox');

//   // Register HiveStorageService with the opened box
//   getIt.registerSingleton<IStorageService>(
//     HiveStorageService(box),
//     instanceName: 'hive',
//   );

//   final sharedPrefsService = SharedPreferencesService();
//   await sharedPrefsService.init();

//   getIt.registerSingleton<IStorageService>(
//     sharedPrefsService,
//     instanceName: 'shared',
//   );
//   getIt.registerSingleton<AppPreferences>(
//     AppPreferences(storageService: getIt<IStorageService>()),
//   );
// }
