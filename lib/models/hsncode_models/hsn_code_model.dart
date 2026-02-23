class HsnResponseModel {
  final String status;
  final String message;
  final HsnPayload payload;
  final int statusCode;

  HsnResponseModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory HsnResponseModel.fromJson(Map<String, dynamic> json) {
    return HsnResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: HsnPayload.fromJson(json['payload']),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class HsnPayload {
  final List<HsnCodeModel> content;
  final Pageable pageable;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final int numberOfElements;
  final bool empty;

  HsnPayload({
    required this.content,
    required this.pageable,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  factory HsnPayload.fromJson(Map<String, dynamic> json) {
    return HsnPayload(
      content: (json['content'] as List)
          .map((e) => HsnCodeModel.fromJson(e))
          .toList(),
      pageable: Pageable.fromJson(json['pageable']),
      last: json['last'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      size: json['size'],
      number: json['number'],
      first: json['first'],
      numberOfElements: json['numberOfElements'],
      empty: json['empty'],
    );
  }
}

class HsnCodeModel {
  final int id;
  final String hsnCode;
  final String itemCategory;
  final String shopId;
  final double gstPercentage;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String? updatedBy;

  HsnCodeModel({
    required this.id,
    required this.hsnCode,
    required this.itemCategory,
    required this.shopId,
    required this.gstPercentage,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory HsnCodeModel.fromJson(Map<String, dynamic> json) {
    return HsnCodeModel(
      id: json['id'],
      hsnCode: json['hsnCode'] ?? '',
      itemCategory: json['itemCategory'] ?? '',
      shopId: json['shopId'] ?? '',
      gstPercentage: (json['gstPercentage'] as num).toDouble(),
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'],
    );
  }
}
class Pageable {
  final int pageNumber;
  final int pageSize;
  final Sort sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      sort: Sort.fromJson(json['sort']),
      offset: json['offset'],
      paged: json['paged'],
      unpaged: json['unpaged'],
    );
  }
}
class Sort {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  Sort({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sorted: json['sorted'],
      empty: json['empty'],
      unsorted: json['unsorted'],
    );
  }
}
