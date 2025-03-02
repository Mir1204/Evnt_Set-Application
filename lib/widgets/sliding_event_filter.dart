import 'package:flutter/material.dart';

class SlidingEventFilter extends StatelessWidget {
  final List<String> eventTypes;
  final String selectedEventType;
  final Function(String) onEventTypeSelected;

  const SlidingEventFilter({
    Key? key,
    required this.eventTypes,
    required this.selectedEventType,
    required this.onEventTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: eventTypes.length,
        itemBuilder: (context, index) {
          final eventType = eventTypes[index];
          final isSelected = eventType == selectedEventType;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(eventType),
              selected: isSelected,
              onSelected: (_) => onEventTypeSelected(eventType),
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}
