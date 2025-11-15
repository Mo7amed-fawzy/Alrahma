import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class UpdateInstaller {
  static const MethodChannel _channel = MethodChannel('alrahma/install_apk');

  static Future<String> download(
    String url, {
    Function(int received, int total)? onReceiveProgress,
    String? expectedSha256,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
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
            if (total == 0) {
              onReceiveProgress(received, -1);
            } else {
              onReceiveProgress(received, total);
            }
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

  /// طلب التثبيت
  /// Throws:
  ///  - PlatformException with code 'INSTALL_PERMISSION_REQUIRED' if user must enable install-permission
  ///  - PlatformException with code 'INSTALL_ERROR' for other native errors
  static Future<void> install(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("APK file not found: $filePath");
    }

    try {
      // check if we can request installs
      final canInstall =
          await _channel.invokeMethod<bool>('canRequestInstall') ?? true;
      if (!canInstall) {
        // open settings to allow user to grant permission
        await _channel.invokeMethod('requestInstallPermission');
        // throw so caller can show a friendly UI to user to try again after enabling
        throw PlatformException(
          code: 'INSTALL_PERMISSION_REQUIRED',
          message: 'User must enable install permission in settings',
        );
      }

      await _channel.invokeMethod('installApk', {'path': filePath});
    } on PlatformException catch (e) {
      // rethrow to let caller handle different cases
      rethrow;
    } catch (e) {
      throw Exception('Failed to start installer: $e');
    }
  }
}
