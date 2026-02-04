import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/client_models/clients_details.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';


class ClientInfoTile extends StatelessWidget {
  final ClientModel? client;

  const ClientInfoTile({super.key, required this.client});

  

  @override
  Widget build(BuildContext context) {
    final clientData = client;

    if (clientData == null) {
      return const SizedBox.shrink();
    }

  

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Theme(
        // This removes the default lines from ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Hero(
            tag: 'client_avatar_${clientData.fullName}',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Kolors.kPrimary.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Kolors.kOffWhite,
                backgroundImage: clientData.profileImageUrl != null
                    ? NetworkImage(clientData.profileImageUrl!)
                    : null,
                child: clientData.profileImageUrl == null
                    ? const Icon(Icons.person, color: Kolors.kPrimary)
                    : null,
              ),
            ),
          ),
          title: Text(
            clientData.fullName.isNotEmpty ? clientData.fullName : "Client Details",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Kolors.kDark,
              letterSpacing: -0.5,
            ),
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                clientData.rating ?? '0.0',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "• Client",
                style: TextStyle(color: Kolors.kDark.withOpacity(0.4), fontSize: 13),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            const Divider(height: 1, thickness: 1, color: Kolors.kOffWhite),
            const SizedBox(height: 16),

            
            // Modern "Call Client" Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // logic for: launchUrlString("tel:$clientPhone");
                },
                icon: const Icon(Icons.call_rounded, size: 18, color: Colors.white),
                label: const Text(
                  "CONTACT CLIENT",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}