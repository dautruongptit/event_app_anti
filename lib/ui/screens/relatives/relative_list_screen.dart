import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final summaries = provider.groupSummary;
    final totalRelatives = _getTotalCount(summaries);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/relatives/create'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text('Thêm người thân', style: AppTextStyles.button),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderAndGroups(totalRelatives, summaries, provider.filterGroupType),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách',
                    style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        context.read<RelativeProvider>().setSearchQuery(value);
                      },
                      style: AppTextStyles.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondaryLight),
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceDark : Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.relatives.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('Chưa có người thân nào', style: AppTextStyles.body),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final relative = provider.relatives[index];
                  return _buildRelativeItem(relative, index);
                },
                childCount: provider.relatives.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeaderAndGroups(int total, List<GroupSummary> summaries, String? selectedGroup) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(200, 30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Người thân',
                style: AppTextStyles.heading1.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '$total người',
                style: AppTextStyles.subtitle.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 140),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildGroupGrid(summaries, selectedGroup),
        ),
      ],
    );
  }

  Widget _buildGroupGrid(List<GroupSummary> summaries, String? selectedGroup) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.9,
      children: [
        _buildGroupCard(
          'GIA_DINH',
          'Gia đình',
          Icons.people,
          AppColors.iconBgPink,
          AppColors.primaryLight,
          _getCount(summaries, 'GIA_DINH'),
          selectedGroup == 'GIA_DINH',
        ),
        _buildGroupCard(
          'VO_CHONG',
          'Vợ/Chồng',
          Icons.favorite,
          AppColors.iconBgTeal,
          AppColors.secondaryLight,
          _getCount(summaries, 'VO_CHONG'),
          selectedGroup == 'VO_CHONG',
        ),
        _buildGroupCard(
          'CON_CAI',
          'Con cái',
          Icons.child_care,
          AppColors.iconBgPurple,
          const Color(0xFFCE93D8),
          _getCount(summaries, 'CON_CAI'),
          selectedGroup == 'CON_CAI',
        ),
        _buildGroupCard(
          'BAN_BE',
          'Bạn bè',
          Icons.person,
          AppColors.iconBgOrange,
          const Color(0xFFFFB74D),
          _getCount(summaries, 'BAN_BE'),
          selectedGroup == 'BAN_BE',
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  int _getCount(List<GroupSummary> summaries, String type) {
    try {
      return summaries.firstWhere((s) => s.groupType == type).count;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildGroupCard(
      String type, String title, IconData icon, Color bgCol, Color iconCol, int count, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        final provider = context.read<RelativeProvider>();
        provider.setGroupFilter(isSelected ? null : type);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconCol : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgCol,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconCol, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$count người',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelativeItem(RelativeModel relative, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupColor = AppColors.groupTypeColors[relative.groupType] ?? AppColors.primaryLight;
    final initial = relative.name.isNotEmpty ? relative.name[0].toUpperCase() : '?';
    String dobStr = '';
    if (relative.dateOfBirth != null) {
      dobStr = DateFormat('dd/MM').format(relative.dateOfBirth!);
    }

    return GestureDetector(
      onTap: () => context.push('/relatives/${relative.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: groupColor,
              backgroundImage: relative.avatarUrl != null ? NetworkImage(relative.avatarUrl!) : null,
              child: relative.avatarUrl == null
                  ? Text(initial, style: AppTextStyles.heading3.copyWith(color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relative.displayName,
                    style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: groupColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          relative.groupTypeDisplay,
                          style: AppTextStyles.caption.copyWith(color: groupColor, fontSize: 10),
                        ),
                      ),
                      if (dobStr.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          dobStr,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (relative.totalEvents != null && relative.totalEvents! > 0)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${relative.totalEvents}',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.secondaryLight),
                  ),
                  Text(
                    'sự kiện',
                    style: AppTextStyles.caption.copyWith(color: AppColors.secondaryLight),
                  ),
                ],
              ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
    );
  }
}
