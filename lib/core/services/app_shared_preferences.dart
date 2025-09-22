import 'package:shared_preferences/shared_preferences.dart';
import 'package:alrahma/core/services/secure_storage_service.dart';

class SharedPreferencesService implements IStorageService {
  late SharedPreferences _prefs;

  SharedPreferencesService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> write(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw Exception("Unsupported data type");
    }
  }

  @override
  Future<dynamic> read(String key) async {
    return _prefs.get(key);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _prefs.clear();
  }
}
