import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class UpdateInstaller {
  static const MethodChannel _channel = MethodChannel('alrahma/install_apk');

  static Future<String> download(
    String url, {
    Function(int received, int total)? onReceiveProgress,
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

      return savePath;
    } catch (e) {
      final f = File(savePath);
      if (await f.exists()) await f.delete();
      rethrow;
    }
  }

  /// Use native intent via MethodChannel to install the apk using FileProvider.
  static Future<void> install(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("APK file not found: $filePath");
    }
    try {
      await _channel.invokeMethod('installApk', {'path': filePath});
    } on PlatformException catch (e) {
      throw Exception('Failed to start installer: ${e.message}');
    }
  }
}
