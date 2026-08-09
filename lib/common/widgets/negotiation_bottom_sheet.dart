import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_accept_negotiation_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiation_round_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/shimmers/negotiation_chat_skeleton.dart';
import 'package:flutter_application_2/common/widgets/show_top_notification.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

class NegotiationBottomSheetContent extends StatefulWidget {
  final int orderId;

  const NegotiationBottomSheetContent({super.key, required this.orderId});

  @override
  State<NegotiationBottomSheetContent> createState() =>
      _NegotiationBottomSheetContentState();
}

class _NegotiationBottomSheetContentState
    extends State<NegotiationBottomSheetContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  int? _negotiationId;

  /// Optimistic flag so the "Accepted" UI shows the instant the button is
  /// tapped, instead of waiting for the network round trip.
  bool _optimisticAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNegotiationId();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _priceController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchNegotiationId() async {
    final controller = context.read<SpNegotiationsByIdEmailCtrl>();

    await controller.loadNegotiations(orderId: widget.orderId);

    if (!mounted) return;

    final negotiations = controller.negotiations('${widget.orderId}');
    if (negotiations.isEmpty) return;

    setState(() {
      _negotiationId = negotiations.first.negotiationId;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Optimistic send: the bubble appears immediately (WhatsApp-style),
  /// then reconciles with the server in the background.
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

    // 1. Show the bubble instantly — no await before this point.
    final tempId = roundCtrl.addPendingRound(
      negotiationId: _negotiationId!,
      message: message.isEmpty ? null : message,
      offeredPrice: offeredPrice,
    );
    _scrollToBottom();

    // 2. Fire the request in the background and reconcile after.
    final success = await roundCtrl.sendRound(
      negotiationId: _negotiationId!,
      tempId: tempId,
      message: message.isEmpty ? null : message,
      offeredPrice: offeredPrice,
    );

    if (!mounted) return;

    if (success) {
      // Silent refresh — no spinner over the list, just swaps the temp
      // bubble for the confirmed one.
      await negotiationsCtrl.refreshNegotiations(orderId: widget.orderId);
    } else {
      // Bubble is now flagged "failed" by the controller — let the user
      // retry by tapping it instead of a generic toast-only failure.
      showTopNotification(
        context,
        'Failed to send negotiation round. Tap the message to retry.',
        isError: true,
      );
    }
  }

  Future<void> _retryPendingRound(
    NegotiationRound pending,
    SpNegotiationRoundCtrl roundCtrl,
    SpNegotiationsByIdEmailCtrl negotiationsCtrl,
  ) async {
    if (_negotiationId == null || pending.localId == null) return;

    final success = await roundCtrl.sendRound(
      negotiationId: _negotiationId!,
      tempId: pending.localId!,
      message: pending.message,
      offeredPrice: pending.offeredPrice,
    );

    if (!mounted) return;

    if (success) {
      await negotiationsCtrl.refreshNegotiations(orderId: widget.orderId);
    } else {
      showTopNotification(context, 'Still failed to send.', isError: true);
    }
  }

  void _discardPendingRound(NegotiationRound pending, SpNegotiationRoundCtrl roundCtrl) {
    if (_negotiationId == null || pending.localId == null) return;
    roundCtrl.removePendingRound(_negotiationId!, pending.localId!);
  }

  @override
  Widget build(BuildContext context) {
    final key = '${widget.orderId}';

    return Consumer2<SpNegotiationsByIdEmailCtrl, SpNegotiationRoundCtrl>(
      builder: (context, controller, roundCtrl, _) {
        final negotiations = controller.negotiations(key);

        // Only show the full chat skeleton on the very first load.
        // A background refresh (e.g. right after sending a message)
        // already has cached negotiations, so it updates in place
        // instead of tearing down and reloading the whole sheet.
        if (controller.isLoading(key) && negotiations.isEmpty) {
          return const NegotiationChatSkeleton();
        }

        if ((controller.error(key)?.isNotEmpty ?? false) &&
    negotiations.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          controller.error(key)!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

        if (negotiations.isNotEmpty && _negotiationId == null) {
          _negotiationId = negotiations.first.negotiationId;
        }

        final serverAccepted =
            negotiations.isNotEmpty && negotiations.first.status == 'accepted';
        final isAccepted = _optimisticAccepted || serverAccepted;

        final confirmedRounds = negotiations
            .expand((n) => n.rounds ?? [])
            .cast<NegotiationRound>()
            .toList();

        final pendingRounds = roundCtrl.pendingRoundsFor(_negotiationId);

        final allRounds = [...confirmedRounds, ...pendingRounds]
          ..sort(
            (a, b) => (a.createdAt ?? DateTime(1970))
                .compareTo(b.createdAt ?? DateTime(1970)),
          );

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        if (allRounds.isEmpty) {
          return Column(
            children: [
              _buildPlaceholder(),
              _buildInputAndAcceptArea(
                allRounds,
                isAccepted: isAccepted,
                roundCtrl: roundCtrl,
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: allRounds.length,
                  itemBuilder: (context, index) => _buildRoundBubble(
                    allRounds[index],
                    roundCtrl,
                  ),
                ),
              ),
            ),
            _buildInputAndAcceptArea(
              allRounds,
              isAccepted: isAccepted,
              roundCtrl: roundCtrl,
            ),
          ],
        );
      },
    );
  }
  // --- UI Building Widgets ---

  Widget _buildRoundBubble(
    NegotiationRound round,
    SpNegotiationRoundCtrl roundCtrl,
  ) {
    final isProvider = round.senderType == "provider";
    final isFailed = round.isFailed;
    final isSending = round.isPending;

    final negotiationsCtrl = context.read<SpNegotiationsByIdEmailCtrl>();

    Widget bubble = Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: isFailed
            ? Colors.red.shade50
            : isProvider
                ? Colors.blue.shade100
                : Colors.grey.shade200,
        border: isFailed ? Border.all(color: Colors.red.shade300) : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isProvider ? 16 : 4),
          bottomRight: Radius.circular(isProvider ? 4 : 16),
        ),
      ),
      child: Opacity(
        opacity: isSending ? 0.6 : 1.0,
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
                const Icon(Icons.monetization_on, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                if (isSending)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                else if (isFailed)
                  Icon(Icons.error_outline, size: 14, color: Colors.red.shade600)
                else
                  Text(
                    round.createdAt != null
                        ? DateFormat('HH:mm').format(round.createdAt!)
                        : 'N/A',
                    style: const TextStyle(fontSize: 12, color: Kolors.kDark),
                  ),
                if (isFailed) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Tap to retry',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (isFailed) {
      bubble = GestureDetector(
        onTap: () => _retryPendingRound(round, roundCtrl, negotiationsCtrl),
        onLongPress: () => _discardPendingRound(round, roundCtrl),
        child: bubble,
      );
    }

    return Align(
      alignment: isProvider ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }

  Widget _buildPlaceholder() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Kolors.kOffWhite),
            SizedBox(height: 16),
            Text(
              "Start the Negotiation",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Send your first price offer to begin the discussion.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Kolors.kOffWhite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAndAcceptArea(
    List<NegotiationRound> rounds, {
    required bool isAccepted,
    required SpNegotiationRoundCtrl roundCtrl,
  }) {
    return Consumer<ProviderAcceptNegotiationCtrl>(
      builder: (context, acceptCtrl, _) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final lastSenderIsClient =
            rounds.isNotEmpty && rounds.last.senderType == "client";
        final isFirstMessage = rounds.isEmpty;

        // Same logic as before — but since `rounds` now includes the
        // optimistic pending round the instant it's added, this flips to
        // "waiting" immediately, with no spinner delay.
        final shouldShowControls =
            !isAccepted && (isFirstMessage || lastSenderIsClient);
        final shouldShowAccept = shouldShowControls &&
            rounds.isNotEmpty &&
            rounds.last.offeredPrice != null;

        if (!shouldShowControls) {
          if (isAccepted) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Colors.green.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Negotiation Accepted. No further changes.',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomInset + 8, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Kolors.kOffWhite, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Waiting for client to respond...',
                  style: TextStyle(color: Kolors.kOffWhite, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomInset + 8, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      // No isLoading gate here anymore — optimistic accept
                      // happens instantly, so there's nothing to disable for.
                      onPressed: () => _handleAccept(acceptCtrl, rounds),
                      child: Text(
                        'Accept R${rounds.last.offeredPrice?.toStringAsFixed(2) ?? '?'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Kolors.kOffWhite),
                      decoration: InputDecoration(
                        hintText: 'Price',
                        labelText: 'R',
                        hintStyle: const TextStyle(color: Colors.white),
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message or optional notes...',
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Kolors.kPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      // No spinner / disabled state — send is instant now.
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        final roundCtrl = context.read<SpNegotiationRoundCtrl>();
                        final negotiationsCtrl =
                            context.read<SpNegotiationsByIdEmailCtrl>();
                        await _sendMessage(roundCtrl, negotiationsCtrl);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleAccept(
    ProviderAcceptNegotiationCtrl acceptCtrl,
    List<NegotiationRound> rounds,
  ) async {
    if (_negotiationId == null || _optimisticAccepted) return;

    // 1. Flip to "accepted" UI immediately — banner shows with zero delay.
    setState(() => _optimisticAccepted = true);

    final ok = await acceptCtrl.acceptNegotiation(_negotiationId!);

    if (!mounted) return;

    if (!ok) {
      // 2a. Revert on failure.
      setState(() => _optimisticAccepted = false);
      showTopNotification(context, 'Failed to accept negotiation.', isError: true);
      return;
    }

    // 2b. Confirmed — sync canonical state, then close out.
    await context.read<SpNegotiationsByIdEmailCtrl>()
        .refreshNegotiations(orderId: widget.orderId);
        final shipmentCtrl = context.read<ShipmentController>();
        
        debugPrint("Accept screen ShipmentController: ${shipmentCtrl.hashCode}");
        await shipmentCtrl.fetchShipments();

    if (!mounted) return;

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

    Navigator.of(context).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TabIndexNotifier>().setIndex(0);
    });
  }
}