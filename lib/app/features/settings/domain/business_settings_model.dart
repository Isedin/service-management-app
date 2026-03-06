class BusinessSettings {
  final String businessId;

  final double carpetPricePerM2;
  final double runnerPricePerM2;
  final double stairPricePerPiece;
  final double blanketSmallPrice;
  final double blanketLargePrice;

  /// npr 0.10 = 10%
  final double dropoffDiscountRate;

  final String? contactPhone;
  final String? smsReadyTemplate;

  const BusinessSettings({
    required this.businessId,
    required this.carpetPricePerM2,
    required this.runnerPricePerM2,
    required this.stairPricePerPiece,
    required this.blanketSmallPrice,
    required this.blanketLargePrice,
    required this.dropoffDiscountRate,
    this.contactPhone,
    this.smsReadyTemplate,
  });

  factory BusinessSettings.fromMap(Map<String, dynamic> m) {
    double d(dynamic x) =>
        (x is num) ? x.toDouble() : double.tryParse('$x') ?? 0;

    return BusinessSettings(
      businessId: m['business_id'].toString(),
      carpetPricePerM2: d(m['carpet_price_per_m2']),
      runnerPricePerM2: d(m['runner_price_per_m2']),
      stairPricePerPiece: d(m['stair_price_per_piece']),
      blanketSmallPrice: d(m['blanket_small_price']),
      blanketLargePrice: d(m['blanket_large_price']),
      dropoffDiscountRate: d(m['dropoff_discount_rate']),
      contactPhone: (m['contact_phone'] as String?)?.trim().isEmpty == true
          ? null
          : m['contact_phone'] as String?,
      smsReadyTemplate:
          (m['sms_ready_template'] as String?)?.trim().isEmpty == true
          ? null
          : m['sms_ready_template'] as String?,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'carpet_price_per_m2': carpetPricePerM2,
      'runner_price_per_m2': runnerPricePerM2,
      'stair_price_per_piece': stairPricePerPiece,
      'blanket_small_price': blanketSmallPrice,
      'blanket_large_price': blanketLargePrice,
      'dropoff_discount_rate': dropoffDiscountRate,
      'contact_phone': contactPhone,
      'sms_ready_template': smsReadyTemplate,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
