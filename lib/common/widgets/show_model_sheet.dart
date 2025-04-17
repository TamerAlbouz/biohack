import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';

void showOptionsPicker(
  BuildContext context,
  String title,
  List<Map<String, dynamic>> options,
  int currentValue,
  Function(int) onSelect,
) {
  const line = DottedLine(
    direction: Axis.horizontal,
    lineLength: double.infinity,
    lineThickness: 1,
    dashLength: 4.0,
    dashColor: MyColors.softStroke,
  );

  showModalBottomSheet(
    context: context,
    backgroundColor: MyColors.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (context, index) => line,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final bool isSelected = currentValue == option['value'];

                  return InkWell(
                    onTap: () {
                      onSelect(option['value']);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? MyColors.primary
                                  : MyColors.textBlack,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: MyColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
