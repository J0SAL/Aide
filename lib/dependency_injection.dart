import './data/pred_data.dart';
import './data/pred_data_mock.dart';
import './data/pred_data_prod.dart';

enum Flavor { MOCK, PROD }

//DI
class Injector {
  static final Injector _singleton = new Injector._internal();
  static Flavor? _flavor;

  static void configure(Flavor flavor) {
    _flavor = flavor;
  }

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  PredictionRepository get predictionRepository {
    switch (_flavor) {
      case Flavor.MOCK:
        return MockPredRepository();
      default:
        return ProdPredRepository();
    }
  }
}
