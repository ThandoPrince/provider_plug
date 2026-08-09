import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_active_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:provider/provider.dart';

class ProviderActiveToggle extends StatelessWidget {
  const ProviderActiveToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final profileCtrl = context.watch<SpProfileCtrl>();
    final activeCtrl = context.watch<ProviderActiveController>();

    if (profileCtrl.isLoading || profileCtrl.spProfile == null) {
      return const Padding(
        padding: EdgeInsets.only(right: 12),
        child: SizedBox(
          width: 90,
          height: 38,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // Initialize only once.
    if (!activeCtrl.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        activeCtrl.setInitialStatus(
          profileCtrl.spProfile!.isActive,
        );
      });
    }

    final isActive = activeCtrl.isActive;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: SizedBox(
          height: 38,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(90, 38),
              backgroundColor:
                  isActive ? Colors.green : Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: activeCtrl.isLoading
                ? null
                : () async {
                    final success = await activeCtrl.toggleActive();

                    if (!context.mounted) return;

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            activeCtrl.message ??
                                "Failed to update status",
                          ),
                        ),
                      );
                    }
                  },
            child: activeCtrl.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? "ONLINE" : "OFFLINE",
                        style: const TextStyle(
                          color: Kolors.kOffWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}