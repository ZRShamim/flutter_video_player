import 'dart:developer';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
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

  double? aspectRatio;
  @override
  void initState() {
    videoController();
    super.initState();
  }

  videoController() async {
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
          "https://www.googleapis.com/drive/v3/files/12QWT-RUDW-m-hYb0wuzdXOtqBmssTqzE?alt=media&key=AIzaSyB_cNFR2Km1RdWkwkeyNo4HgINPguS0_LI"),
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
                  Downloader.downloadFile();
                } else {
                  log("Denied");
                }
              },
              child: const Text('Download'),
            )
          ],
        ),
      ),
    );
  }
}
