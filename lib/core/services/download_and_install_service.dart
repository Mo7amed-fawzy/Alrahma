// lib/core/services/update_installer.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateInstaller {
  /// يُعيد مسار الملف بعد التحميل.
  /// onReceiveProgress: (received, total) => if total == 0 => indeterminate (total == -1)
  static Future<String> download(
    String url, {
    Function(int, int)? onReceiveProgress,
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
      // استخدم download مع callback للتقدم
      final response = await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (onReceiveProgress == null) return;
          // إذا السيرفر لم يحدد الطول نمرر total = -1 لتدل على indeterminate
          if (total == 0) {
            onReceiveProgress(received, -1);
          } else {
            onReceiveProgress(received, total);
          }
        },
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
        ),
      );

      final status = response.statusCode ?? 0;
      if (status != 200 && status != 206) {
        throw Exception("Download failed with status $status");
      }

      return savePath;
    } catch (e) {
      // احذف الملف الجزئي لو حصل خطأ
      try {
        final f = File(savePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      rethrow;
    }
  }

  /// يفتح ملف الـ APK ليبدأ التثبيت (على Android سيفتح صفحة التثبيت)
  static Future<void> install(String filePath) async {
    final f = File(filePath);
    if (!await f.exists()) {
      throw Exception("APK file not found: $filePath");
    }
    await OpenFilex.open(filePath);
  }
}
