import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/client_models/clients_details.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ClientInfoTile extends StatelessWidget {
  final ClientModel? client;

  const ClientInfoTile({super.key, required this.client});

  /// Helper to build labeled detail rows with icons
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Kolors.kPrimary),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Kolors.kDark,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Kolors.kDark.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safe null handling
    final clientData = client;

    if (clientData == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Client information not available"),
      );
    }

    final clientEmail = clientData.clientProfile?.emailAddress ?? "Not provided";
    final clientPhone = clientData.clientProfile?.mobileNumber ?? "Not provided";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Kolors.kPrimary.withOpacity(0.2), width: 1),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: Kolors.kPrimary,
            collapsedIconColor: Kolors.kPrimary,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,

            // Avatar
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Kolors.kPrimary.withOpacity(0.15),
              backgroundImage: clientData.profileImageUrl != null
                  ? NetworkImage(clientData.profileImageUrl!)
                  : null,
              child: clientData.profileImageUrl == null
                  ? const Icon(Icons.person, color: Kolors.kPrimary, size: 28)
                  : null,
            ),

            // Title
            title: Text(
              clientData.fullName.isNotEmpty ? clientData.fullName : "Client Details",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Kolors.kDark,
              ),
            ),

            // Subtitle
            subtitle: Text(
              "Rating: ${clientData.rating ?? '0.0'} ⭐",
              style: TextStyle(
                color: Kolors.kPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),

            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Divider(height: 20, color: Kolors.kOffWhite, thickness: 1.5),

              const Text(
                "Contact Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Kolors.kDark,
                ),
              ),
              const SizedBox(height: 8),

              _buildDetailRow("Full Name", clientData.fullName.isNotEmpty ? clientData.fullName : "N/A", Icons.person_outline),
              _buildDetailRow("Email", clientEmail, Icons.email_outlined),
              _buildDetailRow("Phone", clientPhone, Icons.phone_outlined),

              const SizedBox(height: 10),

              _buildDetailRow("Average Rating", "${clientData.rating ?? '0.00'} / 5.0", Icons.star_border),
            ],
          ),
        ),
      ),
    );
  }
}
