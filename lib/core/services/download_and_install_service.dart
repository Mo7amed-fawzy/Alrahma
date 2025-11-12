import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateInstaller {
  /// يعيد مسار الملف بعد التحميل
  static Future<String> download(
    String url, {
    Function(int, int)? onReceiveProgress,
  }) async {
    // استخدم application documents directory للحصول على مسار يمكن الكتابة فيه بدون صلاحيات اضافية
    final dir = await getApplicationDocumentsDirectory();
    final savePath = "${dir.path}/update.apk";

    final dio = Dio(
      BaseOptions(
        followRedirects: true,
        connectTimeout: Duration(milliseconds: 60 * 1000),
        receiveTimeout: Duration(milliseconds: 60 * 1000),
      ),
    );

    // تأكد من التعامل مع الاستثناءات
    final response = await dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw Exception("Download failed with status ${response.statusCode}");
    }

    return savePath;
  }

  /// يفتح ملف الـ APK ليبدأ التثبيت (على Android سيفتح صفحة التثبيت)
  static Future<void> install(String filePath) async {
    if (!File(filePath).existsSync()) {
      throw Exception("APK file not found: $filePath");
    }
    await OpenFilex.open(filePath);
  }
}
