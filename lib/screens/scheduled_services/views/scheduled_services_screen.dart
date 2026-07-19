import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scheduled_services/widgets/scheduled_header.dart';
import 'package:flutter_application_2/screens/scheduled_services/widgets/scheduled_orders_list.dart';
import 'package:provider/provider.dart';

class ScheduledOrdersScreen extends StatefulWidget {
  final int providerID;
  const ScheduledOrdersScreen({super.key, required this.providerID});

  @override
  State<ScheduledOrdersScreen> createState() => _ScheduledOrdersScreenState();
}

class _ScheduledOrdersScreenState extends State<ScheduledOrdersScreen> {
  late final ShipmentController _controller;
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    _controller = ShipmentController();
    _controller.fetchShipments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _controller.fetchShipments();
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta! > 0 && _showHeader) {
        setState(() => _showHeader = false);
      } else if (notification.scrollDelta! < 0 && !_showHeader) {
        setState(() => _showHeader = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Kolors.kPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [  Kolors.kPrimary, Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Consumer<ShipmentController>(
            builder: (context, ctrl, _) {
              if (ctrl.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (ctrl.errorMessage != null) {
                return Center(
                    child: Text(ctrl.errorMessage!,
                        style: const TextStyle(color: Colors.red)));
              }

              if (ctrl.shipments.isEmpty) {
                return const Center(
                  child: Text("No scheduled orders found.",
                      style: TextStyle(color: Colors.white70)),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  _onScroll(n);
                  return false;
                },
                child: Column(
                  children: [
                    ScheduledOrdersHeader(showHeader: _showHeader),
                    Expanded(
                      child: ScheduledOrdersList(
                        shipments: ctrl.shipments,
                        onRefresh: _refresh,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
