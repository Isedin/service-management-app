// lib/app/features/orders/widgets/carpet_item_row.dart
import 'package:flutter/material.dart';
import 'package:service_manegement_app/core/utils/pricing_helper.dart';

class CarpetItemRow extends StatelessWidget {
  const CarpetItemRow({
    super.key,
    required this.lengthM,
    required this.widthM,
    required this.lineTotal,
    required this.pricePerM2,
    required this.onTap,
  });

  final num lengthM;
  final num widthM;
  final num lineTotal;
  final double pricePerM2;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lCm = (lengthM * 100).round();
    final wCm = (widthM * 100).round();

    final total = lineTotal.toDouble();

    final billedM2 = PricingHelper.billedM2FromTotal(
      totalKm: total,
      pricePerM2: pricePerM2,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(flex: 4, child: Text("$wCm x $lCm cm")),
            Expanded(
              flex: 3,
              child: Text(
                billedM2.toStringAsFixed(2),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(PricingHelper.km(total), textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}
