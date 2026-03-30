import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/bookings/update_ratings_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_2/screens/entryPoint/views/entry_point.dart';
import 'package:provider/provider.dart';

class RatingsScreen extends StatefulWidget {
  final String providerEmail;
  final int? sessionId;
  final SessionModel session;

  const RatingsScreen({
    super.key,
    required this.providerEmail,
    required this.sessionId,
    required this.session,
  });

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  int _selectedScore = 0;
  final TextEditingController _reviewController = TextEditingController();

  // ------------------- PRICE BREAKDOWN (GLASS-MORPHIC) -------------------
  Widget _buildPriceBreakdown() {
    final order = widget.session.shipment?.serviceOrdered?.order;
    final double serviceFee = order?.finalPrice ?? 0.0;
    final double total = serviceFee; // Simplified for this view

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2), // Transparent glass effect
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SESSION SUMMARY",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: Kolors.kPrimary.withOpacity(0.8),
                ),
              ),
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          _buildPriceRow("Gross Earnings", serviceFee),
          const SizedBox(height: 12),
          _buildPriceRow("Service Commission", 0.0, isDiscount: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ),
          _buildPriceRow("Final Payout", total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            fontSize: isTotal ? 16 : 13,
            color: isTotal ? Colors.white : Colors.white60,
          ),
        ),
        Text(
          "R ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            fontSize: isTotal ? 24 : 14,
            color: isTotal ? Colors.white : (isDiscount ? Colors.greenAccent : Colors.white70),
          ),
        ),
      ],
    );
  }

  String _getRatingText() {
    switch (_selectedScore) {
      case 1: return "Terrible";
      case 2: return "Poor";
      case 3: return "Average";
      case 4: return "Very Good";
      case 5: return "Excellent!";
      default: return "Rate the client";
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RatingController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Nav since AppBar background is tricky with gradients
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "JOB COMPLETE",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontSize: 12,
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildPriceBreakdown(),
                      const SizedBox(height: 20),
                      const Text(
                        "How was the client?",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w200, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getRatingText().toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900, 
                          color: Colors.white, 
                          letterSpacing: 1.5,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // ---------- GLOWING STAR RATING ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          final isSelected = _selectedScore >= starIndex;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              setState(() => _selectedScore = starIndex);
                            },
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 1.0 : 0.2,
                              child: Icon(
                                Icons.star_rounded,
                                color: isSelected ? Colors.white : Colors.white,
                                size: 56,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 50),

                      // ---------- DARK INPUT FIELD ----------
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "OPTIONAL COMMENTS",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _reviewController,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Share your experience...",
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- NEON SUBMIT BUTTON ----------
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedScore == 0 ? Colors.white.withOpacity(0.1) : Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                              _showSuccessDialog(); // Same as previous implementation
                            }
                          },
                    child: controller.loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            "SUBMIT & CLOSE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              letterSpacing: 1.5,
                              color: _selectedScore == 0 ? Kolors.kPrimary : Kolors.kOffWhite
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reuse the previous _showSuccessDialog but with _dkCard color
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Kolors.kPrimary, size: 60),
              const SizedBox(height: 24),
              const Text("Well Done!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    context.read<TabIndexNotifier>().setIndex(0);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const EntryPoint()),
                      (route) => false,
                    );
                },
                child: const Text("FINISH"),
              )
            ],
          ),
        ),
      ),
    );
  }
}