import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/get_provider_for_service_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/deactivate_provider_service_controller.dart';
import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_bottom_sheet.dart';
import 'package:flutter_application_2/common/widgets/app_confirmation_dialog.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_application_2/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/common/widgets/shimmers/linked_services_skeleton.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/select_service/views/select_a_service_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/views/linked_service_details_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProviderLinkedServicesScreen extends StatefulWidget {
  

  const ProviderLinkedServicesScreen({super.key});

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
      final controller = context.read<GetProviderForServiceController>();

      if (controller.services.isEmpty) {
        controller.fetchProviderServices();
      }
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
        appBar: CustomScreenAppBar(
          title: 'My Linked Services',
          actions: [
            IconButton(
  icon: const Icon(
    Icons.add_circle_outline,
    color: Colors.white,
  ),
  tooltip: 'Add service',
  onPressed: () async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectAServiceScreen(),
      ),
    );

    debugPrint("ProviderLinkedServicesScreen: result = $result");

    if (result == true && mounted) {
      context
          .read<GetProviderForServiceController>()
          .fetchProviderServices();
    }
  },
),
          ],
        ),
        body: Consumer<GetProviderForServiceController>(
          builder: (context, controller, _) {
            // Only show the skeleton on the true first load — a refresh
            // triggered by add/remove/pull-to-refresh already has cached
            // services, so the list stays up instead of flashing a loader.
            if (controller.isLoading && controller.services.isEmpty) {
              return const LinkedServicesSkeleton();
            }

            if (controller.error != null &&
                controller.error!.isNotEmpty &&
                controller.services.isEmpty) {
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
              onRefresh: () => controller.fetchProviderServices(),
              color: Colors.white,
              backgroundColor: Kolors.kPrimary,
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

    final serviceName = item.service?.serviceName ?? 'Unnamed Service';

    final serviceGroup = item.service?.serviceGroup?.name ?? 'No category';

    final costText = item.costOfService?.basePrice != null
        ? 'R${item.costOfService?.basePrice!.toStringAsFixed(2)}'
        : 'No price set';

       final affidavitStatus = item.isAffidavitVerified == true
    ? 'Verified'
    : item.hasUploadedAffidavit == true
        ? 'Pending Verification'
        : 'Not Uploaded';
        final affidavitColor = item.isAffidavitVerified == true
    ? Colors.green
    : item.hasUploadedAffidavit == true
        ? Colors.orange
        : Colors.red;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showServiceOptions(item),
        child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Kolors.kPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isPrimary
                          ? Icons.star_rounded
                          : Icons.build_circle_outlined,
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
                        style: appStyle(
                          10,
                          Colors.amberAccent,
                          FontWeight.bold,
                        ),
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
  icon: Icons.verified_user_outlined,
  label: 'Affidavit',
  value: affidavitStatus,
  color: affidavitColor,
),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showServiceOptions(ProviderServiceModel service) async {
    await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => AppBottomSheet(
    title: "Service Options",
    children: [
      ListTile(
        leading: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        title: const Text(
          "View service details",
          style: TextStyle(color: Colors.white),
        ),
        onTap: () async {
          Navigator.pop(context);

          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderServiceDetailsScreen(
                service: service,
              ),
            ),
          );

          if (updated == true && context.mounted) {
            await context
                .read<GetProviderForServiceController>()
                .fetchProviderServices();
          }
        },
      ),

      ListTile(
        leading: const Icon(
          Icons.delete_outline,
          color: Colors.redAccent,
        ),
        title: const Text(
          "Remove linked service",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          "This service will no longer be offered.",
          style: TextStyle(color: Colors.white54),
        ),
        onTap: () async {
          Navigator.pop(context);

          final confirm = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AppConfirmationDialog(
              icon: Icons.delete_forever_rounded,
              iconColor: Colors.redAccent,
              title: "Remove Service",
              message:
                  "Are you sure you want to remove '${service.service?.serviceName}'?\n\n"
                  "This service will no longer be offered to new customers.",
              confirmText: "Remove",
              confirmColor: Colors.red,
            ),
          );

          if (confirm != true || !context.mounted) return;

          final controller =
              context.read<DeactivateProviderServiceController>();

          final success = await controller.deactivateProviderService(
            providerServiceId: service.id!,
          );

          if (!context.mounted) return;

          if (success) {
            FlushbarService.success(
              context,
              "Linked service removed successfully.",
            );

            await context
                .read<GetProviderForServiceController>()
                .fetchProviderServices();
          } else {
            FlushbarService.error(
              context,
              controller.errorMessage ??
                  "Failed to remove linked service.",
            );
          }
        },
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

  Widget _buildStateView({required IconData icon, required String message}) {
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
