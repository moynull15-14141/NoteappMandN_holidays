import 'package:flutter/material.dart';

class MoodSelector extends StatefulWidget {
  final String? selectedMood;
  final Function(String) onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  static const Map<String, String> moods = {
    'amazing': '🤩',
    'happy': '😊',
    'good': '👍',
    'neutral': '😐',
    'sad': '😢',
    'angry': '😠',
    'tired': '😴',
    'excited': '🎉',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: moods.entries.map((entry) {
            final isSelected = widget.selectedMood == entry.key;
            return GestureDetector(
              onTap: () => widget.onMoodSelected(entry.key),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withAlpha(26)
                      : Colors.transparent,
                ),
                child: Text(entry.value, style: const TextStyle(fontSize: 28)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
