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
    final lines = file.readAsLinesSync();
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains(r'\1')) {
        print('$path:${i + 1}: ${lines[i]}');
      }
    }
  }
}
