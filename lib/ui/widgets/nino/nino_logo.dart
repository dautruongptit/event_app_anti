import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Brand mark — direction 1a "Near Ones": a coral rounded square holding
/// the letter N, a translucent ring hugging it, and a small mint dot
/// (coral-bordered) top-right when [showBadge] is true.
class NinoLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const NinoLogo({super.key, this.size = 84, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    final ringSize = size * 0.71;
    final ringWidth = size * 0.048;
    final fontSize = size * 0.452;
    final badgeSize = size * 0.131;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppColors.coralGradient,
              borderRadius: BorderRadius.circular(size * 0.286),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5A5F).withValues(alpha: 0.3),
                  blurRadius: size * 0.14,
                  offset: Offset(0, size * 0.06),
                ),
              ],
            ),
          ),
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: ringWidth),
            ),
          ),
          Text(
            'N',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -fontSize * 0.05,
              height: 1,
            ),
          ),
          if (showBadge)
            Positioned(
              top: size * 0.167,
              right: size * 0.167,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ECDC4),
                  border: Border.all(color: const Color(0xFFFF6266), width: badgeSize * 0.24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small horizontal lockup: [NinoLogo] + "nino" wordmark. Used in headers
/// and footers where the full square mark would be too big.
class NinoWordmark extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color? textColor;

  const NinoWordmark({super.key, this.logoSize = 20, this.fontSize = 14, this.textColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NinoLogo(size: logoSize, showBadge: false),
        SizedBox(width: logoSize * 0.4),
        Text(
          'nino',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -fontSize * 0.04,
            color: textColor ?? (isDark ? Colors.white : const Color(0xFF1F2530)),
          ),
        ),
      ],
    );
  }
}
