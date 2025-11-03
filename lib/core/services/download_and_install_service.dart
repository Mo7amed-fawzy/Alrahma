// lib/core/services/download_and_install_service.dart
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateInstaller {
  static Future<String> download(
    String url, {
    Function(int, int)? onReceiveProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    final savePath = "${dir!.path}/update.apk";

    final dio = Dio();

    await dio.download(url, savePath, onReceiveProgress: onReceiveProgress);

    return savePath;
  }

  static Future<void> install(String filePath) async {
    await OpenFilex.open(filePath);
  }
}
