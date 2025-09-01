// lib/core/services/trial_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// TrialService Ultra
/// دمج بين النسخة القديمة والجديدة:
/// - Singleton + init/reset/startTrial
/// - تشفير + Hash integrity + Device binding
/// - SharedPreferences + SecureStorage + SQLite cross-check
/// - Logging داخلي
class TrialService {
  static final TrialService _instance = TrialService._internal();

  // =============================
  // مفاتيح التخزين
  // =============================
  static const String _firstLaunchKey = 'firstLaunchDate';
  static const String _lastCheckKey = 'lastCheckDate';
  static const String _fakeKey = 'config_x1';
  static const String _deviceKey = 'trial_device';
  static const String _keyA = "fl_date_a";
  static const String _keyB = "fl_date_b";
  static const String _hashKey = "trial_hash";
  static const String _trialDurationKey = "trial_duration_days";

  static const int _defaultTrialDays = 7;

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized; // ✅ Getter public

  TrialService._internal();

  factory TrialService() => _instance;

  // =============================
  // 🔐 التشفير
  // =============================
  static String _encodeDate(DateTime date) {
    // حفظ التاريخ بشكل ISO مع UTC
    return date.toUtc().toIso8601String();
  }

  static DateTime _decodeDate(String encoded) {
    try {
      return DateTime.parse(encoded).toUtc();
    } catch (_) {
      throw Exception("Invalid encoded date");
    }
  }

  // =============================
  // 📌 Hash integrity check
  // =============================
  static String _generateHash(String date, String deviceId) {
    const secret = "MY_SUPER_SECRET_KEY_456";
    return sha256.convert(utf8.encode("$date|$deviceId|$secret")).toString();
  }

  static Future<bool> _validateHash(
    String date,
    String deviceId,
    String storedHash,
  ) async {
    final calcHash = _generateHash(date, deviceId);
    return calcHash == storedHash;
  }

