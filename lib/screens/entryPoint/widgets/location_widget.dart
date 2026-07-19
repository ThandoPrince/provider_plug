import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_active_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:provider/provider.dart';

class ProviderActiveToggle extends StatefulWidget {
  

  const ProviderActiveToggle({
    super.key,
    
  });

  @override
  State<ProviderActiveToggle> createState() => _ProviderActiveToggleState();
}

class _ProviderActiveToggleState extends State<ProviderActiveToggle> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialStatus();
    });

    
    
  }

  Future<void> _loadInitialStatus() async {
    final spCtrl = context.read<SpProfileCtrl>();
    final activeCtrl = context.read<ProviderActiveController>();

    await spCtrl.fetchSPByEmail();

    final profile = spCtrl.spProfile;
    if (profile != null) {
      activeCtrl.setInitialStatus(profile.isActive);
    }

    if (!mounted) return;

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderActiveController>(
      builder: (context, controller, _) {
        if (!_initialized) {
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

        final isActive = controller.isActive;

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
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        final success =
                            await controller.toggleActive();

                        if (!context.mounted) return;

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                controller.message ?? "Failed to update status",
                              ),
                            ),
                          );
                        }
                      },
                child: controller.isLoading
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
      },
    );
  }
}