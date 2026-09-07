class TariffTier {
  final double minKwh;
  final double? maxKwh;
  final double pricePerKwh;
  final int tierOrder;

  const TariffTier({
    required this.minKwh,
    required this.maxKwh,
    required this.pricePerKwh,
    required this.tierOrder,
  });
}
