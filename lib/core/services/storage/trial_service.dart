// lib/core/services/trial_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
  bool get isInitialized => _isInitialized;

  TrialService._internal();

  factory TrialService() => _instance;

  // =============================
  // 🔐 التشفير
  // =============================
  static String _encodeDate(DateTime date) => date.toUtc().toIso8601String();

  static DateTime _decodeDate(String encoded) {
    try {
      return DateTime.parse(encoded).toUtc();
    } catch (_) {
      throw Exception("Invalid encoded date");
    }
  }

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
  // =============================
  // =============================
  // تعديل startTrial() بحيث يستخدم SQLite + secureStorage backup
  Future<void> startTrial({int? durationInDays}) async {
    _ensureInit();

    // لو SQLite موجودة مسبقًا → لا تعيد startTrial
    final dbData = await _readFromDb();
    if (dbData != null) {
      _log("Trial already exists in SQLite, skipping startTrial.");
      await _restorePrefsFromDb(dbData); // تحدث cache فقط
      return;
    }

    // تأكيد deviceId و integrity
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

    // Backup مشفر في secureStorage
    final backupData = jsonEncode({
      "date": encoded,
      "deviceId": deviceId,
      "hash": hash,
      "duration": durationInDays ?? _defaultTrialDays,
    });
    await _secureStorage.write(key: "trial_backup", value: backupData);

    _log(
      "Trial started ✅ | Start: $now | Duration: ${durationInDays ?? _defaultTrialDays} days",
    );
  }

  // =============================
  // تعديل validateIntegrity لدعم restore من backup
  Future<void> validateIntegrity() async {
    final dbData = await _readFromDb();
    if (dbData != null) {
      // SQLite موجود → تحديث cache
      await _restorePrefsFromDb(dbData);
      _log("Integrity check passed from SQLite ✅");
      return;
    }

    // لو SQLite مفقودة → محاولة استرجاع من secureStorage backup
    final backup = await _secureStorage.read(key: "trial_backup");
    if (backup != null) {
      final Map<String, dynamic> data = jsonDecode(backup);
      final hashValid = await _validateHash(
        data["date"],
        data["deviceId"],
        data["hash"],
      );
      if (!hashValid) throw Exception("⛔ Backup hash mismatch!");

      // إعادة إنشاء SQLite من backup
      await _saveToDb(data["date"], data["deviceId"], data["hash"]);
      await _prefs.setString(_firstLaunchKey, data["date"]);
      await _prefs.setString(_hashKey, data["hash"]);
      await _prefs.setString(_deviceKey, data["deviceId"]);
      await _prefs.setInt(_trialDurationKey, data["duration"]);
      _log("Integrity restored from secureStorage backup ✅");
      return;
    }

    // لا SQLite ولا backup → إنشاء trial جديد
    _log("No SQLite or backup found, initializing new trial...");
    await startTrial();
  }

  // =============================
  // مساعدة لإعادة كتابة prefs من أي مصدر
  Future<void> _restorePrefsFromDb(Map<String, String> dbData) async {
    await _prefs.setString(_firstLaunchKey, dbData['date']!);
    await _prefs.setString(_hashKey, dbData['hash']!);
    await _prefs.setString(_deviceKey, dbData['deviceId']!);
  }

  // =============================
  // ✅ Remaining days
  // =============================
  Future<int> remainingDays() async {
    _ensureInit();

    // تحقق من الوقت والجهاز والتكامل
    await validateTime();
    await validateDevice();
    await validateIntegrity();

    final encoded = _prefs.getString(_firstLaunchKey)!;
    final startDate = _decodeDate(encoded);

    final duration = _prefs.getInt(_trialDurationKey) ?? _defaultTrialDays;
    final endDate = startDate.add(Duration(days: duration));

    // حساب الأيام المتبقية بدقة أكبر
    final now = DateTime.now().toUtc();
    final diff = endDate.difference(now);
    final remaining = diff.inSeconds > 0 ? (diff.inHours / 24).ceil() : 0;

    _log("Remaining days: $remaining");
    return remaining;
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
  Future<void> resetTrial({bool fullReset = false}) async {
    _ensureInit();

    // مسح cache فقط
    await _prefs.remove(_firstLaunchKey);
    await _prefs.remove(_hashKey);
    await _prefs.remove(_deviceKey);
    await _prefs.remove(_trialDurationKey);
    await _prefs.remove(_keyA);
    await _prefs.remove(_keyB);
    await _prefs.remove(_fakeKey);
    await _prefs.remove(_lastCheckKey);

    await _secureStorage.delete(key: _firstLaunchKey);

    if (fullReset) {
      // مسح SQLite لو fullReset = true
      final db = await _openDb();
      await db.delete('trial', where: 'id = ?', whereArgs: [1]);
      _log("Trial fully reset (prefs + SQLite) 🔄");
    } else {
      _log("Trial cache reset (prefs + secureStorage) 🔄 | SQLite preserved ✅");
    }
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

  // Future<void> validateIntegrity() async {
  //   final dbData = await _readFromDb();
  //   if (dbData != null) {
  //     // SQLite موجود → استخدامه
  //     await _restorePrefsFromDb(dbData);
  //     _log("Integrity check passed from SQLite ✅");
  //     return;
  //   }

  //   // لو SQLite مفقودة → محاولة استرجاع من secureStorage backup
  //   final backup = await _secureStorage.read(key: "trial_backup");
  //   if (backup != null) {
  //     final Map<String, dynamic> data = jsonDecode(backup);
  //     final hashValid = await _validateHash(
  //       data["date"],
  //       data["deviceId"],
  //       data["hash"],
  //     );
  //     if (!hashValid) throw Exception("⛔ Backup hash mismatch!");

  //     // إعادة إنشاء SQLite من backup
  //     await _saveToDb(data["date"], data["deviceId"], data["hash"]);
  //     await _restorePrefsFromDb(data.map((k, v) => MapEntry(k, v.toString())));
  //     _log("Integrity restored from secureStorage backup ✅");
  //     return;
  //   }

  //   // لا SQLite ولا backup → إنشاء trial جديد
  //   _log("No SQLite or backup found, initializing new trial...");
  //   await startTrial();
  // }

  // // مساعدة لإعادة كتابة prefs من أي مصدر
  // Future<void> _restorePrefsFromDb(Map<String, String> dbData) async {
  //   await _prefs.setString(_firstLaunchKey, dbData['date']!);
  //   await _prefs.setString(_hashKey, dbData['hash']!);
  //   await _prefs.setString(_deviceKey, dbData['deviceId']!);
  // }

  // // =============================
  // // ✅ Trial status map
  // // =============================
  // Future<Map<String, dynamic>> getTrialStatus() async {
  //   final expired = await isTrialExpired();
  //   final remaining = await remainingDays();
  //   final encoded = _prefs.getString(_firstLaunchKey);
  //   final firstLaunch = encoded != null ? _decodeDate(encoded) : null;

  //   return {
  //     "expired": expired,
  //     "remainingDays": remaining,
  //     "firstLaunch": firstLaunch?.toIso8601String(),
  //   };
  // }

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
