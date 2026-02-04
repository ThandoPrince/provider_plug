import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/client_models/client_address_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ScheduledAddressTile extends StatelessWidget {
  final ClientAddressModel? address;

  const ScheduledAddressTile({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Service Location",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Kolors.kDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.pin_drop, color: Kolors.kDark, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address?.formattedAddress ?? "Address N/A",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Kolors.kDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address?.locality ?? address?.route ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        color: Kolors.kDark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
