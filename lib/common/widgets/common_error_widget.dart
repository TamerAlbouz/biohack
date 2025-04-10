import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';

class CommonErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double size;
  final bool isFullScreen;

  const CommonErrorWidget({
    super.key,
    this.message = 'Oops! Something went wrong...',
    required this.onRetry,
    this.size = 120,
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phone error animation
        PhoneErrorAnimation(size: size),

        const SizedBox(height: 24),

        // Error message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Retry button
        _buildRetryButton(context),
      ],
    );

    // If it's a full screen error, wrap it in an Expanded and Center
    if (isFullScreen) {
      return Expanded(
        child: Center(child: content),
      );
    }

    // Otherwise just return the content
    return Center(child: content);
  }

  Widget _buildRetryButton(BuildContext context) {
    return InkWell(
      onTap: onRetry,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MyColors.primary,
              MyColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneErrorAnimation extends StatefulWidget {
  final double size;

  const PhoneErrorAnimation({
    super.key,
    required this.size,
  });

  @override
  State<PhoneErrorAnimation> createState() => _PhoneErrorAnimationState();
}

class _PhoneErrorAnimationState extends State<PhoneErrorAnimation>
    with TickerProviderStateMixin {
  late AnimationController _phoneController;
  late AnimationController _warningController;
  late AnimationController _screenGlitchController;

  late Animation<double> _phoneShakeAnimation;
  late Animation<double> _warningScaleAnimation;
  late Animation<double> _warningOpacityAnimation;
  late Animation<double> _screenGlitchAnimation;

  @override
  void initState() {
    super.initState();

    // Phone shake animation
    _phoneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _phoneShakeAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(
        parent: _phoneController,
        curve: Curves.easeInOut,
      ),
    );

    // Warning animation
    _warningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _warningScaleAnimation = Tween<double>(begin: 0.85, end: 1.1).animate(
      CurvedAnimation(
        parent: _warningController,
        curve: Curves.easeInOut,
      ),
    );

    _warningOpacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _warningController,
        curve: Curves.easeInOut,
      ),
    );

    // Screen glitch effect
    _screenGlitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _screenGlitchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _screenGlitchController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _warningController.dispose();
    _screenGlitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size * 1.1,
      height: widget.size * 1.1,
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_phoneController, _warningController, _screenGlitchController]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _phoneShakeAnimation.value,
              child: SizedBox(
                width: widget.size * 0.6,
                height: widget.size * 0.9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Phone frame
                    _buildPhoneFrame(),

                    // Screen with glitch effect
                    _buildPhoneScreen(),

                    // Warning symbol
                    _buildWarningSymbol(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhoneFrame() {
    return Container(
      width: widget.size * 0.5,
      height: widget.size * 0.9,
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(widget.size * 0.1),
        border: Border.all(
          color: MyColors.primary,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildPhoneScreen() {
    // Calculate glitch effect
    double glitchOffset = _screenGlitchAnimation.value;
    bool showGlitch = glitchOffset > 0.7 && glitchOffset < 0.8;

    return Positioned(
      top: widget.size * 0.15,
      child: Container(
        width: widget.size * 0.4,
        height: widget.size * 0.6,
        decoration: BoxDecoration(
          color: showGlitch
              ? MyColors.primary.withValues(alpha: 0.5)
              : MyColors.primary,
          borderRadius: BorderRadius.circular(widget.size * 0.02),
        ),
        child: showGlitch
            ? Stack(
                children: [
                  // Glitch lines
                  Positioned(
                    top: widget.size * 0.2 * glitchOffset,
                    height: 2,
                    width: widget.size * 0.4,
                    child:
                        Container(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  Positioned(
                    top: widget.size * 0.4 * glitchOffset,
                    height: 1,
                    width: widget.size * 0.4,
                    child:
                        Container(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildWarningSymbol() {
    return Positioned(
      top: widget.size * 0.35,
      child: Transform.scale(
        scale: _warningScaleAnimation.value,
        child: Opacity(
          opacity: _warningOpacityAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Warning triangle
              CustomPaint(
                size: Size(widget.size * 0.25, widget.size * 0.2),
                painter: WarningTrianglePainter(
                  color: Colors.white,
                ),
              ),

              // Exclamation mark
              Text(
                "!",
                style: TextStyle(
                  color: MyColors.primary,
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the warning triangle
class WarningTrianglePainter extends CustomPainter {
  final Color color;

  WarningTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
