import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/pred_data.dart';
import 'package:translator/translator.dart';

class Result extends StatefulWidget {
  Prediction prediction;
  String imagePath;
  String question;
  Result(
      {Key? key,
      required this.prediction,
      required this.imagePath,
      required this.question})
      : super(key: key);
  @override
  State<Result> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<Result> {
  final FlutterTts fluttertts = FlutterTts();
  final translator = GoogleTranslator();
  var input = "";
  List<List> languages = <List>[
    ["English", "en"],
    ["Hindi", "hi"],
    ["Marathi", "mr"],
    ["French", "fr"],
    ["Spanish", "es"]
  ];

  Future<void> setLanguage() async {
    await fluttertts.setLanguage("en");
  }

  @override
  void initState() {
    super.initState();
    input = widget.prediction.result;
    speak(widget.prediction.result);
  }

  @override
  void dispose() {
    setLanguage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RESULTS',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Times New Roman',
              letterSpacing: 3.0),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                resultText(),
                imagePreview(),
                translateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  resultText() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (widget.question == "") ? "Caption: " : "Answer: ",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          Text(
            input,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(widget.imagePath),
        fit: BoxFit.cover, // Fixes border issues
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.4,
      ),
    );
  }

  translateButton() {
    return ElevatedButton(
      onPressed: () {
        showBottomSheet();
      },
      child: const Text('Change Language!'),
    );
  }

  backButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text('Go back!'),
    );
  }

  speak(String s) async {
    fluttertts.speak(s);
  }

  void trans(String lang) async {
    await fluttertts.setLanguage(lang);
    translator.translate(input, to: lang).then((result) => setState(() {
          input = result.toString();
          speak(result.toString());
        }));
  }

  showBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        context: context,
        builder: (context) {
          return CustomLangImgWidget(context,
              MediaQuery.of(context).size.height / 100, languages, trans);
        });
  }
}

class CustomLangImgWidget extends Container {
  final void Function(String) trans;
  CustomLangImgWidget(
      BuildContext context, double height, List<List> languages, this.trans,
      {Key? key})
      : super(
          key: key,
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          height: height * 30,
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var language in languages)
                  OutlinedButton(
                    onPressed: () {
                      trans(language[1]);
                      dismissDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(style: BorderStyle.none),
                    ),
                    child: Text(
                      language[0],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        );
}

dismissDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop('dialog');
}
