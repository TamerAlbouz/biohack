import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';

class RoundedRadioButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;

  const RoundedRadioButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor = MyColors.buttonGreen,
    this.unselectedColor = MyColors.textFieldBlack,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: kRadius10,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textColor : MyColors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
