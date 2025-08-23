import 'package:hive_flutter/adapters.dart';
import 'package:tabea/core/services/secure_storage_service.dart';

class HiveStorageService implements IStorageService {
  final Box box;
  HiveStorageService(this.box);

  @override
  Future<void> write(String key, dynamic value) async => box.put(key, value);

  @override
  Future<dynamic> read(String key) async => box.get(key);

  @override
  Future<void> delete(String key) async => box.delete(key);

  @override
  Future<void> deleteAll() async => box.clear();
}
