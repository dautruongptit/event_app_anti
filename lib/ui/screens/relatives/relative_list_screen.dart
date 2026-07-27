import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

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
  Timer? _debounce;
  final List<String> _groupTypes = ['', 'GIA_DINH', 'VO_CHONG', 'CON_CAI', 'BAN_BE'];
  final List<String> _groupLabels = ['Tất cả', 'Gia đình', 'Vợ/Chồng', 'Con cái', 'Bạn bè'];

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
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<RelativeProvider>().setSearchQuery(query.isEmpty ? null : query);
    });
  }

  Color _getGroupColor(String? groupType) {
    switch (groupType) {
      case 'GIA_DINH':
        return AppColors.primaryLight;
      case 'VO_CHONG':
        return Colors.pink;
      case 'CON_CAI':
        return Colors.green;
      case 'BAN_BE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelativeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(provider, isDark),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.loadRelatives();
                  await provider.loadGroupSummary();
                },
                child: _buildContent(provider, isDark),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/relatives/create'),
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(),
    );
  }

  Widget _buildHeader(RelativeProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
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
          Text('Người thân', style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          _buildSearchBox(isDark),
          const SizedBox(height: 16),
          _buildFilterChips(provider, isDark),
          const SizedBox(height: 16),
          _buildGroupSummary(provider, isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBox(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm người thân...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips(RelativeProvider provider, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_groupTypes.length, (index) {
          final type = _groupTypes[index];
          final label = _groupLabels[index];
          final isSelected = (provider.filterGroupType ?? '') == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                provider.setGroupFilter(type.isEmpty ? null : type);
              },
              selectedColor: _getGroupColor(type).withValues(alpha: 0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? _getGroupColor(type) : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? _getGroupColor(type) : Colors.transparent,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGroupSummary(RelativeProvider provider, bool isDark) {
    if (provider.groupSummary.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.groupSummary.map((summary) {
          final color = _getGroupColor(summary.groupType);
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGroupLabel(summary.groupType),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${summary.count}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _getGroupLabel(String type) {
    final idx = _groupTypes.indexOf(type);
    if (idx != -1) return _groupLabels[idx];
    return type;
  }

  Widget _buildContent(RelativeProvider provider, bool isDark) {
    if (provider.isLoading && provider.relatives.isEmpty) {
      return _buildShimmerLoading();
    }

    if (provider.error != null && provider.relatives.isEmpty) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (provider.relatives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có người thân nào',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.relatives.length,
      itemBuilder: (context, index) {
        final relative = provider.relatives[index];
        return _buildRelativeCard(relative, isDark)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 50 * index))
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildRelativeCard(RelativeModel relative, bool isDark) {
    final color = _getGroupColor(relative.groupType);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => context.push('/relatives/${relative.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${relative.id}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withValues(alpha: 0.2),
                  backgroundImage: relative.avatarUrl != null ? NetworkImage(relative.avatarUrl!) : null,
                  child: relative.avatarUrl == null
                      ? Text(
                          relative.name.isNotEmpty ? relative.name[0].toUpperCase() : '?',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            relative.name,
                            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (relative.nickname != null && relative.nickname!.isNotEmpty)
                      Text('(${relative.nickname})', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            relative.groupTypeDisplay,
                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (relative.daysUntilBirthday != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.cake, size: 14, color: AppColors.accentLight),
                          const SizedBox(width: 4),
                          Text(
                            relative.birthdayText,
                            style: TextStyle(fontSize: 12, color: AppColors.accentLight, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                    if (relative.nextEventTitle != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.event, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              relative.nextEventTitle!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
