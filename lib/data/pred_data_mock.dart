import 'dart:async';
import './pred_data.dart';

class MockPredRepository implements PredictionRepository {
  @override
  Future<Prediction> fetchData(String imagePath, String question) {
    return Future.value(prediction);
  }
}

var prediction = Prediction(result: "stop");
