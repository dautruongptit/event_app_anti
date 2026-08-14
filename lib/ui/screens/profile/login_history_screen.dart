import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/models/login_history.dart';
import 'package:event_app/providers/auth_provider.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  late Future<List<LoginHistoryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuthProvider>().fetchLoginHistory();
  }

  Future<void> _reload() async {
    setState(() {
      _future = context.read<AuthProvider>().fetchLoginHistory();
    });
    await _future;
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${local.year} $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử đăng nhập', style: AppTextStyles.heading3),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<LoginHistoryModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.error_outline, size: 48, color: Colors.grey.withValues(alpha: 0.6)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Không tải được lịch sử đăng nhập.\nKéo xuống để thử lại.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              );
            }

            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Chưa có lịch sử đăng nhập',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = history[index];
                final color = item.isSuccess ? AppColors.success : AppColors.error;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.phone_android_rounded, color: color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.deviceLabel, style: AppTextStyles.subtitle),
                            const SizedBox(height: 4),
                            if (item.ipAddress != null)
                              Text(
                                'IP: ${item.ipAddress}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            Text(
                              _formatDate(item.loginAt),
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isSuccess ? '✓' : '✕',
                          style: TextStyle(color: color, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
