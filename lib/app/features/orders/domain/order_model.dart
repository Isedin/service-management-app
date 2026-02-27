class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String status;
  final bool isPaid;

  final int plannedCarpetCount;
  final int measuredCarpetCount;
  final bool isFullyMeasured;

  final double totalAmount;

  final String mode; // dropoff | pickup_delivery

  final int plannedStairCount;
  final int plannedBlanketSmallCount;
  final int plannedBlanketLargeCount;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.isPaid,
    required this.plannedCarpetCount,
    required this.measuredCarpetCount,
    required this.isFullyMeasured,
    required this.totalAmount,
    required this.mode,
    required this.plannedStairCount,
    required this.plannedBlanketSmallCount,
    required this.plannedBlanketLargeCount,
  });

  factory OrderModel.fromMap(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return OrderModel(
      id: json['id'] as String,
      customerName: (json['customer_name'] ?? '') as String,
      customerPhone: (json['customer_phone'] ?? '') as String,
      status: (json['status'] ?? 'received') as String,
      isPaid: (json['is_paid'] ?? false) as bool,
      plannedCarpetCount: toInt(json['planned_carpet_count']),
      measuredCarpetCount: toInt(json['measured_carpet_count']),
      isFullyMeasured: (json['is_fully_measured'] ?? false) as bool,
      totalAmount: toDouble(json['total_amount']),
      mode: (json['mode'] ?? 'dropoff') as String,
      plannedStairCount: toInt(json['planned_stair_count']),
      plannedBlanketSmallCount: toInt(json['planned_blanket_small_count']),
      plannedBlanketLargeCount: toInt(json['planned_blanket_large_count']),
    );
  }
}
