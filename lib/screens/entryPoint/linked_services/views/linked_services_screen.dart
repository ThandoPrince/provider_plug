import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/get_provider_for_service_controller.dart';
import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProviderLinkedServicesScreen extends StatefulWidget {
  final String email;

  const ProviderLinkedServicesScreen({
    super.key,
    required this.email,
  });

  @override
  State<ProviderLinkedServicesScreen> createState() =>
      _ProviderLinkedServicesScreenState();
}

class _ProviderLinkedServicesScreenState
    extends State<ProviderLinkedServicesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetProviderForServiceController>().fetchProviderServices(
        widget.email,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  title: Text(
    'MY LINKED SERVICES',
    style: appStyle(
      14,
      Colors.white,
      FontWeight.bold,
    ).copyWith(letterSpacing: 1.5),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
      tooltip: 'Add service',
      onPressed: () {
        context.push(
          '/sp_select_a_service/${Uri.encodeComponent(widget.email)}',
        );
      },
    ),
  ],
),
        body: Consumer<GetProviderForServiceController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (controller.error != null && controller.error!.isNotEmpty) {
              return _buildStateView(
                icon: Icons.error_outline,
                message: controller.error!,
              );
            }

            if (controller.services.isEmpty) {
              return _buildStateView(
                icon: Icons.handyman_outlined,
                message: 'No linked services found.',
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchProviderServices(widget.email),
              color: Kolors.kPrimary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return _buildServiceCard(service);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(ProviderServiceModel item) {
    final bool isPrimary = item.isPrimary == true;

    final serviceName =
        item.service?.serviceName ??
        item.service?.serviceName ??
        'Unnamed Service';

    final serviceGroup =
         
        item.service?.serviceGroup?.name ??
        'No category';

    final costText = item.costOfService?.basePrice != null
        ? 'R${item.costOfService?.basePrice!.toStringAsFixed(2)}'
        : 'No price set';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? Kolors.kPrimary.withOpacity(0.8)
              : Colors.white.withOpacity(0.12),
          width: isPrimary ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Kolors.kPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPrimary ? Icons.star_rounded : Icons.build_circle_outlined,
                  color: isPrimary ? Colors.amberAccent : Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: appStyle(16, Colors.white, FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceGroup,
                      style: appStyle(12, Colors.white70, FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    'PRIMARY',
                    style: appStyle(10, Colors.amberAccent, FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: Icons.payments_outlined,
                label: 'Base Cost',
                value: costText,
                color: Colors.greenAccent,
              ),
              _buildInfoItem(
                icon: Icons.check_circle_outline,
                label: 'Status',
                value: 'Linked',
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: appStyle(10, Colors.white54, FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: appStyle(13, Colors.white, FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateView({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.white30),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: appStyle(14, Colors.white70, FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}