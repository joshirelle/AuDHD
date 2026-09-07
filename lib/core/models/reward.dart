class Reward {
  final String label;
  final int stars;
  final bool isCustom;

  /// Susi papunta sa `RewardIcons`. `null` sa pabuyang naitala bago pa
  /// magkaroon ng larawan — bituin ang ipinapakita noon.
  final String? iconKey;

  const Reward({
    required this.label,
    required this.stars,
    this.isCustom = false,
    this.iconKey,
  });
}
