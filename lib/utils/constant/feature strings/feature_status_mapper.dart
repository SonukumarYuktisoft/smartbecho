import 'package:smartbecho/utils/constant/feature%20strings/feature_status.dart';

FeatureStatus mapFeatureStatus(String? value) {
  switch (value) {
    case 'ALLOWED':
      return FeatureStatus.allowed;
    case 'LOCKED':
      return FeatureStatus.locked;
    default:
      return FeatureStatus.unauthorized;
  }
}
