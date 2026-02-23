class TodaysSaleCardModel {
  final String status;
  final String message;
  final Payload payload;
  final int statusCode;

  TodaysSaleCardModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory TodaysSaleCardModel.fromJson(Map<String, dynamic> json) {
    return TodaysSaleCardModel(
      status: json['status'],
      message: json['message'],
      payload: Payload.fromJson(json['payload']),
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.toJson(),
      'statusCode': statusCode,
    };
  }
}

class Payload {
  final int availableStock;
  final int todayUnitsSold;
  final double todaySaleAmount;

  Payload({
    required this.availableStock,
    required this.todayUnitsSold,
    required this.todaySaleAmount,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      availableStock: json['availableStock'],
      todayUnitsSold: json['todayUnitsSold'],
      todaySaleAmount: (json['todaySaleAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableStock': availableStock,
      'todayUnitsSold': todayUnitsSold,
      'todaySaleAmount': todaySaleAmount,
    };
  }
}
