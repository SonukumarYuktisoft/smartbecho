// current_subscription_model.dart
import 'package:smartbecho/models/subscription%20models/subscription_models/subscription_history_model.dart';
import 'package:smartbecho/models/subscription%20models/subscription_models/user_subscription_model.dart';

class CurrentSubscriptionResponse {
  final String? status;
  final String? message;
  final List<UserSubscription>? payload;
  final int? statusCode;

  CurrentSubscriptionResponse({
    this.status,
    this.message,
    this.payload,
    this.statusCode,
  });

  factory CurrentSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionResponse(
      status: json['status'],
      message: json['message'],
      payload: json['payload'] != null
          ? (json['payload'] as List)
              .map((e) => UserSubscription.fromJson(e))
              .toList()
          : null,
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload?.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}