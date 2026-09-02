import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/nino/bottom_option_sheet.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/nino_toast.dart';

/// "Thông tin của tôi" — sửa hồ sơ cá nhân. Theo đúng thiết kế
/// `exports/19-sua-ho-so.png` (Claude Design, project "Mobile app với 8
/// màn hình", section isEditMe trong Nino App.dc.html).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Giới tính / Ngày sinh: backend User hiện chưa có các trường này (chỉ
  // Relative mới có — xem RelativeService). Giữ state cục bộ ở đây và
  // KHÔNG gửi lên API khi lưu, để không âm thầm làm người dùng tưởng nhầm
  // là đã lưu trong khi dữ liệu chưa hề được backend lưu trữ. Khi backend
  // bổ sung User.phone/gender/dateOfBirth, nối các trường này vào
  // AuthProvider.updateProfile() như đã làm với fullName.
  String _gender = 'MALE';
  int? _dobDay;
  int? _dobMonth;
  int? _dobYear;

  bool _isInit = false;
  bool _touched = false;

  /// Bề rộng cột nhãn khi nhãn và ô input/select được đặt ngang hàng (xem
  /// [_formRow]) — khớp layout của [RelativeFormScreen] để hai form
  /// "sửa người thân" / "sửa hồ sơ" nhất quán với nhau.
  static const double _formLabelWidth = 88;
  static const double _formFieldOffset = _formLabelWidth + 12;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final user = context.read<AuthProvider>().user;
      _nameController.text = user?.fullName ?? '';
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    final provider = context.read<AuthProvider>();
    final success = await provider.uploadAvatar(File(image.path));
    if (!mounted) return;
    if (success) {
      showNinoToast(context, 'Đã cập nhật ảnh đại diện');
    } else {
      showNinoToast(context, provider.error ?? 'Lỗi khi tải ảnh lên');
    }
  }

  int _maxDobDayFor(int? month, int? year) {
    if (month == null) return 31;
    return DateUtils.getDaysInMonth(year ?? 2024, month);
  }

  void _clampDobDay() {
    if (_dobDay == null || _dobMonth == null || _dobYear == null) return;
    final maxDay = DateUtils.getDaysInMonth(_dobYear!, _dobMonth!);
    if (_dobDay! > maxDay) _dobDay = maxDay;
  }

  /// Chọn ngày sinh theo chuỗi tuần tự ngày → tháng → năm (chọn xong 1 phần
  /// tự mở tiếp sheet phần sau) — khớp đúng luồng `_pickDobStep` của
  /// [RelativeFormScreen] để 1 điểm chạm "Ngày sinh" duy nhất, không phải 3
  /// ô độc lập như trước (2 màn "sửa hồ sơ"/"sửa người thân" giờ đồng nhất).
  Future<void> _pickDatePart(String part) async {
    final now = DateTime.now();
    late final List<int> range;
    late final String title;
    late final int? current;
    if (part == 'day') {
      final maxDay = _maxDobDayFor(_dobMonth, _dobYear);
      range = List.generate(maxDay, (i) => i + 1);
      title = 'Chọn ngày sinh';
      current = _dobDay;
    } else if (part == 'month') {
      range = List.generate(12, (i) => i + 1);
      title = 'Chọn tháng sinh';
      current = _dobMonth;
    } else {
      range = List.generate(90, (i) => now.year - i);
      title = 'Chọn năm sinh';
      current = _dobYear;
    }
    final next = const {'day': 'month', 'month': 'year', 'year': null}[part];
    await showBottomOptionSheet(
      context: context,
      title: title,
      options: range
          .map((v) => NinoOption(
                label: '$v',
                icon: '',
                selected: v == current,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    if (part == 'day') _dobDay = v;
                    if (part == 'month') {
                      _dobMonth = v;
                      _clampDobDay();
                    }
                    if (part == 'year') {
                      _dobYear = v;
                      _clampDobDay();
                    }
                  });
                  if (next != null) _pickDatePart(next);
                },
              ))
          .toList(),
    );
  }

  Future<void> _submit() async {
    setState(() => _touched = true);
    if (!_formKey.currentState!.validate()) {
      showNinoToast(context, 'Vui lòng nhập họ và tên');
      return;
    }
    FocusScope.of(context).unfocus();
    final provider = context.read<AuthProvider>();
    final success = await provider.updateProfile(_nameController.text.trim());
    if (!mounted) return;
    if (success) {
      showNinoToast(context, 'Đã lưu thông tin');
      context.pop();
    } else {
      showNinoToast(context, provider.error ?? 'Lỗi khi lưu thông tin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final danger = isDark ? AppColors.errorDark : AppColors.error;
    final neutSoft = isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight;

    final user = context.watch<AuthProvider>().user;
    final isLoading = context.watch<AuthProvider>().isLoading;
    final nameError = _touched && _nameController.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 14, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                      Text('Thông tin của tôi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                      TextButton(
                        onPressed: isLoading ? null : _submit,
                        child: Text('Lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: pri)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              InitialsAvatar(name: user?.fullName ?? '?', color: pri, softColor: priSoft, radius: 41, avatarUrl: user?.avatarUrl),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: GestureDetector(
                                  onTap: isLoading ? null : _pickAndUploadAvatar,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: card,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: line2),
                                      boxShadow: [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 2))],
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.camera_alt_outlined, size: 15, color: pri),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _formRow(
                          label: Text('Họ tên *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                          field: TextFormField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Nguyễn Minh',
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: pri, width: 1.5)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: nameError ? danger : line2)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                          ),
                        ),
                        if (nameError)
                          Padding(
                            padding: const EdgeInsets.only(left: _formFieldOffset, top: 7),
                            child: Text('⚠ Vui lòng nhập họ và tên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: danger)),
                          ),
                        const SizedBox(height: 18),
                        _formRow(
                          label: Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                          field: GestureDetector(
                            onTap: () => showNinoToast(context, 'Email đăng nhập không sửa được'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                              decoration: BoxDecoration(color: neutSoft, borderRadius: BorderRadius.circular(15), border: Border.all(color: line)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user?.email ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt),
                                    ),
                                  ),
                                  Icon(Icons.lock_outline_rounded, size: 15, color: fnt),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _formRow(
                          label: Text('Điện thoại', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                          field: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(hintText: '0912 345 678'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _formRow(
                          label: Text('Giới tính', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                          field: Row(
                            children: [
                              _genderRadio('MALE', 'Nam', txt, pri),
                              _genderRadio('FEMALE', 'Nữ', txt, pri),
                              _genderRadio('OTHER', 'Khác', txt, pri),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _formRow(
                          label: Text('Ngày sinh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                          field: _dobField(txt, fnt, card, line2),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) Container(color: Colors.black.withValues(alpha: 0.2), child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  /// Đặt [label] và [field] ngang hàng nhau (nhãn cột trái cố định bề rộng,
  /// field chiếm phần còn lại) — khớp [RelativeFormScreen] để hai form
  /// "sửa người thân" / "sửa hồ sơ" nhất quán với nhau.
  Widget _formRow({required Widget label, required Widget field}) {
    return Row(
      children: [
        SizedBox(width: _formLabelWidth, child: label),
        const SizedBox(width: 12),
        Expanded(child: field),
      ],
    );
  }

  Widget _genderRadio(String value, String label, Color txt, Color pri) {
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: value,
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v!),
              activeColor: pri,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 2),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt)),
          ],
        ),
      ),
    );
  }

  /// Ô "Ngày sinh" — 1 ô duy nhất mở sheet chọn tuần tự (xem
  /// [_pickDatePart]), cùng style Container/border với ô Email ngay phía
  /// trên (thay vì 3 ô Ngày/Tháng/Năm tách rời như trước — không đồng nhất
  /// với các field khác trong cùng form).
  Widget _dobField(Color txt, Color fnt, Color card, Color border) {
    final hasDob = _dobDay != null && _dobMonth != null && _dobYear != null;
    return GestureDetector(
      onTap: () => _pickDatePart('day'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(15), border: Border.all(color: border)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasDob
                    ? '${_dobDay.toString().padLeft(2, '0')}/${_dobMonth.toString().padLeft(2, '0')}/$_dobYear'
                    : 'Chọn ngày sinh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: hasDob ? txt : fnt),
              ),
            ),
            Icon(Icons.calendar_today_rounded, size: 15, color: fnt),
          ],
        ),
      ),
    );
  }
}
