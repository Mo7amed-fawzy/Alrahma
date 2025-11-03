import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstracted interface for any storage solution
abstract class IStorageService {
  Future<void> write(String key, dynamic value);
  Future<dynamic> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class SecureStorageService implements IStorageService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  Future<void> write(String key, dynamic value) async {
    await secureStorage.write(key: key, value: value.toString());
  }

  @override
  Future<dynamic> read(String key) async {
    return await secureStorage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await secureStorage.deleteAll();
  }
}