  // =============================
  // 📌 SQLite storage
  // =============================
  static Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'trial_service.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE trial(id INTEGER PRIMARY KEY, launchDate TEXT, deviceId TEXT, hash TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> _saveToDb(
    String date,
    String deviceId,
    String hash,
  ) async {
    final db = await _openDb();
    await db.insert('trial', {
      'id': 1,
      'launchDate': date,
      'deviceId': deviceId,
      'hash': hash,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, String>?> _readFromDb() async {
    final db = await _openDb();
    final maps = await db.query('trial', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return {
        "date": maps.first['launchDate'] as String,
        "deviceId": maps.first['deviceId'] as String,
        "hash": maps.first['hash'] as String,
      };
    }
    return null;
  }

  // =============================
  // 📌 Device ID
  // =============================
  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      final info = await deviceInfo.androidInfo;
      return info.id;
    } catch (_) {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? "unknown_device";
    }
  }

  // =============================
  // ✅ Init
  // =============================
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    _log("TrialService initialized ✅");
  }

  // =============================
  // ✅ Start trial
  // =============================_encodeDate
  Future<void> startTrial({int? durationInDays}) async {
    _ensureInit();

    if (_prefs.containsKey(_firstLaunchKey)) {
      _log("Trial already started on ${_prefs.getString(_firstLaunchKey)}");
      return;
    }

    final now = DateTime.now().toUtc();
    final encoded = _encodeDate(now);

    final deviceId = await _getDeviceId();
    final hash = _generateHash(encoded, deviceId);

    // Save
    await _prefs.setString(_firstLaunchKey, encoded);
    await _prefs.setString(_hashKey, hash);
    await _prefs.setInt(_trialDurationKey, durationInDays ?? _defaultTrialDays);
    await _prefs.setString(_deviceKey, deviceId);
    await _prefs.setString(_keyA, encoded);
    await _prefs.setString(_keyB, "fake_${encoded.hashCode}");
    await _prefs.setString(
      _fakeKey,
      "dummy_${DateTime.now().millisecondsSinceEpoch}",
    );
    await _secureStorage.write(key: _firstLaunchKey, value: encoded);
    await _saveToDb(encoded, deviceId, hash);

    _log(
      "Trial started ✅ | Start: $now | Duration: ${durationInDays ?? _defaultTrialDays} days",
    );
  }

  // =============================
  // ✅ Remaining days
  // =============================
  Future<int> remainingDays() async {
    _ensureInit();

    if (!_prefs.containsKey(_firstLaunchKey)) {
      await startTrial();
    }

    await validateTime();
    await validateDevice();
    await validateIntegrity();

    final encoded = _prefs.getString(_firstLaunchKey)!;
    final startDate = _decodeDate(encoded);

    final duration = _prefs.getInt(_trialDurationKey) ?? _defaultTrialDays;
    final endDate = startDate.add(Duration(days: duration));
    final remaining = endDate.difference(DateTime.now().toUtc()).inDays;

    final safeRemaining = remaining > 0 ? remaining : 0;
    _log("Remaining days: $safeRemaining");

    return safeRemaining;
  }

  // =============================
  // ✅ Status check
  // =============================
  Future<bool> isTrialActive() async {
    final remaining = await remainingDays();
    final active = remaining > 0;
    _log("Trial active: $active");
    return active;
  }

  Future<bool> isTrialExpired() async {
    final expired = !(await isTrialActive());
    _log("Trial expired: $expired");
    return expired;
  }

  // =============================
  // ✅ Reset
  // =============================
  Future<void> resetTrial() async {
    _ensureInit();
    await _prefs.clear();
    await _secureStorage.delete(key: _firstLaunchKey);
    final db = await _openDb();
    await db.delete('trial', where: 'id = ?', whereArgs: [1]);
    _log("Trial reset 🔄");
  }

  // =============================
  // ✅ Validations
  // =============================
  Future<void> validateTime() async {
    final now = DateTime.now().toUtc();
    if (_prefs.containsKey(_lastCheckKey)) {
      final last = DateTime.parse(_prefs.getString(_lastCheckKey)!);
      if (now.isBefore(last)) {
        throw Exception("⛔ Time tampering detected!");
      }
    }
    await _prefs.setString(_lastCheckKey, now.toIso8601String());
  }

  Future<void> validateDevice() async {
    final savedId = _prefs.getString(_deviceKey);
    final currentId = await _getDeviceId();
    if (savedId != null && savedId != currentId) {
      throw Exception("⛔ Device mismatch detected!");
    }
  }

  Future<void> validateIntegrity() async {
    final encoded = _prefs.getString(_firstLaunchKey);
    final savedHash = _prefs.getString(_hashKey);
    final deviceId = _prefs.getString(_deviceKey);

    // ✅ لو أول مرة: مفيش داتا محفوظة → نعتبرها initial setup
    if (encoded == null || savedHash == null || deviceId == null) {
      debugPrint("ℹ️ Trial data not found, initializing for the first time...");
      await startTrial(); // هيعمل create للبيانات
      return;
    }

    final hashValid = await _validateHash(encoded, deviceId, savedHash);
    if (!hashValid) {
      throw Exception("⛔ Hash mismatch detected!");
    }

    final dbData = await _readFromDb();
    if (dbData == null ||
        dbData['date'] != encoded ||
        dbData['deviceId'] != deviceId ||
        dbData['hash'] != savedHash) {
      throw Exception("⛔ SQLite cross-check failed!");
    }

    debugPrint("✅ Integrity check passed successfully");
  }

  // =============================
  // ✅ Trial status map
  // =============================
  Future<Map<String, dynamic>> getTrialStatus() async {
    final expired = await isTrialExpired();
    final remaining = await remainingDays();
    final encoded = _prefs.getString(_firstLaunchKey);
    final firstLaunch = encoded != null ? _decodeDate(encoded) : null;

    return {
      "expired": expired,
      "remainingDays": remaining,
      "firstLaunch": firstLaunch?.toIso8601String(),
    };
  }

  // =============================
  // Helpers
  // =============================
  void _ensureInit() {
    if (!_isInitialized) {
      throw Exception("TrialService not initialized. Call init() first.");
    }
  }

  void _log(String message) {
    print("[TrialService] $message");
  }
}
