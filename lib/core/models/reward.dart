class Reward {
  final String label;
  final int stars;
  final bool isCustom;

  const Reward({
    required this.label,
    required this.stars,
    this.isCustom = false,
  });
}
