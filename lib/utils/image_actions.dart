import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

class ImageActions {
  static Future<void> downloadImage(String url) async {
    if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
      try {
        var response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
        final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: "OleksandrAI_${DateTime.now().millisecondsSinceEpoch}",
        );
        print(result);
      } catch (e) {
        print("Download error: $e");
      }
    }
  }

  static Future<void> viewInWeb(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
