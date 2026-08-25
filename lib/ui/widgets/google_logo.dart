import 'package:flutter/material.dart';

/// Logo chữ "G" nhiều màu của Google, vẽ bằng CustomPainter để không cần
/// asset ảnh riêng. Dùng chung cho SplashScreen, LoginScreen, RegisterScreen
/// để icon nút "Đăng nhập/Đăng ký với Google" đồng nhất trên mọi màn hình.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4);
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853);
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335);

    final Offset center = Offset(w / 2, h / 2);
    final double radius = w / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, -0.4, 1.8, true, bluePaint);
    canvas.drawArc(rect, 1.4, 1.3, true, greenPaint);
    canvas.drawArc(rect, 2.7, 0.9, true, yellowPaint);
    canvas.drawArc(rect, 3.6, 1.1, true, redPaint);

    final Paint bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, bgPaint);

    final Rect barRect = Rect.fromLTWH(w * 0.45, h * 0.38, w * 0.52, h * 0.24);
    canvas.drawRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
