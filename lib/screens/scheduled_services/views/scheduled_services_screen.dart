import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/state_views.dart';
 // Add this import
import 'package:flutter_application_2/screens/scheduled_services/widgets/scheduled_header.dart';
import 'package:flutter_application_2/screens/scheduled_services/widgets/scheduled_orders_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduledOrdersScreen extends StatefulWidget {
  final int providerID;
  const ScheduledOrdersScreen({super.key, required this.providerID});

  @override
  State<ScheduledOrdersScreen> createState() => _ScheduledOrdersScreenState();
}

class _ScheduledOrdersScreenState extends State<ScheduledOrdersScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _showHeader = true;
  String _selectedFilter = "All";

  List<dynamic> _filteredShipments(List<dynamic> shipments) {
    if (_selectedFilter == "All") return shipments;
    final filterMap = {
      "Pending": "pending",
      "In Transit": "in_transit",
      "Arrived": "arrived",
      "In Session": "in_session",
      "Delivered": "delivered",
    };
    final selectedStatus = filterMap[_selectedFilter];
    return shipments.where((shipment) {
      return (shipment.shipmentStatus ?? "").toLowerCase() == selectedStatus;
    }).toList();
  }

  Future<void> _refresh(BuildContext context) async {
    await context.read<ShipmentController>().fetchShipments();
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
    super.build(context);
    final ctrl = context.watch<ShipmentController>();
    debugPrint("Scheduled ShipmentController: ${ctrl.hashCode}");

    final filteredShipments = _filteredShipments(ctrl.shipments);

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Kolors.kPrimary,
              Color(0xFF1A1A1A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            _onScroll(n);
            return false;
          },
          child: _buildBody(ctrl, filteredShipments),
        ),
      ),
    );
  }

  Widget _buildBody(ShipmentController ctrl, List<dynamic> filteredShipments) {
    Widget content;

    // Initial loading state
    if (ctrl.isLoading && ctrl.shipments.isEmpty) {
      content = _buildStateView(
        StateView.loading(
          message: 'Loading orders...',
          iconColor: Colors.white,
          textColor: Colors.white70,
          backgroundColor: Colors.transparent,
        ),
      );
    }
    // Error state
    else if (ctrl.errorMessage != null && ctrl.shipments.isEmpty) {
      content = _buildStateView(
        StateView.error(
          title: 'Error',
          message: ctrl.errorMessage!,
          onAction: () => _refresh(context),
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          iconColor: Colors.white,
          textColor: Colors.white,
          backgroundColor: Colors.transparent,
        ),
      );
    }
    // Empty state - no shipments at all
    else if (ctrl.shipments.isEmpty) {
      content = _buildStateView(
        StateView.empty(
          title: 'No Scheduled Orders',
          message: "You don't have any scheduled orders at the moment.",
          icon: Icons.event_note_outlined,
          onAction: () => _refresh(context),
          actionLabel: 'Refresh',
          actionIcon: Icons.refresh,
          iconColor: Colors.white24,
          textColor: Colors.white70,
          backgroundColor: Colors.transparent,
        ),
      );
    }
    // Filter empty state
    else if (filteredShipments.isEmpty) {
      content = _buildStateView(
        StateView.empty(
          title: 'No Matching Orders',
          message: 'No orders match the selected filter.',
          icon: Icons.filter_alt_off_outlined,
          iconColor: Colors.white10,
          textColor: Colors.white38,
          backgroundColor: Colors.transparent,
        ),
      );
    }
    // Success state
    else {
      content = ScheduledOrdersList(
        shipments: filteredShipments,
        onRefresh: () => _refresh(context),
      );
    }

    return Column(
      children: [
        ScheduledOrdersHeader(showHeader: _showHeader),
        const SizedBox(height: 8),
        _buildFilters(),
        const SizedBox(height: 8),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildStateView(Widget child) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      "All",
      "Pending",
      "In Transit",
      "Arrived",
      "In Session",
      "Delivered",
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter == _selectedFilter;
          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            selectedColor: Kolors.kPrimary,
            backgroundColor: Colors.white,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }
}