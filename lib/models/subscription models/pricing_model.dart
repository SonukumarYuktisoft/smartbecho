class PricingPlan {
  final String id;
  final String name;
  final double priceMonthly;
  final double priceYearly;
  final bool isPopular;
  final List<PlanFeature> features;

  PricingPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.isPopular,
    required this.features,
  });
}

class PlanFeature {
  final String title;
  final bool enabled;

  PlanFeature({
    required this.title,
    required this.enabled,
  });
}
