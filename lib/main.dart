import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:videoplayer/flick/flick_video.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black54, // navigation bar color
      statusBarColor: Colors.black54, // status bar color
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your app name',
      home: FlickVideo(),
    );
  }
}
