import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../modules/pred_presenter.dart';
import '../data/pred_data.dart';
import './page2.dart';
import 'camera_page.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> implements PredictionViewContract {
  String imagePath = "";
  String previewImg = "assets/preview.png";
  final ImagePicker _picker = ImagePicker();
  bool isValid = false;
  bool _isListening = false;
  late stt.SpeechToText _speech;
  bool _isLoading = false;

  late TextEditingController _controller;
  final FlutterTts fluttertts = FlutterTts();

  late PredDataPresenter _presenter;

  _Home() {
    _presenter = PredDataPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "AIDE",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Times New Roman',
              letterSpacing: 3.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: detailsWidget(),
    );
  }

  detailsWidget() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return GestureDetector(
      onDoubleTap: () => _listen(),
      onTap: () => _cameraScreen(),
      onLongPress: () => _submitData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 10.0, right: 10.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                heading(),
                imagePreview(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: captionInput(),
                      ),
                      const SizedBox(width: 10),
                      captionVoiceButton(),
                    ]),
                submitButton(),
              ]),
        ),
      ),
    );
  }

  heading() {
    return const Center(
      child: Text(
        "Upload Image",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          _cameraScreen();
        },
        splashColor: Colors.white10,
        child: (imagePath == "")
            ? Image.asset(
                previewImg,
                fit: BoxFit.cover, // Fixes border issues
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.4,
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover, // Fixes border issues
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
      ),
    );
  }

  captionInput() {
    return TextFormField(
      controller: _controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Ask Question',
        hintText: 'Ask Question',
      ),
    );
  }

  captionVoiceButton() {
    return FloatingActionButton(
      onPressed: _listen,
      child: Icon(_isListening ? Icons.mic : Icons.mic_none),
    );
  }

  submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          // fixedSize: Size(double.infinity, 50), // fromHeight use double.infinity as width and 40 is the height
          padding: const EdgeInsets.all(20.0),
          textStyle: const TextStyle(fontSize: 20)),
      onPressed: () => _submitData(),
      child: const Text('Submit'),
    );
  }

  _submitData() {
    _validate();
    if (isValid) {
      speak("submitting data");
      setState(() {
        _isLoading = true;
      });
      _presenter.getPrediction(imagePath, _controller.text);
    }
  }

  _validate() {
    if (imagePath == "") {
      speak("Please upload the image first");
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload the image first')));
    } else {
      isValid = true;
    }
  }

  _cameraScreen() async {
    speak("Opening Camera");
    List<CameraDescription> cameras = await availableCameras();
    var image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          cameras: cameras,
        ),
      ),
    );
    if (image == null) {
      setState(() => imagePath = "");
      speak("image not captured");
      return;
    }
    speak("image captured");
    setState(() {
      imagePath = image.path;
    });
  }

  _listen() async {
    if (!_isListening) {
      speak("Listening");
      setState(() => _isListening = true);
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      speak("Question Added");
    }
  }

  speak(String s) async {
    fluttertts.speak(s);
  }

  @override
  void onLoadPredComplete(Prediction prediction) {
    setState(() => _isLoading = false);
    // print("prediction: " + prediction.result);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Result(
              prediction: prediction,
              imagePath: imagePath,
              question: _controller.text)),
    );
  }

  @override
  void onLoadPredictionError() {}
}
