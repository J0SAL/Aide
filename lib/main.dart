import 'package:flutter/material.dart';
import './pages/page1.dart';
import './pages/page2.dart';
import './dependency_injection.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';

void main() {
  Injector.configure(Flavor.PROD);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: defaultTargetPlatform == TargetPlatform.iOS
              ? Colors.grey[100]
              : null),
      home: Home(),
    );
  }
}
