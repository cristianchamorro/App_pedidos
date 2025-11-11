import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom Logo Widget for the Restaurant App
/// This widget displays a custom-drawn logo that scales perfectly
/// and matches the app theme colors.
/// 
/// Can be replaced with an Image widget if a custom logo file is provided.
class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final bool showCircleBackground;

  const AppLogo({
    super.key,
    this.size = 120,
    this.backgroundColor,
    this.showCircleBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    // If you have a custom logo image, uncomment this and comment out the CustomPaint:
    // return Image.asset(
    //   'assets/images/logo.png',
    //   width: size,
    //   height: size,
    // );

    // For now, we use a custom-drawn logo
    return Container(
      width: size,
      height: size,
      decoration: showCircleBackground
          ? BoxDecoration(
              color: backgroundColor ?? Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _LogoPainter(),
      ),
    );
  }
}

/// Custom painter for the restaurant logo
/// Draws a stylized restaurant icon with fork, knife, and plate
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the main circle/plate (60% of size)
    final plateRadius = radius * 0.6;
    paint.color = AppTheme.primary;
    canvas.drawCircle(center, plateRadius, paint);

    // Draw inner plate circle (lighter)
    final innerPlateRadius = plateRadius * 0.85;
    paint.color = AppTheme.primaryLight;
    canvas.drawCircle(center, innerPlateRadius, paint);

    // Draw utensils in white
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.05;

    // Fork (left side)
    final forkX = center.dx - plateRadius * 0.5;
    final utensilTop = center.dy - plateRadius * 0.6;
    final utensilBottom = center.dy + plateRadius * 0.6;

    // Fork handle
    canvas.drawLine(
      Offset(forkX, utensilTop),
      Offset(forkX, utensilBottom),
      paint,
    );

    // Fork prongs
    paint.strokeWidth = size.width * 0.025;
    final prongSpacing = size.width * 0.04;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(forkX + (i * prongSpacing), utensilTop),
        Offset(forkX + (i * prongSpacing), utensilTop + plateRadius * 0.3),
        paint,
      );
    }

    // Knife (right side)
    paint.strokeWidth = size.width * 0.05;
    final knifeX = center.dx + plateRadius * 0.5;
    canvas.drawLine(
      Offset(knifeX, utensilTop),
      Offset(knifeX, utensilBottom),
      paint,
    );

    // Knife blade (top part, slightly wider)
    paint.strokeWidth = size.width * 0.06;
    canvas.drawLine(
      Offset(knifeX, utensilTop),
      Offset(knifeX, utensilTop + plateRadius * 0.4),
      paint,
    );

    // Add a small accent dot at the top center
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.accent;
    canvas.drawCircle(
      Offset(center.dx, center.dy - plateRadius * 0.3),
      size.width * 0.03,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
