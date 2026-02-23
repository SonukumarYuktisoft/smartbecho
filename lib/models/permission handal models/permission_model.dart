
import 'dart:convert';

class PermissionResponseModel {
  final String status;
  final String message;
  final PermissionPayload? payload;
  final int statusCode;

  PermissionResponseModel({
    required this.status,
    required this.message,
    this.payload,
    required this.statusCode,
  });

  factory PermissionResponseModel.fromJson(Map<String, dynamic> json) {
    return PermissionResponseModel(
      status: json['status'] ?? 'FAILED',
      message: json['message'] ?? '',
      payload: json['payload'] != null
          ? PermissionPayload.fromJson(json['payload'])
          : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'payload': payload?.toJson(),
    'statusCode': statusCode,
  };
}

class PermissionPayload {
  final Map<String, String> features;
  final Map<String, String> sectionPermissions;

  PermissionPayload({
    required this.features,
    required this.sectionPermissions,
  });

  factory PermissionPayload.fromJson(Map<String, dynamic> json) {
    return PermissionPayload(
      features: Map<String, String>.from(json['features'] ?? {}),
      sectionPermissions: Map<String, String>.from(json['sectionPermissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'features': features,
    'sectionPermissions': sectionPermissions,
  };
}
