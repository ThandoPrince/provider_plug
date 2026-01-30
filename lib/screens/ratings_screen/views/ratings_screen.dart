import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/update_ratings_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_2/screens/scheduled_services/views/scheduled_services_screen.dart';
import 'package:provider/provider.dart';

class RatingsScreen extends StatefulWidget {
  final String providerEmail;
  final int? sessionId;

  const RatingsScreen({super.key, required this.providerEmail, required this.sessionId});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  int _selectedScore = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RatingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Feedback", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        automaticallyImplyLeading: false, // 🚀 Removed back button
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // 1. Illustration/Icon Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Kolors.kSecondaryLight.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, size: 80, color: Colors.orange),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "How was your client?",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your feedback helps maintain a safe and\nprofessional community.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400, height: 1.5),
                      ),
                      const SizedBox(height: 40),

                      // 2. Star Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedScore = starIndex),
                            child: AnimatedScale(
                              scale: _selectedScore >= starIndex ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _selectedScore >= starIndex ? Icons.star_rounded : Icons.star_border_rounded,
                                color: _selectedScore >= starIndex ? Colors.orange : Colors.grey.shade300,
                                size: 48,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getRatingText(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Kolors.kPrimary),
                      ),
                      const SizedBox(height: 40),

                      // 3. Review TextField
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ADD A COMMENT (OPTIONAL)",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _reviewController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Tell us more about the experience...",
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Submit Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedScore == 0 ? Colors.grey.shade300 : Kolors.kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: controller.loading || _selectedScore == 0
                        ? null
                        : () async {
                            final success = await controller.submitRating(
                              sessionId: widget.sessionId.toString(),
                              providerEmail: widget.providerEmail,
                              score: _selectedScore,
                              review: _reviewController.text,
                            );

                            if (success && mounted) {
                              _showSuccessDialog();
                            }
                          },
                    child: controller.loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SUBMIT FEEDBACK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_selectedScore) {
      case 1: return "Terrible";
      case 2: return "Poor";
      case 3: return "Average";
      case 4: return "Very Good";
      case 5: return "Excellent!";
      default: return "Select a score";
    }
  }

 void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 16),
          const Text("Thank You!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text("Your rating has been submitted.", textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Kolors.kPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Close the dialog
                Navigator.of(context, rootNavigator: true).pop();

                // Navigate to EntryPoint Home tab
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ScheduledOrdersScreen(email: "nomfundomabunda748@gmail.com",)),
                  (route) => false,
                );

                // Optionally, you could also select the Home tab directly if using TabIndexNotifier:
                // final tabNotifier = context.read<TabIndexNotifier>();
                // tabNotifier.setIndex(0);
              },
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

}