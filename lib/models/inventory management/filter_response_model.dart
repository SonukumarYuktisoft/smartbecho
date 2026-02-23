class FilterResponse {
  final List<String> companies;
  final List<String> models;
  final List<String> rams;
  final List<String> roms;
  final List<String> colors;
  final List<String> itemCategories;

  FilterResponse({
    required this.companies,
    required this.models,
    required this.rams,
    required this.roms,
    required this.colors,
    required this.itemCategories,
  });

  factory FilterResponse.fromJson(Map<String, dynamic> json) {
    return FilterResponse(
      companies: List<String>.from(json['companies'] ?? []),
      models: List<String>.from(json['models'] ?? []),
      rams: List<String>.from(json['rams'] ?? []),
      roms: List<String>.from(json['roms'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      itemCategories: List<String>.from(json['itemCategories'] ?? []),
    );
  }
}