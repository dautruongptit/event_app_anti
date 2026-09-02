import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../../providers/home_provider.dart';
import '../../widgets/nino/bottom_option_sheet.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/nino/sticky_action_bars.dart';

class RelativeFormScreen extends StatefulWidget {
  final int? relativeId;
  const RelativeFormScreen({super.key, this.relativeId});

  @override
  State<RelativeFormScreen> createState() => _RelativeFormScreenState();
}

class _RelativeFormScreenState extends State<RelativeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _hobbyController = TextEditingController();

  // Mặc định khi thêm mới: "Người Thân" — trung tính, không như "Bản thân"
  // (chỉ hợp khi tự thêm chính mình) hay các quan hệ cụ thể khác.
  String _groupType = 'NGUOI_THAN';
  String _gender = 'MALE';
  int? _dobDay;
  int? _dobMonth;
  int? _dobYear;
  List<String> _hobbies = [];
  bool _isInit = false;
  bool _touched = false;

  /// Danh sách "Quan hệ" hiện chọn được — khớp đúng ảnh mẫu "Quan hệ với
  /// bạn" (10 lựa chọn cụ thể). Nhóm cũ (GIA_DINH/CON_CAI/BAN_BE) không còn
  /// trong picker này nhưng vẫn hiển thị đúng tên nếu người thân có sẵn còn
  /// mang nhóm cũ (xem `RelativeModel.groupTypeDisplay`) — chỉ không chọn
  /// lại được nữa, tránh vỡ dữ liệu cũ.
  static const Map<String, (String, String)> _groupTypes = {
    'BAN_THAN': ('Bản thân', '🧑'),
    'ONG': ('Ông', '👴'),
    'BA': ('Bà', '👵'),
    'BO': ('Bố', '👨'),
    'ME': ('Mẹ', '👩'),
    'VO_CHONG': ('Vợ (Chồng)', '💍'),
    'ANH_CHI_EM': ('Anh/Chị/Em', '🧒'),
    'CON': ('Con Trai/Con Gái', '👶'),
    'NGUOI_YEU': ('Người yêu', '💕'),
    'NGUOI_THAN': ('Người Thân', '👤'),
  };

  /// Nhóm CŨ (không còn trong picker ở [_groupTypes]) — chỉ để tra hiển thị
  /// khi người thân đang sửa còn mang 1 trong các giá trị này, tránh
  /// `_groupTypes[_groupType]!` ném lỗi null-check.
  static const Map<String, (String, String)> _legacyGroupTypes = {
    'GIA_DINH': ('Gia đình', '👨‍👩‍👧'),
    'CON_CAI': ('Con cái', '👶'),
    'BAN_BE': ('Bạn bè', '👤'),
  };

  (String, String) _groupInfo(String key) =>
      _groupTypes[key] ?? _legacyGroupTypes[key] ?? (key, '❓');

  /// Thụt lề của icon (24) + khoảng cách (12) — dùng để dòng lỗi bên dưới
  /// mỗi dòng thẳng hàng với phần nhãn/giá trị thay vì với icon.
  static const double _rowIndent = 36;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.relativeId != null) {
      _loadRelativeData();
      _isInit = true;
    }
  }

  void _loadRelativeData() {
    final relative = context.read<RelativeProvider>().selectedRelative;
    if (relative != null && relative.id == widget.relativeId) {
      _nameController.text = relative.name;
      _nicknameController.text = relative.nickname ?? '';
      _groupType = relative.groupType;
      _gender = relative.gender ?? 'MALE';
      _dobDay = relative.dateOfBirth?.day;
      _dobMonth = relative.dateOfBirth?.month;
      _dobYear = relative.dateOfBirth?.year;
      _locationController.text = relative.location ?? '';
      _notesController.text = relative.notes ?? '';
      _hobbies = List.from(relative.hobbies ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  void _addHobby() {
    final text = _hobbyController.text.trim();
    if (text.isNotEmpty && !_hobbies.contains(text)) {
      setState(() {
        _hobbies.add(text);
        _hobbyController.clear();
      });
    }
  }

  void _removeHobby(String hobby) => setState(() => _hobbies.remove(hobby));

  /// Số ngày tối đa hợp lệ cho [month], khi năm sinh có thể chưa được chọn.
  /// Nếu chưa biết năm, giả định một năm nhuận (2024) để tháng 2 vẫn cho
  /// phép 29 ngày — tránh việc năm hiện tại (lúc mở app) tình cờ không
  /// nhuận lại âm thầm chặn/hạ một ngày 29/2 hợp lệ trước khi người dùng
  /// kịp chọn năm sinh thật.
  int _maxDobDayFor(int? month, int? year) {
    if (month == null) return 31;
    return DateUtils.getDaysInMonth(year ?? 2024, month);
  }

  /// Nếu ngày sinh đang chọn vượt quá số ngày thực tế của tháng/năm ĐÃ CHỌN
  /// ĐẦY ĐỦ CẢ HAI, hạ xuống ngày cuối cùng hợp lệ của tháng đó thay vì để
  /// DateTime() tự động cuộn sang tháng sau một cách âm thầm. Chỉ validate
  /// chính xác khi đã biết cả năm lẫn tháng — nếu năm chưa chọn, chưa có
  /// bằng chứng thật để hạ một ngày 29/2 đang chọn xuống 28.
  void _clampDobDay() {
    if (_dobDay == null || _dobMonth == null || _dobYear == null) return;
    final maxDay = DateUtils.getDaysInMonth(_dobYear!, _dobMonth!);
    if (_dobDay! > maxDay) _dobDay = maxDay;
  }

  /// Chọn ngày sinh theo chuỗi tuần tự dd → mm → yyyy (chọn xong 1 phần tự
  /// mở tiếp sheet phần sau) — khớp đúng luồng `pickDob`/`sheet:'dob'` của
  /// thiết kế gốc (mỗi lần chỉ 1 điểm chạm "Ngày sinh", không phải 3 ô độc
  /// lập như bản trước). [field] là `'dd'`/`'mm'`/`'yy'`.
  Future<void> _pickDobStep(String field) async {
    final now = DateTime.now();
    late final List<int> range;
    late final String title;
    late final int? current;
    if (field == 'dd') {
      // Số ngày phụ thuộc tháng đã chọn (và năm nếu đã có) để tránh cho
      // phép chọn ngày không tồn tại (vd 31/2) — xem _maxDobDayFor.
      final maxDay = _maxDobDayFor(_dobMonth, _dobYear);
      range = List.generate(maxDay, (i) => i + 1);
      title = 'Chọn ngày sinh';
      current = _dobDay;
    } else if (field == 'mm') {
      range = List.generate(12, (i) => i + 1);
      title = 'Chọn tháng sinh';
      current = _dobMonth;
    } else {
      range = List.generate(90, (i) => now.year - i);
      title = 'Chọn năm sinh';
      current = _dobYear;
    }
    final next = const {'dd': 'mm', 'mm': 'yy', 'yy': null}[field];
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
                    if (field == 'dd') _dobDay = v;
                    if (field == 'mm') {
                      _dobMonth = v;
                      _clampDobDay();
                    }
                    if (field == 'yy') {
                      _dobYear = v;
                      _clampDobDay();
                    }
                  });
                  if (next != null) _pickDobStep(next);
                },
              ))
          .toList(),
    );
  }

  /// Nút "Xoá" chỉ hiện khi đang sửa (không có ở màn Thêm mới) — khớp thiết
  /// kế: `sc-if value="{{ isEdit }}"` bọc nút Xoá ngay trong form Sửa,
  /// không nằm ở màn Chi tiết (xem [RelativeDetailScreen]).
  Future<void> _confirmDelete() async {
    final confirmed = await showDeleteConfirmSheet(
      context: context,
      title: 'Xoá ${_nameController.text.trim()}?',
      message: 'Toàn bộ sự kiện và lời nhắc của người này sẽ bị xoá.',
    );
    if (!confirmed || !mounted) return;
    final success = await context
        .read<RelativeProvider>()
        .deleteRelative(widget.relativeId!);
    if (mounted && success) {
      showNinoToast(context, 'Đã xoá người thân');
      // HomeProvider có snapshot người thân/sự kiện riêng, không tự đồng bộ
      // với RelativeProvider — nếu không refresh ở đây, quay về Home (có
      // thể pop thẳng về Home nếu vào từ đó, không qua chuyển tab) sẽ vẫn
      // hiện dữ liệu cũ.
      context.read<HomeProvider>().refresh();
      context.go('/relatives');
    }
  }

  Future<void> _submit() async {
    setState(() => _touched = true);
    if (!_formKey.currentState!.validate() ||
        _dobDay == null ||
        _dobMonth == null ||
        _dobYear == null) {
      showNinoToast(context, 'Còn thông tin bắt buộc chưa nhập');
      return;
    }
    FocusScope.of(context).unfocus();

    final data = {
      'name': _nameController.text.trim(),
      'nickname': _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      'groupType': _groupType,
      'gender': _gender,
      'dateOfBirth': DateTime(_dobYear!, _dobMonth!, _dobDay!)
          .toIso8601String()
          .split('T')
          .first,
      'location': _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      'hobbies': _hobbies,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };

    final provider = context.read<RelativeProvider>();
    final success = widget.relativeId == null
        ? await provider.createRelative(data)
        : await provider.updateRelative(widget.relativeId!, data);

    if (success && mounted) {
      showNinoToast(context,
          widget.relativeId == null ? 'Đã thêm người thân' : 'Đã lưu thay đổi');
      // HomeProvider có snapshot người thân/sự kiện riêng, không tự đồng bộ
      // với RelativeProvider — nếu không refresh ở đây, quay về Home (có
      // thể pop thẳng về Home nếu vào từ đó, không qua chuyển tab) sẽ vẫn
      // hiện dữ liệu cũ (VD: "Quan hệ" vừa sửa không cập nhật).
      context.read<HomeProvider>().refresh();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.relativeId != null;
    final isLoading = context.watch<RelativeProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final danger = isDark ? AppColors.errorDark : AppColors.error;
    final nameError = _touched && _nameController.text.trim().isEmpty;
    final dobError =
        _touched && (_dobDay == null || _dobMonth == null || _dobYear == null);

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
                      IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.chevron_left_rounded, color: txt)),
                      Text(isEditing ? 'Sửa người thân' : 'Thêm người thân',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: txt)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Xoá chỉ hiện khi đang sửa (không có ở màn Thêm
                          // mới) — trước đây là nút riêng ở cuối form, gộp
                          // lên đây ngang hàng với Lưu để chỉ còn 1 khu vực
                          // hành động duy nhất trên đầu màn.
                          if (isEditing)
                            IconButton(
                              onPressed: isLoading ? null : _confirmDelete,
                              icon: Icon(Icons.delete_outline_rounded, color: danger),
                            ),
                          TextButton(
                            onPressed: isLoading ? null : _submit,
                            child: Text('Lưu',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: pri)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                      children: [
                        _flatRow(
                          icon: Icons.favorite_border_rounded,
                          label: 'Quan hệ *',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          onTap: () => showBottomOptionSheet(
                            context: context,
                            title: 'Quan hệ',
                            // "Bản thân" không cho chọn ở đây (thêm mới lẫn
                            // sửa) — mục người thân là để quản lý NGƯỜI KHÁC,
                            // không phải chính người dùng. Vẫn giữ trong
                            // _groupTypes để hiển thị đúng nếu dữ liệu cũ lỡ
                            // mang giá trị này.
                            options: _groupTypes.entries
                                .where((e) => e.key != 'BAN_THAN')
                                .map((e) => NinoOption(
                                      label: e.value.$1,
                                      icon: e.value.$2,
                                      selected: _groupType == e.key,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        setState(() => _groupType = e.key);
                                      },
                                    ))
                                .toList(),
                          ),
                          trailing:
                              Icon(Icons.edit_outlined, size: 15, color: fnt),
                          value: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_groupInfo(_groupType).$2,
                                  style: const TextStyle(fontSize: 15)),
                              const SizedBox(width: 6),
                              Text(_groupInfo(_groupType).$1,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: txt)),
                            ],
                          ),
                        ),
                        _flatRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Tên *',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          // Backend (RelativeService.update()) không hề khoá đổi
                          // tên khi sửa — cho sửa thoải mái, khớp ảnh thiết kế
                          // (icon bút chì, không phải ổ khoá).
                          trailing:
                              Icon(Icons.edit_outlined, size: 15, color: fnt),
                          value: TextFormField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: txt),
                            decoration: const InputDecoration(
                              isDense: true,
                              filled: false,
                              hintText: 'Nguyễn Thị Lan',
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập tên'
                                : null,
                          ),
                        ),
                        if (nameError)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: _rowIndent, top: 2, bottom: 6),
                            child: Text('⚠ Vui lòng nhập tên',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: danger)),
                          ),
                        _flatRow(
                          key: const Key('dobRow'),
                          icon: Icons.calendar_today_rounded,
                          label: 'Ngày sinh *',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          onTap: () => _pickDobStep('dd'),
                          trailing:
                              Icon(Icons.edit_outlined, size: 15, color: fnt),
                          value: Text(
                            (_dobDay != null &&
                                    _dobMonth != null &&
                                    _dobYear != null)
                                ? '${_dobDay.toString().padLeft(2, '0')}/${_dobMonth.toString().padLeft(2, '0')}/$_dobYear'
                                : 'Chọn ngày sinh',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: dobError ? danger : txt),
                          ),
                        ),
                        if (dobError)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: _rowIndent, top: 2, bottom: 6),
                            child: Text('⚠ Chọn đầy đủ ngày / tháng / năm sinh',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: danger)),
                          ),
                        _flatRow(
                          icon: Icons.male_rounded,
                          label: 'Giới tính',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          value: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _genderRadio('MALE', 'Nam', txt, pri),
                              _genderRadio('FEMALE', 'Nữ', txt, pri),
                              _genderRadio('OTHER', 'Khác', txt, pri),
                            ],
                          ),
                        ),
                        _flatRow(
                          icon: Icons.sell_outlined,
                          label: 'Sở thích',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          value: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ..._hobbies.map((h) => Container(
                                    padding: const EdgeInsets.only(
                                        left: 11, right: 6, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.secondarySoftDark
                                          : AppColors.secondarySoftLight,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(h,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.secondaryDark
                                                    : AppColors
                                                        .secondaryLight)),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => _removeHobby(h),
                                          child: Icon(Icons.close_rounded,
                                              size: 13,
                                              color: isDark
                                                  ? AppColors.secondaryDark
                                                  : AppColors.secondaryLight),
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                width: 130,
                                child: TextField(
                                  controller: _hobbyController,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: txt),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: false,
                                    hintText: 'Thêm sở thích…',
                                    hintStyle: TextStyle(
                                        color: fnt,
                                        fontWeight: FontWeight.w500),
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _addHobby(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _flatRow(
                          icon: Icons.notes_rounded,
                          label: 'Ghi chú',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          value: TextFormField(
                            controller: _notesController,
                            textAlign: TextAlign.right,
                            maxLines: 3,
                            minLines: 1,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: txt),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              hintText: 'Không bắt buộc',
                              hintStyle: TextStyle(
                                  color: fnt, fontWeight: FontWeight.w500),
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        // "Địa chỉ" — backend có hỗ trợ (RelativeModel.location) nhưng
                        // ảnh mẫu 07-sua-nguoi-than.png không có dòng này; giữ lại để
                        // không mất khả năng nhập, thêm cuối danh sách.
                        _flatRow(
                          icon: Icons.location_on_outlined,
                          label: 'Địa chỉ',
                          fnt: fnt,
                          mut: mut,
                          line: line,
                          value: TextFormField(
                            controller: _locationController,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: txt),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              hintText: 'Hà Nội',
                              hintStyle: TextStyle(
                                  color: fnt, fontWeight: FontWeight.w600),
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading)
              Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  /// Một dòng thông tin phẳng: icon nhỏ bên trái + nhãn + giá trị (căn phải,
  /// có thể là input) + chevron nếu [onTap] khác null (ghi đè bằng
  /// [trailing] nếu cần huỷ/thay chevron mặc định) — khớp cấu trúc dòng của
  /// section `isForm` trong thiết kế (không bọc khung box từng field).
  Widget _flatRow({
    required IconData icon,
    required String label,
    required Widget value,
    required Color fnt,
    required Color mut,
    required Color line,
    Key? key,
    VoidCallback? onTap,
    Widget? trailing,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    final end = trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right_rounded, size: 18, color: fnt)
            : const SizedBox.shrink());
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: line))),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(width: 24, child: Icon(icon, size: 20, color: fnt)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: mut)),
          const SizedBox(width: 8),
          Expanded(
              child: Align(alignment: Alignment.centerRight, child: value)),
          const SizedBox(width: 6),
          SizedBox(width: 18, child: end),
        ],
      ),
    );
    if (onTap == null) return KeyedSubtree(key: key, child: content);
    return InkWell(key: key, onTap: onTap, child: content);
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
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: txt)),
          ],
        ),
      ),
    );
  }

}
