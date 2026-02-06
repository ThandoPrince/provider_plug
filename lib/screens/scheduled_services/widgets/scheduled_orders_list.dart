import 'package:flutter/material.dart';
import 'scheduled_order_card.dart';

class ScheduledOrdersList extends StatelessWidget {
  final List shipments;
  final Future<void> Function() onRefresh;

  const ScheduledOrdersList({
    super.key,
    required this.shipments,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          return ScheduledOrderCard(
            shipment: shipments[index],
            onRefresh: () => onRefresh(),
          );
        },
      ),
    );
  }
}
