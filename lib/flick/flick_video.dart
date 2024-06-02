import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class FlickVideo extends StatefulWidget {
  const FlickVideo({super.key});

  @override
  _FlickVideoState createState() => _FlickVideoState();
}

class _FlickVideoState extends State<FlickVideo> {
  late FlickManager flickManager;
  late VideoPlayerController videoPlayerController;
  String videoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  //String videoUrl = "https://www.googleapis.com/drive/v3/files/12QWT-RUDW-m-hYb0wuzdXOtqBmssTqzE?alt=media&key=AIzaSyB_cNFR2Km1RdWkwkeyNo4HgINPguS0_LI",

  String? taskId;
  final ReceivePort _port = ReceivePort();

  double? aspectRatio;
  @override
  void initState() {
    videoController();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        log("Download Complete");
      }

      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  videoController() async {
    final box = GetStorage();
    log(box.read('testvideo'));

    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        videoUrl,
      ),
    )..addListener(() {
        log(videoPlayerController.value.duration.toString());
        setState(() {
          aspectRatio = videoPlayerController.value.aspectRatio;
        });
        if (videoPlayerController.value.isCompleted) {
          // Play fb ads
          log("completed");
          log("playing Ads");
        } else if (!videoPlayerController.value.isPlaying) {
          // Play fb ads
          log("paused");
          log("play Ads Here");
        }
      });
    flickManager = FlickManager(
      videoPlayerController: videoPlayerController,
    );
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void dispose() {
    flickManager.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio ?? 5 / 3,
              child: FlickVideoPlayer(
                flickManager: flickManager,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                PermissionStatus status = await Permission.storage.request();
                if (status.isGranted) {
                  log('Downloading');
                  // Downloader.downloadFile(
                  //   url: videoUrl,
                  // );
                  final baseStorage = await getExternalStorageDirectory();
                  taskId = await FlutterDownloader.enqueue(
                    url: videoUrl,
                    headers: {}, // optional: header send with url (auth token etc)
                    savedDir: baseStorage!.path,
                    showNotification:
                        true, // show download progress in status bar (for Android)
                    openFileFromNotification:
                        true, // click on notification to open downloaded file (for Android)
                  );
                } else {
                  log("Denied");
                }
              },
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
