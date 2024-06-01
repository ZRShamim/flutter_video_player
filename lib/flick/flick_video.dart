import 'dart:developer';
import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:videoplayer/download_file/download_file.dart';

class FlickVideo extends StatefulWidget {
  const FlickVideo({super.key});

  @override
  _FlickVideoState createState() => _FlickVideoState();
}

class _FlickVideoState extends State<FlickVideo> {
  late FlickManager flickManager;
  late VideoPlayerController videoPlayerController;
  String video_url =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  //String video_url = "https://www.googleapis.com/drive/v3/files/12QWT-RUDW-m-hYb0wuzdXOtqBmssTqzE?alt=media&key=AIzaSyB_cNFR2Km1RdWkwkeyNo4HgINPguS0_LI",

  double? aspectRatio;
  @override
  void initState() {
    videoController();
    super.initState();
  }

  videoController() async {
    final box = GetStorage();
    log(box.read('testvideo'));

    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        video_url,
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

  @override
  void dispose() {
    flickManager.dispose();
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
                  Downloader.downloadFile(
                    url: video_url,
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
