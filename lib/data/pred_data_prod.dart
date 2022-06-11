import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import './pred_data.dart';

class ProdPredRepository implements PredictionRepository {
  String BASE_URL = "http://9f2a-35-227-86-159.ngrok.io";

  @override
  Future<Prediction> fetchData(String imagePath, String question) async {
    try {
      String fileName = imagePath.split('/').last;
      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath, filename: fileName),
        'question': question
      });
      String url;
      if (question == "") {
        url = BASE_URL + '/caption';
      } else {
        url = BASE_URL + '/vqa';
      }
      var dio = Dio();
      Response response = await dio.post(
        url,
        options: Options(contentType: 'multipart/form-data'),
        data: formData,
      );

      if (response.statusCode != 200) {
        throw FetchDataException(
            "An error ocurred : [Status Code : $response.statusCode]");
      }
      return Prediction.fromJson(response.data);
    } catch (e) {
      print(e);
      return Prediction.fromJson({'caption': 'Something Went Wrong'});
    }
  }
}
