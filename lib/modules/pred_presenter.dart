import '../data/pred_data.dart';
import '../dependency_injection.dart';

abstract class PredictionViewContract {
  void onLoadPredComplete(Prediction result);
  void onLoadPredictionError();
}

class PredDataPresenter {
  PredictionViewContract _view;
  PredictionRepository _repository;

  PredDataPresenter(this._view)
      : _repository = new Injector().predictionRepository;

  void getPrediction(String imagePath, String question) {
    _repository
        .fetchData(imagePath, question)
        .then((c) => _view.onLoadPredComplete(c))
        .catchError((onError) => _view.onLoadPredictionError());
  }
}
