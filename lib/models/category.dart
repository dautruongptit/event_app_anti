import 'package:flutter/material.dart';
import '../core/utils/category_icons.dart';

/// Danh mục sự kiện — lấy từ `GET /events/categories` (bảng `event_categories`
/// bên backend), KHÔNG hardcode ở Flutter nữa. Trước đây picker "Danh mục"
/// ở màn Thêm/Sửa sự kiện dùng 1 danh sách cứng riêng, đã lệch khỏi dữ liệu
/// DB thật (VD: màu "Sinh nhật" khác nhau giữa 2 nơi).
class CategoryModel {
  final int id;
  final String code;
  final String displayName;
  final String icon;
  final String colorHex;
  final bool isSystem;

  const CategoryModel({
    required this.id,
    required this.code,
    required this.displayName,
    required this.icon,
    required this.colorHex,
    this.isSystem = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      icon: json['icon'] as String? ?? '',
      colorHex: json['colorHex'] as String? ?? '',
      isSystem: json['isSystem'] as bool? ?? true,
    );
  }

  IconData get iconData => iconForCategoryIcon(icon);
  Color get color => colorFromHex(colorHex);
}
