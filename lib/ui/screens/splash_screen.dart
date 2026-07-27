import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();
    
    if (authProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 80,
                color: Colors.white,
              ),
            ).animate()
              .scale(duration: 800.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 800.ms),
            const SizedBox(height: 32),
            Text(
              'Nhạc Sự Kiện',
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontSize: 36,
              ),
            ).animate()
              .fadeIn(delay: 400.ms, duration: 800.ms)
              .slideY(begin: 0.2, end: 0, delay: 400.ms, curve: Curves.easeOut),
            const SizedBox(height: 16),
            Text(
              'Quản lý sự kiện thông minh',
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ).animate()
              .fadeIn(delay: 600.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
