import 'dart:async';

import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double width;
  final Duration startAfter;
  final Duration speed;
  final double pauseAfterRound;
  final double fadeWidth;
  final Color? backgroundColor;
  final int minCharactersToScroll;
  final TextAlign textAlign; // New alignment parameter

  const ScrollingText({
    super.key,
    required this.text,
    required this.width,
    this.style,
    this.startAfter = const Duration(microseconds: 250),
    this.speed = const Duration(milliseconds: 50),
    this.pauseAfterRound = 1.5,
    this.fadeWidth = 20.0,
    this.backgroundColor,
    this.minCharactersToScroll = 20,
    this.textAlign = TextAlign.left, // Default to left alignment
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  late ScrollController _scrollController;
  Timer? _timer;
  bool _hasOverflow = false;
  bool _isPaused = false;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForOverflow();
      if (_hasOverflow && _shouldScroll) {
        _startScrolling();
      }
    });
  }

  void _checkForOverflow() {
    setState(() {
      _shouldScroll = widget.text.length >= widget.minCharactersToScroll;

      final textPainter = TextPainter(
        text: TextSpan(text: widget.text, style: widget.style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: double.infinity);

      _hasOverflow = textPainter.width > widget.width;
    });
  }

  void _startScrolling() async {
    await Future.delayed(widget.startAfter);
    if (!mounted) return;

    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted || _scrollController.positions.isEmpty) {
        timer.cancel();
        return;
      }

      if (_isPaused) return;

      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentPosition = _scrollController.position.pixels;

      if (currentPosition >= maxScroll) {
        _scrollController.jumpTo(0);
        _pauseScrolling();
      } else {
        _scrollController.animateTo(
          currentPosition + 3,
          duration: widget.speed,
          curve: Curves.linear,
        );
      }
    });
  }

  void _pauseScrolling() async {
    _isPaused = true;
    await Future.delayed(Duration(
      milliseconds: (widget.width * widget.pauseAfterRound).toInt(),
    ));
    if (mounted) {
      _isPaused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    // If not scrolling, wrap in an aligned container
    if (!_hasOverflow || !_shouldScroll) {
      return SizedBox(
        width: widget.width,
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: widget.textAlign,
        ),
      );
    }

    // For scrolling text, create a stack with scroll view
    return Stack(
      children: [
        SizedBox(
          width: widget.width,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                // Add initial spacing for center/right alignment when scrolling
                if (widget.textAlign != TextAlign.left)
                  SizedBox(
                      width: widget.textAlign == TextAlign.center
                          ? widget.width / 2
                          : widget.width),
                Text(
                  widget.text,
                  style: widget.style,
                  maxLines: 1,
                ),
                SizedBox(width: widget.width * 0.3),
                Text(
                  widget.text,
                  style: widget.style,
                  maxLines: 1,
                ),
                // Add final spacing for center/left alignment when scrolling
                if (widget.textAlign != TextAlign.right)
                  SizedBox(
                      width: widget.textAlign == TextAlign.center
                          ? widget.width / 2
                          : widget.width),
              ],
            ),
          ),
        ),
        // Fade effects
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: widget.fadeWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: widget.fadeWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}

// Example usage with different alignments
// class ExampleWithAlignment extends StatelessWidget {
//   const ExampleWithAlignment({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Left-aligned (default)
//             Container(
//               width: 200,
//               color: Colors.grey[200],
//               padding: const EdgeInsets.all(8),
//               child: ScrollingText(
//                 text: "This is left-aligned text that will scroll",
//                 width: 200,
//                 style: const TextStyle(fontSize: 16),
//                 backgroundColor: Colors.grey[200],
//                 textAlign: TextAlign.left,
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Center-aligned
//             Container(
//               width: 200,
//               color: Colors.grey[200],
//               padding: const EdgeInsets.all(8),
//               child: ScrollingText(
//                 text: "This is center-aligned text that will scroll",
//                 width: 200,
//                 style: const TextStyle(fontSize: 16),
//                 backgroundColor: Colors.grey[200],
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Right-aligned
//             Container(
//               width: 200,
//               color: Colors.grey[200],
//               padding: const EdgeInsets.all(8),
//               child: ScrollingText(
//                 text: "This is right-aligned text that will scroll",
//                 width: 200,
//                 style: const TextStyle(fontSize: 16),
//                 backgroundColor: Colors.grey[200],
//                 textAlign: TextAlign.right,
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Short text with different alignments
//             Container(
//               width: 200,
//               color: Colors.grey[200],
//               padding: const EdgeInsets.all(8),
//               child: ScrollingText(
//                 text: "Short text",
//                 width: 200,
//                 style: const TextStyle(fontSize: 16),
//                 backgroundColor: Colors.grey[200],
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
