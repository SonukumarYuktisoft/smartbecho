import 'package:intl/intl.dart';

String convertDateFormat(String inputDate) {
  final inputFormat = DateFormat('dd-MM-yyyy');
  final outputFormat = DateFormat('yyyy-MM-dd');
  final dateTime = inputFormat.parse(inputDate);
  return outputFormat.format(dateTime);
}
  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }


void printMapWithTypes(Map<String, dynamic> map) {
  map.forEach((key, value) {
    print('Key: $key, Value: $value, Type: ${value.runtimeType}');
  });
}

void printMapWithTypesAll(Map<String, dynamic> map, [String indent = '']) {
  map.forEach((key, value) {
    if (value is Map) {
      print('$indent$key: Map (${value.runtimeType})');
      printMapWithTypesAll(value.cast<String, dynamic>(), '$indent  ');
    } else if (value is List) {
      print('$indent$key: List (${value.runtimeType})');
      for (var i = 0; i < value.length; i++) {
        var item = value[i];
        if (item is Map) {
          print('$indent  [$i]: Map (${item.runtimeType})');
          printMapWithTypesAll(item.cast<String, dynamic>(), '$indent    ');
        } else {
          print('$indent  [$i]: $item (${item.runtimeType})');
        }
      }
    } else {
      print('$indent$key: $value (${value.runtimeType})');
    }
  });
}
