import 'package:get/get.dart';
import 'package:smartbecho/controllers/poster generation controller/poster_generation_controller.dart';

class PosterGenerationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PosterController>(PosterController(), permanent: false);
  }
}
