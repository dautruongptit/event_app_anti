// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Nhắc Sự Kiện';

  @override
  String get home => 'Trang chủ';

  @override
  String get events => 'Sự kiện';

  @override
  String get relatives => 'Người thân';

  @override
  String get notifications => 'Thông báo';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get createEvent => 'Tạo sự kiện';

  @override
  String get editEvent => 'Sửa sự kiện';

  @override
  String get deleteEvent => 'Xóa sự kiện';

  @override
  String get eventTitle => 'Tên sự kiện';

  @override
  String get eventType => 'Loại sự kiện';

  @override
  String get eventDate => 'Ngày diễn ra';

  @override
  String get createRelative => 'Thêm người thân';

  @override
  String get editRelative => 'Sửa người thân';

  @override
  String get deleteRelative => 'Xóa người thân';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get uploadAvatar => 'Tải ảnh đại diện';

  @override
  String get today => 'Hôm nay';

  @override
  String get tomorrow => 'Ngày mai';

  @override
  String daysUntil(Object days) {
    return 'Còn $days ngày';
  }

  @override
  String get upcoming => 'Sắp diễn ra';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String get error => 'Có lỗi xảy ra';

  @override
  String get retry => 'Thử lại';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get birthday => 'Sinh nhật';

  @override
  String get anniversary => 'Kỷ niệm';

  @override
  String get holiday => 'Ngày lễ';

  @override
  String get housing => 'Nhà ở';

  @override
  String get bill => 'Hóa đơn';

  @override
  String get shopping => 'Mua sắm';

  @override
  String get other => 'Khác';

  @override
  String get family => 'Gia đình';

  @override
  String get spouse => 'Vợ/Chồng';

  @override
  String get children => 'Con cái';

  @override
  String get friends => 'Bạn bè';
}
