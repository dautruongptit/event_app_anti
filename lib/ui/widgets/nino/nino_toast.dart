import 'package:flutter/material.dart';

/// Floating dark pill toast, auto-dismisses after ~1.9s — matches the
/// design's toast (distinct from Material's full-width SnackBar, used
/// only for brief confirmations like "Đã lưu thay đổi").
void showNinoToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 18,
      right: 18,
      bottom: 96,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF22262C),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 28, offset: Offset(0, 12))],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFF2F4F7), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1900), () {
    if (entry.mounted) entry.remove();
  });
}
