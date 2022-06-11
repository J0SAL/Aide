import 'dart:async';

class Prediction {
  late String result;
  Prediction({required this.result});
  Prediction.fromJson(Map json) : result = json['caption'];
}

abstract class PredictionRepository {
  Future<Prediction> fetchData(String imagePath, String question);
}

class FetchDataException implements Exception {
  final _message;
  FetchDataException([this._message]);
  String toString() {
    if (_message == null) return "Exception";
    return "Exception: $_message";
  }
}
