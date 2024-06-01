import 'dart:developer';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class Downloader {
  static void downloadFile({
    required String url,
    String filename = 'TestFile',
  }) async {
    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request);

    final appDocDirectory = await _getAppDocDirectory();

    final finalVideoPath = '${appDocDirectory.path}/$filename.mp4';

    List<List<int>> chunks = [];
    int downloaded = 0;

    response.asStream().listen(
      (http.StreamedResponse r) {
        r.stream.listen(
          (List<int> chunk) {
            // Display percentage of completion
            debugPrint(
                'downloadPercentage: ${downloaded / r.contentLength! * 100}');

            chunks.add(chunk);
            downloaded += chunk.length;
          },
          onDone: () async {
            // Display percentage of completion
            debugPrint(
                'downloadPercentage: ${downloaded / r.contentLength! * 100}');

            // Save the file in local
            File file = File(finalVideoPath);
            final Uint8List bytes = Uint8List(r.contentLength!);
            int offset = 0;
            for (List<int> chunk in chunks) {
              bytes.setRange(offset, offset + chunk.length, chunk);
              offset += chunk.length;
            }
            await file.writeAsBytes(bytes);
            // Save the file in gallery
            await saveDownloadedVideoToGallery(videoPath: finalVideoPath);
            // remove the file in local
            await removeDownloadedVideo(videoPath: finalVideoPath);
            return;
          },
        );
      },
    );
  }

  static Future<void> saveDownloadedVideoToGallery(
      {required String videoPath}) async {
    var res = await ImageGallerySaver.saveFile(videoPath, name: "test");
    log(res.toString());
    final box = GetStorage();

    String path =
        res['filePath'].toString().replaceAll(RegExp('content://'), '');
    box.write('testvideo', path);
  }

  static Future<void> removeDownloadedVideo({required String videoPath}) async {
    try {
      Directory(videoPath).deleteSync(recursive: true);
    } catch (error) {
      debugPrint('$error');
    }
  }

  static Future<Directory> _getAppDocDirectory() async {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }

    return (await getExternalStorageDirectory())!;
  }
}
