import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';

class HexagonPatternBox extends StatelessWidget {
  final double width;
  final double height;

  const HexagonPatternBox({
    super.key,
    this.width = 200,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: MyColors.primary,
        ),
        child: CustomPaint(
          size: Size(width, height),
          painter: DiagonalRectanglePainter(
            primaryColor: Colors.white,
            secondaryColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DiagonalRectanglePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  DiagonalRectanglePainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double rectWidth = size.width / 15; // Adjust rectangle width
    final double rectHeight = size.height / 8; // Adjust rectangle height
    final double spacing = rectWidth * 2; // Space between rectangles

    final Paint primaryPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint secondaryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    void drawDiagonalRectangle(double x, double y, Paint paint) {
      // Rotate rectangle by 45 degrees
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.pi / 4);

      final Rect rect = Rect.fromCenter(
        center: const Offset(0, 0),
        width: rectWidth,
        height: rectHeight,
      );

      canvas.drawRect(rect, paint);
      canvas.restore();
    }

    // Create a slight random offset for each rectangle
    final random = math.Random(42); // Fixed seed for consistent pattern

    // Calculate the number of diagonal lines needed
    int numDiagonals = ((size.width + size.height) / spacing).ceil() + 2;

    // Draw diagonal lines of rectangles
    for (int d = -5; d < numDiagonals; d++) {
      double startX = d * spacing;
      double startY = 0;

      // If startX is beyond the width, adjust startY
      if (startX > size.width) {
        startY = startX - size.width;
        startX = size.width;
      }

      // If startX is negative, adjust startY
      if (startX < 0) {
        startY = -startX;
        startX = 0;
      }

      while (startY < size.height && startX >= 0) {
        // Add small random offsets
        final double offsetX = random.nextDouble() * 4 - 2;
        final double offsetY = random.nextDouble() * 4 - 2;

        // Alternate between primary and secondary rectangles
        final bool isPrimary = d % 2 == 0;
        drawDiagonalRectangle(
          startX + offsetX,
          startY + offsetY,
          isPrimary ? primaryPaint : secondaryPaint,
        );

        startX -= spacing;
        startY += spacing;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
