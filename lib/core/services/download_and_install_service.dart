import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class UpdateInstaller {
  static const MethodChannel _channel = MethodChannel('alrahma/install_apk');

  /// تحميل APK مع تحقق SHA256 وخطأ واضح
  static Future<String> download(
    String url, {
    Function(int received, int total)? onReceiveProgress,
    String? expectedSha256,
  }) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null)
      throw Exception("Failed to get external storage directory");

    final savePath = "${dir.path}/update.apk";

    final dio = Dio(
      BaseOptions(
        followRedirects: true,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    try {
      final response = await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (onReceiveProgress != null) {
            final progress = total <= 0
                ? -1
                : (received / total).clamp(0.0, 1.0);
            onReceiveProgress(received, total);
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception("Download failed: ${response.statusCode}");
      }

      if (expectedSha256 != null && expectedSha256.isNotEmpty) {
        final file = File(savePath);
        final bytes = await file.readAsBytes();
        final digest = sha256.convert(bytes).toString();
        if (digest.toLowerCase() != expectedSha256.toLowerCase()) {
          await file.delete().catchError((_) {});
          throw Exception(
            "SHA256 mismatch. expected=$expectedSha256 got=$digest",
          );
        }
      }

      return savePath;
    } catch (e) {
      final f = File(savePath);
      if (await f.exists()) await f.delete();
      rethrow;
    }
  }

  /// تثبيت APK مع retry ودعم صلاحيات
  static Future<void> install(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception("APK file not found: $filePath");

    try {
      final canInstall =
          await _channel.invokeMethod<bool>('canRequestInstall') ?? true;
      if (!canInstall) {
        await _channel.invokeMethod('requestInstallPermission');
        throw PlatformException(
          code: 'INSTALL_PERMISSION_REQUIRED',
          message: 'User must enable install permission in settings',
        );
      }

      await _channel.invokeMethod('installApk', {'path': filePath});
    } on PlatformException catch (e) {
      if (e.code == 'INSTALL_PERMISSION_REQUIRED') throw e;
      // retry مرة واحدة إذا فشل
      try {
        await _channel.invokeMethod('installApk', {'path': filePath});
      } catch (e2) {
        throw Exception('Failed to start installer: $e2');
      }
    } catch (e) {
      throw Exception('Failed to start installer: $e');
    }
  }
}
