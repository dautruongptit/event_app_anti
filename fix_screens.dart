import 'dart:io';

void main() {
  final files = [
    'lib/ui/screens/relatives/relative_list_screen.dart',
    'lib/ui/screens/relatives/relative_detail_screen.dart',
    'lib/ui/screens/relatives/relative_form_screen.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();

    // AppColors
    content = content.replaceAll(RegExp(r'AppColors\.primary(?![a-zA-Z])'), 'AppColors.primaryLight');
    content = content.replaceAll(RegExp(r'AppColors\.secondary(?![a-zA-Z])'), 'AppColors.secondaryLight');
    content = content.replaceAll(RegExp(r'AppColors\.accent(?![a-zA-Z])'), 'AppColors.accentLight');
    content = content.replaceAll('AppColors.backgroundLight', 'AppColors.bgLight');
    content = content.replaceAll('AppColors.backgroundDark', 'AppColors.bgDark');
    content = content.replaceAll('AppColors.cardBackground', 'isDark ? AppColors.cardDark : AppColors.cardLight');

    // AppTextStyles
    content = content.replaceAll('AppTextStyles.bodyLarge', 'AppTextStyles.subtitle');
    content = content.replaceAll('AppTextStyles.bodyMedium', 'AppTextStyles.body');
    content = content.replaceAll('AppTextStyles.subtitle1', 'AppTextStyles.subtitle');
    content = content.replaceAll('AppTextStyles.body2', 'AppTextStyles.bodySmall');

    // opacity -> values
    content = content.replaceAll('.withOpacity(', '.withValues(alpha: ');

    // BorderSide -> Border.all
    content = content.replaceAll(RegExp(r'border:\s*BorderSide\('), 'border: Border.all(');

    // Dropdown value deprecated -> remove it if requested
    content = content.replaceAllMapped(RegExp(r'DropdownButtonFormField<String>\(\s*value:\s*[a-zA-Z0-9_]+,'), (m) => 'DropdownButtonFormField<String>(');

    // Const issues
    content = content.replaceAllMapped(RegExp(r'const\s+(Icon\([^)]*color:\s*AppColors\.[a-zA-Z]+[^)]*\))'), (m) => m.group(1)!);
    content = content.replaceAllMapped(RegExp(r'const\s+(LinearGradient\([^)]*colors:\s*\[[^\]]*AppColors\.[a-zA-Z]+[^\]]*\][^)]*\))'), (m) => m.group(1)!);
    content = content.replaceAllMapped(RegExp(r'const\s+(CircleAvatar\([^)]*backgroundColor:\s*AppColors\.[a-zA-Z]+[^)]*\))'), (m) => m.group(1)!);
    content = content.replaceAllMapped(RegExp(r'const\s+(BoxDecoration\([^)]*color:\s*AppColors\.[a-zA-Z]+[^)]*\))'), (m) => m.group(1)!);
    content = content.replaceAllMapped(RegExp(r'const\s+(Center\([^)]*CircularProgressIndicator\([^)]*color:\s*AppColors\.[a-zA-Z]+[^)]*\)[^)]*\))'), (m) => m.group(1)!);
    content = content.replaceAllMapped(RegExp(r'const\s+(Text\([^)]*color:\s*AppColors\.[a-zA-Z]+[^)]*\))'), (m) => m.group(1)!);

    file.writeAsStringSync(content);
  }
}
