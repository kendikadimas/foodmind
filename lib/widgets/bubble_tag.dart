import 'package:flutter/material.dart';
import '../theme.dart';

class BubbleTag extends StatefulWidget {
  final String label;
  final ValueChanged<bool> onSelected;
  final bool initialSelected;

  const BubbleTag({
    super.key,
    required this.label,
    required this.onSelected,
    this.initialSelected = false,
  });

  @override
  State<BubbleTag> createState() => _BubbleTagState();
}

class _BubbleTagState extends State<BubbleTag> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onSelected(isSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryOrange,
            width: 2,
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
