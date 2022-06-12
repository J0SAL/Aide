import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:volume_controller/volume_controller.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras![0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    VolumeController().listener((volume) {
      _captureImage();
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return GestureDetector(
      onTap: () => _captureImage(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            child: CameraPreview(controller),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: Text("Capture Image"),
            onPressed: () => _captureImage(),
          ),
        ],
      ),
    );
  }

  _captureImage() async {
    print("capturing image");
    var pictureFile = await controller.takePicture();
    Navigator.pop(context, pictureFile);
  }
}
