import 'package:flutter/material.dart';

/// Bọc [child] và tự chạy hiệu ứng "rung" (xoay qua lại nhanh, như chuông
/// bị gõ) mỗi khi [trigger] đổi giá trị so với lần build trước — dùng cho
/// biểu tượng chuông thông báo khi có push mới đến lúc app đang mở (xem
/// NotificationProvider.newNotificationTick / FcmService.onForegroundMessage).
///
/// [trigger] có thể là bất kỳ giá trị nào so sánh được bằng `==` (thường là
/// một số đếm tăng dần) — chỉ quan tâm nó có ĐỔI hay không giữa 2 lần build,
/// không quan tâm giá trị cụ thể.
class ShakeOnChange extends StatefulWidget {
  final Object trigger;
  final Widget child;

  const ShakeOnChange({super.key, required this.trigger, required this.child});

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _angle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.25, end: 0.25), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.18), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.18, end: 0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant ShakeOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angle,
      builder: (context, child) => Transform.rotate(angle: _angle.value, child: child),
      child: widget.child,
    );
  }
}
