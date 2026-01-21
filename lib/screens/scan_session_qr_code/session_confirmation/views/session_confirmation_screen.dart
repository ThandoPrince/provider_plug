import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class SessionConfirmationScreen extends StatelessWidget {
  final String sessionToken;

  const SessionConfirmationScreen({
    super.key,
    required this.sessionToken,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Session"),
        backgroundColor: Kolors.kPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Session Check-in Successful",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "You are about to start a service session using a secure session token. "
              "Please review and confirm the details below before proceeding.",
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Text(
                "Session Token:\n$sessionToken",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Terms & Conditions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "• This session confirms the service provider has arrived.\n"
                  "• The session time will be tracked automatically.\n"
                  "• Any disputes must be raised within the session window.\n"
                  "• Cancelling after confirmation may affect refunds.\n",
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Kolors.kPrimary,
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text("Confirm Session"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
