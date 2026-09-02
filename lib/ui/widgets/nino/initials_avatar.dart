import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Circle avatar: shows [avatarUrl] when present, otherwise [emoji] (nếu
/// có — VD icon quan hệ ở màn Người thân) hoặc chữ cái đầu của [name] trên
/// nền [softColor].
class InitialsAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final Color softColor;
  final double radius;
  final String? avatarUrl;
  final String? emoji;

  const InitialsAvatar({
    super.key,
    required this.name,
    required this.color,
    required this.softColor,
    this.radius = 24,
    this.avatarUrl,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: softColor,
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: softColor,
      child: (emoji != null && emoji!.isNotEmpty)
          ? Text(emoji!, style: TextStyle(fontSize: radius * 0.78))
          : Text(
              initial,
              style: TextStyle(fontSize: radius * 0.62, fontWeight: FontWeight.w700, color: color),
            ),
    );
  }
}
