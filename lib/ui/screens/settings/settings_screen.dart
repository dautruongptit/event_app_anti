import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/providers/locale_provider.dart';
import 'package:event_app/core/theme/theme_provider.dart';
import 'package:event_app/core/utils/date_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      final provider = context.read<AuthProvider>();
      final success = await provider.uploadAvatar(File(image.path));
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Lỗi khi tải ảnh lên')),
        );
      }
    }
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi họ tên'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Họ tên',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final success = await context.read<AuthProvider>().updateProfile(controller.text.trim());
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật họ tên')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
      ),
      body: authProvider.isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: 'Ảnh đại diện',
                  isDark: isDark,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        child: user?.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: const Text('Thay đổi ảnh đại diện'),
                      trailing: authProvider.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.camera_alt_outlined),
                      onTap: authProvider.isLoading ? null : _pickAndUploadAvatar,
                    ),
                  ],
                ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                
                _buildSection(
                  title: 'Tài khoản',
                  isDark: isDark,
                  children: [
                    ListTile(
                      leading: Icon(Icons.badge_outlined, color: AppColors.primaryLight),
                      title: const Text('Họ tên'),
                      subtitle: Text(user?.fullName ?? ''),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () => _showEditNameDialog(user?.fullName ?? ''),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: AppColors.primaryLight),
                      title: const Text('Email'),
                      subtitle: Text(user?.email ?? ''),
                      trailing: const Icon(Icons.lock_outline, size: 20, color: Colors.grey),
                    ),
                    if (user?.createdAt != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.calendar_today_outlined, color: AppColors.primaryLight),
                        title: const Text('Ngày tham gia'),
                        subtitle: Text(AppDateUtils.formatDate(user!.createdAt)),
                      ),
                    ]
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),
                
                _buildSection(
                  title: 'Giao diện',
                  isDark: isDark,
                  children: [
                    SwitchListTile(
                      title: const Text('Chế độ tối'),
                      secondary: const Icon(Icons.dark_mode_outlined, color: Colors.indigo),
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                _buildSection(
                  title: 'Ngôn ngữ',
                  isDark: isDark,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Tiếng Việt'),
                      value: 'vi',
                      groupValue: localeProvider.locale.languageCode,
                      onChanged: (val) {
                        if (val != null) {
                          localeProvider.setLocale(Locale(val));
                          authProvider.updateSettings(language: val);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('English'),
                      value: 'en',
                      groupValue: localeProvider.locale.languageCode,
                      onChanged: (val) {
                        if (val != null) {
                          localeProvider.setLocale(Locale(val));
                          authProvider.updateSettings(language: val);
                        }
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),
                
                TextButton.icon(
                  onPressed: () {
                    authProvider.logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 16)),
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required bool isDark, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
