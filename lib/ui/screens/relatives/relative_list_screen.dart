import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/models/relative.dart';
import 'package:event_app/models/group_summary.dart';

class RelativeListScreen extends StatefulWidget {
  const RelativeListScreen({super.key});

  @override
  State<RelativeListScreen> createState() => _RelativeListScreenState();
}

class _RelativeListScreenState extends State<RelativeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RelativeProvider>();
      provider.loadRelatives();
      provider.loadGroupSummary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getTotalCount(List<GroupSummary> summaries) {
    return summaries.fold(0, (sum, item) => sum + item.count);
  }

  int _getGroupCount(List<GroupSummary> summaries, String type) {
    try {
      return summaries.firstWhere((s) => s.groupType == type).count;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final totalCount = _getTotalCount(provider.groupSummary);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 80),
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Người thân',
                        style: AppTextStyles.heading1.copyWith(color: AppColors.surfaceLight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalCount người',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surfaceLight.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // 4 Group Cards
                Positioned(
                  top: 140,
                  left: 24,
                  right: 24,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildGroupCard(
                        'GIA_DINH',
                        'Gia đình',
                        '👨‍👩‍👧‍👦',
                        AppColors.groupTypeColors['GIA_DINH'] ?? AppColors.primaryLight,
                        _getGroupCount(provider.groupSummary, 'GIA_DINH'),
                        provider.filterGroupType == 'GIA_DINH',
                      ),
                      _buildGroupCard(
                        'VO_CHONG',
                        'Vợ/Chồng',
                        '❤️',
                        AppColors.groupTypeColors['VO_CHONG'] ?? AppColors.accentLight,
                        _getGroupCount(provider.groupSummary, 'VO_CHONG'),
                        provider.filterGroupType == 'VO_CHONG',
                      ),
                      _buildGroupCard(
                        'CON_CAI',
                        'Con cái',
                        '👶',
                        AppColors.groupTypeColors['CON_CAI'] ?? AppColors.secondaryLight,
                        _getGroupCount(provider.groupSummary, 'CON_CAI'),
                        provider.filterGroupType == 'CON_CAI',
                      ),
                      _buildGroupCard(
                        'BAN_BE',
                        'Bạn bè',
                        '👥',
                        AppColors.groupTypeColors['BAN_BE'] ?? AppColors.warning,
                        _getGroupCount(provider.groupSummary, 'BAN_BE'),
                        provider.filterGroupType == 'BAN_BE',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for overlap
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        provider.setSearchQuery(value.isEmpty ? null : value);
                      },
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryLight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.accentLight),
                ),
              ),
            )
          else if (provider.relatives.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Không có người thân nào',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryLight),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final relative = provider.relatives[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                    child: _buildRelativeCard(relative, index),
                  );
                },
                childCount: provider.relatives.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
      String type, String title, String emoji, Color color, int count, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<RelativeProvider>();
        if (isSelected) {
          provider.setGroupFilter(null);
        } else {
          provider.setGroupFilter(type);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$count người',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelativeCard(RelativeModel relative, int index) {
    final Color groupColor = AppColors.groupTypeColors[relative.groupType] ?? AppColors.primaryLight;
    final String initial = relative.name.isNotEmpty ? relative.name[0].toUpperCase() : '?';

    String dateStr = '';
    if (relative.dateOfBirth != null) {
      dateStr = DateFormat('dd/MM').format(relative.dateOfBirth!);
    }

    return GestureDetector(
      onTap: () => context.push('/relatives/${relative.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textSecondaryLight.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryLight.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: groupColor.withValues(alpha: 0.1),
              backgroundImage: relative.avatarUrl != null ? NetworkImage(relative.avatarUrl!) : null,
              child: relative.avatarUrl == null
                  ? Text(
                      initial,
                      style: AppTextStyles.heading3.copyWith(color: groupColor),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relative.displayName,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: groupColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          relative.groupTypeDisplay,
                          style: AppTextStyles.caption.copyWith(color: groupColor),
                        ),
                      ),
                      if (dateStr.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.cake, size: 12, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (relative.totalEvents != null && relative.totalEvents! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${relative.totalEvents}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'sự kiện',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
    );
  }
}
