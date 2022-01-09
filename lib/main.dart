import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'moneye_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp(this.cameras);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moneye',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Moneye(cameras),
    );
  }
}
