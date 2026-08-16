import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/core/utils/date_utils.dart';

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
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _hobbyController = TextEditingController();

  String _groupType = 'GIA_DINH';
  String _gender = 'MALE';
  DateTime? _dateOfBirth;
  List<String> _hobbies = [];
  bool _isInit = false;

  final Map<String, String> _groupTypes = {
    'GIA_DINH': 'Gia đình',
    'VO_CHONG': 'Vợ/Chồng',
    'CON_CAI': 'Con cái',
    'BAN_BE': 'Bạn bè',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.relativeId != null) {
      _loadRelativeData();
      _isInit = true;
    }
  }

  void _loadRelativeData() {
    final provider = context.read<RelativeProvider>();
    final relative = provider.selectedRelative;
    if (relative != null && relative.id == widget.relativeId) {
      _nameController.text = relative.name;
      _nicknameController.text = relative.nickname ?? '';
      _groupType = relative.groupType;
      _gender = relative.gender ?? 'MALE';
      _dateOfBirth = relative.dateOfBirth;
      _locationController.text = relative.location ?? '';
      _heightController.text = relative.heightCm?.toString() ?? '';
      _weightController.text = relative.weightKg?.toString() ?? '';
      _hobbies = List.from(relative.hobbies ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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

  void _removeHobby(String hobby) {
    setState(() {
      _hobbies.remove(hobby);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    final data = {
      'name': _nameController.text.trim(),
      'nickname': _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      'groupType': _groupType,
      'gender': _gender,
      'dateOfBirth': _dateOfBirth?.toIso8601String().split('T').first,
      'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      'heightCm': _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text.trim()),
      'weightKg': _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      'hobbies': _hobbies,
    };

    final provider = context.read<RelativeProvider>();
    bool success = false;
    
    if (widget.relativeId == null) {
      success = await provider.createRelative(data);
    } else {
      success = await provider.updateRelative(widget.relativeId!, data);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.relativeId == null ? 'Đã thêm người thân' : 'Đã cập nhật thông tin')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.relativeId != null;
    final isLoading = context.watch<RelativeProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa người thân' : 'Thêm người thân'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionTitle('Thông tin cơ bản'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Họ tên',
                  icon: Icons.person_outline,
                  maxLength: 100,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nicknameController,
                  label: 'Tên gọi khác / Biệt danh (không bắt buộc)',
                  icon: Icons.badge_outlined,
                  maxLength: 50,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Mối quan hệ'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _groupTypes.entries.map((e) {
                    final isSelected = _groupType == e.key;
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _groupType = e.key);
                      },
                      selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryLight : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Giới tính'),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'MALE', label: Text('Nam')),
                    ButtonSegment(value: 'FEMALE', label: Text('Nữ')),
                    ButtonSegment(value: 'OTHER', label: Text('Khác')),
                  ],
                  selected: {_gender},
                  onSelectionChanged: (set) {
                    setState(() => _gender = set.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.primaryLight.withValues(alpha: 0.2);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.primaryLight;
                      }
                      return isDark ? Colors.white : Colors.black;
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Thông tin thêm'),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ngày sinh'),
                  subtitle: Text(
                    _dateOfBirth != null ? AppDateUtils.formatDate(_dateOfBirth!) : 'Chưa chọn',
                    style: TextStyle(
                      color: _dateOfBirth != null ? AppColors.primaryLight : Colors.grey,
                      fontWeight: _dateOfBirth != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  tileColor: isDark ? Colors.grey[800] : Colors.grey[100],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Địa chỉ',
                  icon: Icons.location_on_outlined,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _heightController,
                        label: 'Chiều cao (cm)',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _weightController,
                        label: 'Cân nặng (kg)',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Sở thích'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _hobbyController,
                        label: 'Thêm sở thích',
                        icon: Icons.star_border,
                        onSubmitted: (_) => _addHobby(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _addHobby,
                      icon: Icon(Icons.add_circle, color: AppColors.primaryLight, size: 32),
                    ),
                  ],
                ),
                if (_hobbies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hobbies.map((hobby) {
                      return InputChip(
                        label: Text(hobby),
                        onDeleted: () => _removeHobby(hobby),
                        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                        deleteIconColor: AppColors.primaryLight,
                        labelStyle: const TextStyle(color: AppColors.primaryLight),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: LinearGradient(
                      colors: const [AppColors.primaryLight, AppColors.primaryLight],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    ),
                    child: Text(
                      isEditing ? 'Cập nhật' : 'Thêm mới',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading2);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
