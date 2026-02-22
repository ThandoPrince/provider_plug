import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_accept_negotiation_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiation_round_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_application_2/common/widgets/show_top_notification.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
// import 'package:flutter_application_2/screens/entryPoint/home/views/home_screen.dart'; // Unused import
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

class NegotiationBottomSheetContent extends StatefulWidget {
  final int orderId;
  final String providerEmail;

  const NegotiationBottomSheetContent({
    super.key,
    required this.orderId,
    required this.providerEmail,
  });

  @override
  State<NegotiationBottomSheetContent> createState() =>
      _NegotiationBottomSheetContentState();
}

class _NegotiationBottomSheetContentState
    extends State<NegotiationBottomSheetContent> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  List<NegotiationRound> _displayedRounds = [];
  int? _negotiationId;
  bool _isAccepted = false; // Internal state to manage UI after acceptance

  @override
  void initState() {
    super.initState();
    _fetchNegotiationId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _priceController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _fetchNegotiationId() {
    final key = '${widget.orderId}|${widget.providerEmail}';
    // Use read/listen: false here as this is called in initState
    final controller = Provider.of<SpNegotiationsByIdEmailCtrl>(
      context,
      listen: false,
    );

    try {
      final negotiations = controller.negotiations(key);
      if (negotiations.isNotEmpty) {
        // Check if the negotiation is already marked as accepted or completed
        if (negotiations.first.status == 'accepted') {
          _isAccepted = true;
        }
        setState(() => _negotiationId = negotiations.first.negotiationId);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching negotiation ID: $e');
    }
  }

  /// Only call insertItem for new rounds and use a post-frame callback
  void _updateRounds(List<NegotiationRound> newRounds) {
    if (newRounds.length > _displayedRounds.length) {
      final roundsToAdd = newRounds.skip(_displayedRounds.length).toList();

      // Update the main list state
      _displayedRounds.addAll(roundsToAdd);

      // Schedule the animation after the current frame build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listKey.currentState != null) {
          // Animate each new item
          for (int i = 0; i < roundsToAdd.length; i++) {
            _listKey.currentState!.insertItem(
              _displayedRounds.length - roundsToAdd.length + i,
              duration: const Duration(milliseconds: 300),
            );
          }
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    // Slight delay to ensure the list has finished inserting/building all new items
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(
    SpNegotiationRoundCtrl roundCtrl,
    SpNegotiationsByIdEmailCtrl negotiationsCtrl,
  ) async {
    if (_negotiationId == null) {
      showTopNotification(context, 'Negotiation ID not found.', isError: true);
      return;
    }

    final message = _messageController.text.trim();
    final priceText = _priceController.text.trim();
    final offeredPrice = double.tryParse(priceText);

    if (offeredPrice == null && message.isEmpty) return;

    if (priceText.isNotEmpty && offeredPrice == null) {
      showTopNotification(context, 'Invalid price format', isError: true);
      return;
    }

    _messageController.clear();
    _priceController.clear();
    FocusScope.of(context).unfocus();

    try {
      // 1️⃣ Send round
      await roundCtrl.startRound(
        negotiationId: _negotiationId!,
        providerEmail: widget.providerEmail,
        message: message.isEmpty ? null : message,
        offeredPrice: offeredPrice,
      );

      if (!mounted) {
        showTopNotification(context, 'Failed to send round', isError: true);
        return;
      }

      // 2️⃣ Fetch updated negotiation (FORCE refresh)
      await negotiationsCtrl.refreshNegotiations(
        orderId: widget.orderId,
        email: widget.providerEmail,
      );

      if (!mounted) return;

      // 3️⃣ Extract latest round
      final key = '${widget.orderId}|${widget.providerEmail}';
      final negotiations = negotiationsCtrl.negotiations(key);

      final latestRound = negotiations.expand((n) => n.rounds ?? []).lastOrNull;

      if (latestRound == null) return;

      // 4️⃣ Insert ONLY the new round (AnimatedList-safe)
      setState(() {
        _displayedRounds.add(latestRound);
        _listKey.currentState?.insertItem(
          _displayedRounds.length - 1,
          duration: const Duration(milliseconds: 300),
        );
      });

      // 5️⃣ Scroll to bottom
      _scrollToBottom();

      // 6️⃣ Feedback
      showTopNotification(context, 'Message sent');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send negotiation round: $e');
      }
      showTopNotification(
        context,
        'Failed to send negotiation round.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = '${widget.orderId}|${widget.providerEmail}';

    return Consumer<SpNegotiationsByIdEmailCtrl>(
      builder: (context, controller, _) {
        if (controller.isLoading(key)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error(key)?.isNotEmpty ?? false) {
          return Center(
            child: Text(
              controller.error(key)!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final negotiations = controller.negotiations(key);
        if (negotiations.isNotEmpty && _negotiationId == null) {
          _negotiationId = negotiations.first.negotiationId;
        }

        // Use the controller's latest status to determine acceptance state
        if (negotiations.isNotEmpty &&
            negotiations.first.status == 'accepted') {
          _isAccepted = true;
        }

        final allRounds = negotiations.expand((n) => n.rounds ?? []).toList();

        // Update local state and trigger AnimatedList inserts for new rounds
        _updateRounds(allRounds.cast<NegotiationRound>());

        // If no rounds exist, show the placeholder and the input area below it
        if (_displayedRounds.isEmpty) {
          return Column(
            children: [_buildPlaceholder(), _buildInputAndAcceptArea()],
          );
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  initialItemCount: _displayedRounds.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= _displayedRounds.length)
                      return const SizedBox.shrink();
                    final round = _displayedRounds[index];
                    return _buildAnimatedRound(round, animation);
                  },
                ),
              ),
            ),
            _buildInputAndAcceptArea(),
          ],
        );
      },
    );
  }

  // --- UI Building Widgets ---

  Widget _buildAnimatedRound(
    NegotiationRound round,
    Animation<double> animation,
  ) {
    // NOTE: Assuming 'provider' is the current user (SP)
    final isProvider = round.senderType == "provider";

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Align(
        alignment: isProvider ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: isProvider ? Colors.blue.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isProvider ? 16 : 4),
              bottomRight: Radius.circular(isProvider ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (round.message != null && round.message!.isNotEmpty)
                Text(round.message!, style: const TextStyle(fontSize: 15)),
              if (round.message != null && round.message!.isNotEmpty)
                const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    size: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    round.createdAt != null
                        ? DateFormat('HH:mm').format(round.createdAt!)
                        : 'N/A',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Start the Negotiation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Send your first price offer to begin the discussion.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Combined Input + Accept Button Area
  Widget _buildInputAndAcceptArea() {
    return Consumer2<SpNegotiationRoundCtrl, ProviderAcceptNegotiationCtrl>(
      builder: (context, roundCtrl, acceptCtrl, _) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final isNegotiationAccepted = _isAccepted;
        final lastSenderIsClient =
            _displayedRounds.isNotEmpty &&
            _displayedRounds.last.senderType == "client";
        final isFirstMessage = _displayedRounds.isEmpty;

        // Logic to control visibility of input/send/accept controls:
        final bool shouldShowControls =
            !isNegotiationAccepted && (isFirstMessage || lastSenderIsClient);

        // The Accept button requires controls to be shown AND a client offer with a price
        final bool shouldShowAccept =
            shouldShowControls &&
            _displayedRounds.isNotEmpty &&
            _displayedRounds.last.offeredPrice != null;

        if (!shouldShowControls) {
          // If the negotiation is accepted, show the disabled info bar
          if (isNegotiationAccepted) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Colors.green.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Negotiation Accepted. No further changes.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          
          return Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: bottomInset + 8,
              top: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Waiting for client reply...',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        // Build the input and accept buttons
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomInset + 8,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Accept Offer Button (Top row)
              if (shouldShowAccept)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                     onPressed: acceptCtrl.isLoading
    ? null
    : () async {
        if (_negotiationId == null || _isAccepted) return;

        try {
          setState(() => _isAccepted = true);

          await acceptCtrl.acceptNegotiation(_negotiationId!);

          if (!mounted) return;

          // 1️⃣ Show success message
          final flushbar = Flushbar(
            message: 'Negotiation accepted!',
            duration: const Duration(milliseconds: 1500),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(12),
            backgroundColor: Colors.green.shade700,
            flushbarPosition: FlushbarPosition.TOP,
          );
          await flushbar.show(context);

          if (!mounted) return;

          // 2️⃣ Go HOME (switch tab instead of popping)
          context.read<TabIndexNotifier>().setIndex(0);

          // 3️⃣ Optional: clear stacked routes if this screen was pushed
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);

        } catch (e) {
          setState(() => _isAccepted = false);

          if (kDebugMode) {
            print('❌ Accept failed: $e');
          }

          showTopNotification(
            context,
            'Failed to accept negotiation.',
            isError: true,
          );
        }
      },

                      child: acceptCtrl.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Accept R${_displayedRounds.last.offeredPrice?.toStringAsFixed(2) ?? '?'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

              // 2. Message + Price Input Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Price input
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Price',
                        labelText: 'R',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Message input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Message or optional notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  Container(
  decoration: BoxDecoration(
    color: roundCtrl.isLoading ? Colors.grey : Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  child: IconButton(
    icon: roundCtrl.isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(Icons.send, color: Colors.white),
    onPressed: roundCtrl.isLoading
        ? null
        : () async {
            final negotiationsCtrl =
                Provider.of<SpNegotiationsByIdEmailCtrl>(
              context,
              listen: false,
            );

            await _sendMessage(roundCtrl, negotiationsCtrl);
          },
  ),
)

                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
