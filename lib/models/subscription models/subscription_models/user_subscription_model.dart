
class UserSubscription {
  final int? id;
  final int? userId;
  final int? shopId;
  final String? planCode;
  final String? planNameSnapshot;
  final String? featuresSnapshot;
  final double? pricePaid;
  final String? paymentTxnId;
  final String? subscribedAt;
  final String? period;
  final String? startDate;
  final String? endDate;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;

  UserSubscription({
    this.id,
    this.userId,
    this.shopId,
    this.planCode,
    this.planNameSnapshot,
    this.featuresSnapshot,
    this.pricePaid,
    this.paymentTxnId,
    this.subscribedAt,
    this.period,
    this.startDate,
    this.endDate,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['userId'],
      shopId: json['shopId'],
      planCode: json['planCode'],
      planNameSnapshot: json['planNameSnapshot'],
      featuresSnapshot: json['featuresSnapshot'],
      pricePaid: json['pricePaid']?.toDouble(),
      paymentTxnId: json['paymentTxnId'],
      subscribedAt: json['subscribedAt'],
      period: json['period'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      active: json['active'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'planCode': planCode,
      'planNameSnapshot': planNameSnapshot,
      'featuresSnapshot': featuresSnapshot,
      'pricePaid': pricePaid,
      'paymentTxnId': paymentTxnId,
      'subscribedAt': subscribedAt,
      'period': period,
      'startDate': startDate,
      'endDate': endDate,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}