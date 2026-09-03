import 'package:flutter/material.dart';

/// Map tên icon dạng chuỗi (VD "cake", "home") — cột `icon` của bảng
/// `event_categories` bên backend, comment gốc ghi rõ "Tên icon dùng chung
/// Backend + Flutter" — sang [IconData] cục bộ. Dùng chung giữa
/// `EventModel.eventTypeIcon` (icon của 1 sự kiện đã có) và `CategoryModel`
/// (icon trong picker "Danh mục") để tránh 2 bảng map tách rời, dễ lệch
/// nhau (đã từng xảy ra: màu "Sinh nhật" hardcode ở form khác màu DB).
IconData iconForCategoryIcon(String icon) {
  const map = {
    'cake': Icons.cake_rounded,
    'favorite': Icons.favorite_rounded,
    'celebration': Icons.celebration_rounded,
    'home': Icons.home_rounded,
    'receipt_long': Icons.receipt_long_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'event': Icons.event_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'bolt': Icons.bolt_rounded,
    'more_horiz': Icons.more_horiz_rounded,
  };
  return map[icon] ?? Icons.event_rounded;
}

/// Parse màu hex từ backend (`colorHex`, VD "#FF6B6B") sang [Color]. Dùng
/// chung giữa `EventModel.categoryColorValue` và `CategoryModel.color`.
Color colorFromHex(String hex, {Color fallback = Colors.grey}) {
  if (hex.isEmpty) return fallback;
  var hexStr = hex.replaceAll('#', '');
  if (hexStr.length == 6) hexStr = 'FF$hexStr';
  final val = int.tryParse(hexStr, radix: 16);
  return val != null ? Color(val) : fallback;
}
