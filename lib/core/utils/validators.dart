class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email không được để trống';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Phải có ít nhất 1 chữ hoa';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Phải có ít nhất 1 số';
    if (!RegExp(r'[@#\$%]').hasMatch(value)) return 'Phải có ít nhất 1 ký tự đặc biệt (@#\$%)';
    return null;
  }

  static String? required(String? value, [String fieldName = 'Trường này']) {
    if (value == null || value.trim().isEmpty) return '$fieldName không được để trống';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Họ tên không được để trống';
    if (value.trim().length < 2) return 'Họ tên phải có ít nhất 2 ký tự';
    if (value.trim().length > 100) return 'Họ tên không được quá 100 ký tự';
    return null;
  }
}
