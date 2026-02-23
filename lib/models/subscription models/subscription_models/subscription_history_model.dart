// subscription_history_model.dart
import 'package:smartbecho/models/subscription%20models/subscription_models/user_subscription_model.dart';

class SubscriptionHistoryResponse {
  final String? status;
  final String? message;
  final HistoryPayload? payload;
  final int? statusCode;

  SubscriptionHistoryResponse({
    this.status,
    this.message,
    this.payload,
    this.statusCode,
  });

  factory SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryResponse(
      status: json['status'],
      message: json['message'],
      payload: json['payload'] != null
          ? HistoryPayload.fromJson(json['payload'])
          : null,
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload?.toJson(),
      'statusCode': statusCode,
    };
  }
}

class HistoryPayload {
  final List<UserSubscription>? content;
  final Pageable? pageable;
  final bool? last;
  final int? totalElements;
  final int? totalPages;
  final int? size;
  final int? number;
  final Sort? sort;
  final bool? first;
  final int? numberOfElements;
  final bool? empty;

  HistoryPayload({
    this.content,
    this.pageable,
    this.last,
    this.totalElements,
    this.totalPages,
    this.size,
    this.number,
    this.sort,
    this.first,
    this.numberOfElements,
    this.empty,
  });

  factory HistoryPayload.fromJson(Map<String, dynamic> json) {
    return HistoryPayload(
      content: json['content'] != null
          ? (json['content'] as List)
              .map((e) => UserSubscription.fromJson(e))
              .toList()
          : null,
      pageable: json['pageable'] != null
          ? Pageable.fromJson(json['pageable'])
          : null,
      last: json['last'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      size: json['size'],
      number: json['number'],
      sort: json['sort'] != null ? Sort.fromJson(json['sort']) : null,
      first: json['first'],
      numberOfElements: json['numberOfElements'],
      empty: json['empty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content?.map((e) => e.toJson()).toList(),
      'pageable': pageable?.toJson(),
      'last': last,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'size': size,
      'number': number,
      'sort': sort?.toJson(),
      'first': first,
      'numberOfElements': numberOfElements,
      'empty': empty,
    };
  }
}

class Pageable {
  final int? pageNumber;
  final int? pageSize;
  final Sort? sort;
  final int? offset;
  final bool? paged;
  final bool? unpaged;

  Pageable({
    this.pageNumber,
    this.pageSize,
    this.sort,
    this.offset,
    this.paged,
    this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      sort: json['sort'] != null ? Sort.fromJson(json['sort']) : null,
      offset: json['offset'],
      paged: json['paged'],
      unpaged: json['unpaged'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sort': sort?.toJson(),
      'offset': offset,
      'paged': paged,
      'unpaged': unpaged,
    };
  }
}

class Sort {
  final bool? sorted;
  final bool? empty;
  final bool? unsorted;

  Sort({
    this.sorted,
    this.empty,
    this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sorted: json['sorted'],
      empty: json['empty'],
      unsorted: json['unsorted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sorted': sorted,
      'empty': empty,
      'unsorted': unsorted,
    };
  }
}