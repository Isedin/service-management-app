class PricingHelper {
  static const double defaultPricePerM2 = 3.0;

  /// Round to 0.10 KM (10 feninga).
  static double round10(double km) {
    final fen = (km * 100).round();
    final rounded = ((fen + 5) ~/ 10) * 10; // nearest 10 fen
    return rounded / 100;
  }

  /// Billed m² derived from TOTAL (final truth).
  /// We derive m² that gives same total: m² * pricePerM2 = roundedTotal
  static double billedM2FromTotal({
    required double totalKm,
    required double pricePerM2,
  }) {
    final totalRounded = round10(totalKm);
    if (pricePerM2 <= 0) return 0;
    return totalRounded / pricePerM2;
  }

  static String km(double value) => "${round10(value).toStringAsFixed(2)} KM";
  static String m2(double value) => "${value.toStringAsFixed(2)} m²";
}
