import 'dart:async';

import 'package:flutter/material.dart';

/// Bọc [child] và tự chạy hiệu ứng "rung" (xoay qua lại nhanh, như chuông
/// bị gõ) mỗi khi [trigger] đổi giá trị so với lần build trước — dùng cho
/// biểu tượng chuông thông báo khi có push mới đến lúc app đang mở (xem
/// NotificationProvider.newNotificationTick / FcmService.onForegroundMessage).
///
/// Rung LIÊN TỤC trong [duration] (mặc định 20 giây) thay vì chỉ 1 cú rung
/// ngắn — một cú rung 500ms rất dễ bị bỏ lỡ nếu người dùng không nhìn đúng
/// khoảnh khắc nó xảy ra.
///
/// [trigger] có thể là bất kỳ giá trị nào so sánh được bằng `==` (thường là
/// một số đếm tăng dần) — chỉ quan tâm nó có ĐỔI hay không giữa 2 lần build,
/// không quan tâm giá trị cụ thể.
class ShakeOnChange extends StatefulWidget {
  final Object trigger;
  final Widget child;
  final Duration duration;

  const ShakeOnChange({
    super.key,
    required this.trigger,
    required this.child,
    this.duration = const Duration(seconds: 20),
  });

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange> with SingleTickerProviderStateMixin {
  /// Thời lượng một chu kỳ rung (đi rồi về đúng góc 0) — được lặp lại liên
  /// tục trong suốt [ShakeOnChange.duration].
  static const _cycleDuration = Duration(milliseconds: 400);

  late final AnimationController _controller;
  late final Animation<double> _angle;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycleDuration);
    // Mỗi chu kỳ bắt đầu và kết thúc đúng ở góc 0 — nhờ vậy trạng thái nghỉ
    // (chưa rung / đã rung xong) luôn là góc 0 mà không cần map riêng.
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
      _startShaking();
    }
  }

  void _startShaking() {
    _stopTimer?.cancel();
    _controller.repeat();
    _stopTimer = Timer(widget.duration, () {
      if (!mounted) return;
      _controller.stop();
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
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
