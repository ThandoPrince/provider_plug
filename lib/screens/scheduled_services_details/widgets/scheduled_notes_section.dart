import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ScheduledNotesSection extends StatefulWidget {
  final String? notes;

  const ScheduledNotesSection({super.key, this.notes});

  @override
  State<ScheduledNotesSection> createState() => _ScheduledNotesSectionState();
}

class _ScheduledNotesSectionState extends State<ScheduledNotesSection> {
  bool showNotes = false;

  @override
  Widget build(BuildContext context) {
    final hasNotes = (widget.notes ?? "").isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: hasNotes ? () => setState(() => showNotes = !showNotes) : null,
          child: Row(
            children: [
              const Icon(Icons.notes, color: Kolors.kDark),
              const SizedBox(width: 8),
              const Text(
                "Client Notes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Kolors.kDark,
                ),
              ),
              const Spacer(),
              if (hasNotes)
                AnimatedRotation(
                  turns: showNotes ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: Kolors.kDark, size: 28),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Kolors.kOffWhite.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Kolors.kOffWhite, width: 1),
            ),
            child: Text(
              widget.notes ?? "No notes provided.",
              style: TextStyle(
                fontSize: 15,
                fontStyle: widget.notes == null ? FontStyle.italic : FontStyle.normal,
                color: Kolors.kDark,
              ),
            ),
          ),
          crossFadeState: showNotes
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}
