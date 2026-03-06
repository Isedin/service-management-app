// lib/app/features/orders/widgets/order_total_summary.dart
import 'package:flutter/material.dart';
import 'package:service_manegement_app/core/utils/pricing_helper.dart';

class OrderTotalSummary extends StatelessWidget {
  final double totalAmount;
  final double sumStair;
  final double sumBlanketSmall;
  final double sumBlanketLarge;

  /// runtime cijena po m²
  final double pricePerM2;

  const OrderTotalSummary({
    super.key,
    required this.totalAmount,
    required this.sumStair,
    required this.sumBlanketSmall,
    required this.sumBlanketLarge,
    required this.pricePerM2,
  });

  @override
  Widget build(BuildContext context) {
    final billedM2 = PricingHelper.billedM2FromTotal(
      totalKm: totalAmount,
      pricePerM2: pricePerM2,
    );

    Widget row(String left, String right, {bool bold = false}) {
      final style = TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left, style: style),
            Text(right, style: style),
          ],
        ),
      );
    }

    return Column(
      children: [
        row("Gazista", PricingHelper.km(sumStair)),
        row("Deke male", PricingHelper.km(sumBlanketSmall)),
        row("Deke velike", PricingHelper.km(sumBlanketLarge)),
        const Divider(height: 24),

        // Ovo je “kvadratura za račun”: m² * cijena = TOTAL
        row(
          "Kvadratura za račun",
          "${billedM2.toStringAsFixed(2)} m²",
          bold: true,
        ),
        row("Cijena po m²", "${pricePerM2.toStringAsFixed(2)} KM"),
        const Divider(height: 24),

        row("TOTAL", PricingHelper.km(totalAmount), bold: true),
      ],
    );
  }
}
