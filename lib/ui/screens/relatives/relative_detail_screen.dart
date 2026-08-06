import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/models/relative.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final relative = provider.selectedRelative;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Thông tin người thân',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimaryLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimaryLight),
            onPressed: () {
              // Edit action
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              // Delete action
            },
          ),
        ],
      ),
      body: provider.isLoading || relative == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(relative),
                  const SizedBox(height: 24),
                  _buildBasicInfo(relative),
                  const SizedBox(height: 24),
                  _buildRelatedEvents(relative),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(RelativeDetailModel relative) {
    final initial = relative.name.isNotEmpty ? relative.name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.secondaryLight,
            backgroundImage: relative.avatarUrl != null ? NetworkImage(relative.avatarUrl!) : null,
            child: relative.avatarUrl == null
                ? Text(initial, style: AppTextStyles.heading1.copyWith(color: Colors.white))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            relative.displayName,
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${relative.genderDisplay} • ${relative.age ?? '?'} tuổi',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 24),
          if (relative.daysUntilBirthday != null && relative.dateOfBirth != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake, color: AppColors.secondaryLight, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sinh nhật Còn ${relative.daysUntilBirthday} ngày',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.secondaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(relative.dateOfBirth!),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildBasicInfo(RelativeDetailModel relative) {
    String dobStr = relative.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(relative.dateOfBirth!) : 'Không có';
    String specs = '';
    if (relative.heightCm != null) specs += '${relative.heightCm} cm';
    if (relative.weightKg != null) {
      if (specs.isNotEmpty) specs += ' • ';
      specs += '${relative.weightKg} kg';
    }
    if (specs.isEmpty) specs = 'Không có';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin cơ bản', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.calendar_today, 'Ngày sinh', dobStr),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, 'Địa điểm', relative.location ?? 'Không có'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.info_outline, 'Thông số', specs),
          const SizedBox(height: 16),
          _buildHobbiesRow(relative.hobbies),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.iconBgTeal,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.secondaryLight),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHobbiesRow(List<String>? hobbies) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.iconBgTeal,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite_border, size: 16, color: AppColors.secondaryLight),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sở thích', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 6),
              if (hobbies == null || hobbies.isEmpty)
                Text('Không có', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hobbies.map((h) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(h, style: AppTextStyles.caption),
                  )).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedEvents(RelativeDetailModel relative) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sự kiện liên quan', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {},
              child: Text('+ Thêm sự kiện', style: AppTextStyles.button.copyWith(color: AppColors.primaryLight)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (relative.relatedEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Center(
              child: Text(
                'Chưa có sự kiện nào cho ${relative.displayName}',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...relative.relatedEvents.map((e) => _buildEventItem(e)),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEventItem(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.iconBgTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(event.eventTypeIcon, color: AppColors.secondaryLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(event.eventDate),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (event.daysUntil != null)
            Text(
              event.daysUntilText,
              style: AppTextStyles.label.copyWith(color: AppColors.secondaryLight, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
