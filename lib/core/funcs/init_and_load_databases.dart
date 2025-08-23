import 'package:hive_flutter/hive_flutter.dart';
import 'package:tabea/core/database/cache/app_preferences.dart';
import 'package:tabea/core/services/hive_storage_service.dart';

abstract class DatabasesNames {
  static late AppPreferences clientsPrefs;
  static late AppPreferences projectsPrefs;
  static late AppPreferences paymentsPrefs;
  static late AppPreferences drawingsPrefs;
}

Future<void> loadDatabases() async {
  await Hive.initFlutter();

  final clientsBox = await Hive.openBox('clients');
  final projectsBox = await Hive.openBox('projects');
  final paymentsBox = await Hive.openBox('payments');
  final drawingsBox = await Hive.openBox('drawings');

  DatabasesNames.clientsPrefs = AppPreferences(
    storageService: HiveStorageService(clientsBox),
  );
  DatabasesNames.projectsPrefs = AppPreferences(
    storageService: HiveStorageService(projectsBox),
  );
  DatabasesNames.paymentsPrefs = AppPreferences(
    storageService: HiveStorageService(paymentsBox),
  );
  DatabasesNames.drawingsPrefs = AppPreferences(
    storageService: HiveStorageService(drawingsBox),
  );
}
