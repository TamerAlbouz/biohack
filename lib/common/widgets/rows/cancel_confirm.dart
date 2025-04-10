import 'package:flutter/material.dart';

import '../../../styles/sizes.dart';
import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';

class CancelConfirm extends StatelessWidget {
  const CancelConfirm({
    super.key,
    this.onCancel,
    required this.onConfirm,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
  });

  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final String cancelText;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (onCancel != null) {
                onCancel!();
              }
              Navigator.of(context).pop();
            },
            style: kOutlinedButtonCancelStyle,
            child: Text(cancelText, style: kBoxCancelButtonText),
          ),
        ),
        kGap16,
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: kElevatedButtonCommonStyle,
            child: Text(confirmText, style: kBoxConfirmButtonText),
          ),
        ),
      ],
    );
  }
}
