import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/core/utils/date_utils.dart';
import 'package:event_app/models/event.dart';

class RelativeDetailScreen extends StatefulWidget {
  final int id;
  const RelativeDetailScreen({super.key, required this.id});

  @override
  State<RelativeDetailScreen> createState() => _RelativeDetailScreenState();
}

class _RelativeDetailScreenState extends State<RelativeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeProvider>().loadRelativeDetail(widget.id);
    });
  }

  Color _getGroupColor(String groupType) {
    switch (groupType) {
      case 'GIA_DINH': return AppColors.primaryLight;
      case 'VO_CHONG': return Colors.pink;
      case 'CON_CAI': return Colors.green;
      case 'BAN_BE': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa người thân'),
        content: const Text('Bạn có chắc chắn muốn xóa người thân này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<RelativeProvider>().deleteRelative(widget.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa người thân')),
                );
                context.pop();
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final relative = provider.selectedRelative;
    final isLoading = provider.isLoading || relative == null || relative.id != widget.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: isLoading ? [] : [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/relatives/edit/${widget.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(relative, isDark),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (relative.daysUntilBirthday != null)
                          _buildBirthdayCountdown(relative, isDark)
                              .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        Text('Thông tin chi tiết', style: AppTextStyles.heading2)
                            .animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 12),
                        _buildInfoGrid(relative, isDark)
                            .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                        if (relative.hobbies != null && relative.hobbies!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Sở thích', style: AppTextStyles.heading2)
                              .animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 12),
                          _buildHobbies(relative.hobbies!, isDark)
                              .animate().fadeIn(delay: 450.ms),
                        ],
                        if (relative.relatedEvents.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Sự kiện liên quan', style: AppTextStyles.heading2)
                              .animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 12),
                          ...relative.relatedEvents.asMap().entries.map((e) {
                            return _buildEventCard(e.value, isDark)
                                .animate()
                                .fadeIn(delay: Duration(milliseconds: 550 + e.key * 50))
                                .slideY(begin: 0.1);
                          }),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(dynamic relative, bool isDark) {
    final color = _getGroupColor(relative.groupType);
    return Container(
      padding: const EdgeInsets.only(top: 100, bottom: 32, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.4),
            isDark ? AppColors.bgDark : AppColors.bgLight,
          ],
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${relative.id}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: color.withValues(alpha: 0.2),
                backgroundImage: relative.avatarUrl != null ? NetworkImage(relative.avatarUrl!) : null,
                child: relative.avatarUrl == null
                    ? Text(
                        relative.name.isNotEmpty ? relative.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
                      )
                    : null,
              ),
            ),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            relative.name,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          if (relative.nickname != null && relative.nickname!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                relative.nickname!,
                style: AppTextStyles.subtitle.copyWith(color: Colors.grey),
              ),
            ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(relative.groupTypeDisplay, color, isDark),
              if (relative.gender != null && relative.gender!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildBadge(relative.genderDisplay, Colors.blue, isDark),
              ]
            ],
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildBirthdayCountdown(dynamic relative, bool isDark) {
    final isSoon = relative.daysUntilBirthday! <= 7;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isSoon
            ? LinearGradient(
                colors: [AppColors.accentLight.withValues(alpha: 0.8), AppColors.accentLight.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSoon ? null : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSoon
            ? [
                BoxShadow(
                  color: AppColors.accentLight.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSoon ? Colors.white.withValues(alpha: 0.2) : AppColors.accentLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cake,
              color: isSoon ? Colors.white : AppColors.accentLight,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinh nhật sắp tới',
                  style: TextStyle(
                    color: isSoon ? Colors.white70 : Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  relative.daysUntilBirthday == 0
                      ? 'Hôm nay!'
                      : (relative.daysUntilBirthday == 1 ? 'Ngày mai' : 'Còn ${relative.daysUntilBirthday} ngày nữa'),
                  style: TextStyle(
                    color: isSoon ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(dynamic relative, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        if (relative.age != null)
          _buildInfoItem(Icons.cake_outlined, 'Tuổi', '${relative.age} tuổi', isDark),
        if (relative.dateOfBirth != null)
          _buildInfoItem(Icons.calendar_today, 'Ngày sinh', AppDateUtils.formatDate(relative.dateOfBirth!), isDark),
        if (relative.location != null && relative.location!.isNotEmpty)
          _buildInfoItem(Icons.location_on_outlined, 'Địa chỉ', relative.location!, isDark),
        if (relative.gender != null && relative.gender!.isNotEmpty)
          _buildInfoItem(Icons.person_outline, 'Giới tính', relative.genderDisplay, isDark),
        if (relative.heightCm != null)
          _buildInfoItem(Icons.height, 'Chiều cao', '${relative.heightCm} cm', isDark),
        if (relative.weightKg != null)
          _buildInfoItem(Icons.monitor_weight_outlined, 'Cân nặng', '${relative.weightKg} kg', isDark),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHobbies(List<String> hobbies, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hobbies.map((hobby) {
        return Chip(
          label: Text(hobby),
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }

  Widget _buildEventCard(EventModel event, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(event.eventTypeIcon, color: AppColors.primaryLight),
        ),
        title: Text(event.title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                AppDateUtils.formatDate(event.eventDate),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        trailing: event.daysUntil != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.daysUntilText,
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const CircleAvatar(radius: 60, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 200, height: 24, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            ),
          ],
        ),
      ),
    );
  }
}
