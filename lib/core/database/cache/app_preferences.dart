import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:alrahma/core/services/secure_storage_service.dart';

class AppPreferences {
  static AppPreferences? _instance;
  final IStorageService storageService;

  /// StreamController for listening changes
  final ValueNotifier<Map<String, dynamic>> changesNotifier = ValueNotifier({});

  factory AppPreferences({required IStorageService storageService}) {
    _instance ??= AppPreferences._internal(storageService);
    return _instance!;
  }

  AppPreferences._internal(this.storageService);

  /// Save data
  Future<void> setData(String key, dynamic value) async {
    await storageService.write(key, value);
    changesNotifier.value = {...changesNotifier.value, key: value};
  }

  /// Get data
  Future<dynamic> getData(String key) async {
    return await storageService.read(key);
  }

  /// Remove data
  Future<void> removeData(String key) async {
    await storageService.delete(key);
    changesNotifier.value = {...changesNotifier.value}..remove(key);
  }

  /// Save object model
  Future<void> saveModel<T>(
    String key,
    T model,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final jsonString = jsonEncode(toJson(model));
    await setData(key, jsonString);
  }

  /// Get object model
  Future<T?> getModel<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonString = await getData(key);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return fromJson(jsonMap);
    }
    return null;
  }

  /// Save list of models
  Future<void> saveModels<T>(
    String key,
    List<T> models,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final List<String> jsonList = models
        .map((m) => jsonEncode(toJson(m)))
        .toList();
    await setData(key, jsonList);
  }

  /// Get list of models
  Future<List<T>> getModels<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final data = await getData(key);
    if (data != null && data is List<String>) {
      return data.map((json) => fromJson(jsonDecode(json))).toList();
    }
    return [];
  }

  /// Clear all data
  Future<void> clearAll() async {
    await storageService.deleteAll();
    changesNotifier.value = {};
  }
}
