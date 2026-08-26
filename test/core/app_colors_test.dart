import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/constants/app_colors.dart';

void main() {
  group('AppColors — Zalo-blue redesign tokens', () {
    test('primary is Zalo blue', () {
      expect(AppColors.primaryLight, const Color(0xFF0068FF));
      expect(AppColors.primaryDark, const Color(0xFF4C9AFF));
    });

    test('secondary is harmonized teal-cyan', () {
      expect(AppColors.secondaryLight, const Color(0xFF00A3B8));
      expect(AppColors.secondaryDark, const Color(0xFF26C6DA));
    });

    test('accent reuses primary (no third hue, stays flat)', () {
      expect(AppColors.accentLight, AppColors.primaryLight);
      expect(AppColors.accentDark, AppColors.primaryDark);
    });

    test('light background is soft blue-gray', () {
      expect(AppColors.bgLight, const Color(0xFFF5F8FC));
    });

    test('decorative gradients are flat (every stop the same color)', () {
      for (final gradient in [
        AppColors.primaryGradient,
        AppColors.headerGradient,
        AppColors.tealGradient,
        AppColors.accentGradient,
      ]) {
        expect(
          gradient.colors.toSet().length,
          1,
          reason: 'Gradient should be flat (all stops same color) per design spec',
        );
      }
    });

    test('event type and group type colors are unchanged (functional, not brand)', () {
      expect(AppColors.eventTypeColors['SINH_NHAT'], const Color(0xFFF87171));
      expect(AppColors.eventTypeColors['LE'], const Color(0xFFFDCB6E));
      expect(AppColors.groupTypeColors['GIA_DINH'], const Color(0xFFF87171));
    });

    test('unrelated tokens are unchanged', () {
      expect(AppColors.bgDark, const Color(0xFF0D1117));
      expect(AppColors.error, const Color(0xFFFF6B6B));
      expect(AppColors.textPrimaryLight, const Color(0xFF212121));
    });
  });
}
