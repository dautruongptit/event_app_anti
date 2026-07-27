# 📱 Event App — Ứng Dụng Nhắc Sự Kiện

Ứng dụng di động Flutter quản lý sự kiện cá nhân, người thân và nhận thông báo nhắc nhở. Kết nối với backend Spring Boot REST API.

---

## 📋 Mục Lục

- [Tính năng](#-tính-năng)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt và chạy](#-cài-đặt-và-chạy)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Kiến trúc ứng dụng](#-kiến-trúc-ứng-dụng)
- [Màn hình chính](#-màn-hình-chính)
- [Kết nối Backend](#-kết-nối-backend)
- [Tuỳ chỉnh](#-tuỳ-chỉnh)
- [Xử lý lỗi thường gặp](#-xử-lý-lỗi-thường-gặp)

---

## ✨ Tính năng

### Xác thực
- 🔐 Đăng ký / Đăng nhập bằng email
- 🔄 Tự động refresh JWT token khi hết hạn
- 🚪 Đăng xuất

### Sự kiện
- 📅 Tạo, sửa, xoá sự kiện
- 🏷️ Phân loại: Sinh nhật, Kỷ niệm, Lễ, Nhà ở, Hoá đơn, Mua sắm, Khác
- 🔔 Thiết lập nhắc nhở (trước X ngày/giờ)
- 🔁 Sự kiện lặp lại (hàng năm, hàng tháng, hàng tuần)
- 🔍 Lọc theo loại, tháng, năm, người thân
- ⏳ Đếm ngược đến sự kiện

### Người thân
- 👥 Quản lý danh sách người thân
- 👨‍👩‍👧‍👦 Nhóm: Gia đình, Vợ/Chồng, Con cái, Bạn bè
- 🎂 Theo dõi sinh nhật và sự kiện liên quan
- 🏷️ Sở thích, chiều cao, cân nặng, địa chỉ

### Thông báo
- 🔔 Danh sách thông báo phân trang
- ✅ Đánh dấu đã đọc / đọc tất cả
- 🔢 Badge đếm thông báo chưa đọc

### Giao diện
- 🌙 Chế độ sáng / tối
- 🇻🇳 Hỗ trợ Tiếng Việt và English
- 🎨 Thiết kế Glassmorphism cao cấp
- ✨ Animation mượt mà
- 📱 Responsive trên mọi kích thước màn hình

---

## 🛠 Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter 3.x |
| Ngôn ngữ | Dart 3.x |
| State Management | Provider + ChangeNotifier |
| HTTP Client | Dio 5.x |
| Routing | GoRouter 14.x |
| Font | Google Fonts (Outfit, Inter) |
| Animation | flutter_animate |
| Lưu trữ local | SharedPreferences |
| Ảnh | cached_network_image, image_picker |
| Loading | Shimmer |

---

## 📦 Yêu cầu hệ thống

- **Flutter SDK**: >= 3.0.0
- **Dart SDK**: >= 3.0.0
- **Android Studio** hoặc **VS Code** với Flutter extension
- **Android Emulator** (API 21+) hoặc thiết bị thật
- **Backend**: Spring Boot đang chạy trên port `8080`

---

## 🚀 Cài đặt và chạy

### 1. Clone project

```bash
git clone <your-repo-url>
cd flutter_event_app
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Chạy backend

Đảm bảo Spring Boot backend đang chạy:

```bash
cd ../eventApp
./mvnw spring-boot:run
```

### 4. Chạy ứng dụng

**Trên Android Emulator:**
```bash
flutter run
```
> App tự động kết nối `http://10.0.2.2:8080` (localhost của máy host)

**Trên thiết bị thật:**
1. Mở file `lib/core/constants/api_constants.dart`
2. Đổi `baseUrl` thành IP máy tính của bạn:
```dart
static const String baseUrl = 'http://192.168.1.xxx:8080';
```
3. Chạy:
```bash
flutter run
```

### 5. Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

File APK nằm tại: `build/app/outputs/flutter-apk/`

---

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                    # Điểm khởi chạy, Dependency Injection
├── app.dart                     # MaterialApp + Router + Theme
│
├── core/                        # Lõi ứng dụng
│   ├── constants/
│   │   ├── api_constants.dart   # Đường dẫn API (27 endpoints)
│   │   ├── app_colors.dart      # Bảng màu + gradient
│   │   └── app_text_styles.dart # Typography (Google Fonts)
│   ├── theme/
│   │   ├── app_theme.dart       # Material 3 (sáng/tối)
│   │   └── theme_provider.dart  # Chuyển đổi theme
│   ├── network/
│   │   ├── api_exceptions.dart  # Các loại exception
│   │   └── dio_client.dart      # HTTP client + JWT interceptor
│   ├── router/
│   │   └── app_router.dart      # Điều hướng (GoRouter)
│   ├── l10n/
│   │   ├── app_vi.arb           # Chuỗi Tiếng Việt
│   │   └── app_en.arb           # Chuỗi Tiếng Anh
│   └── utils/
│       ├── date_utils.dart      # Format ngày/giờ
│       └── validators.dart      # Validate form
│
├── models/                      # Data models
│   ├── api_response.dart        # Response wrapper chung
│   ├── auth_response.dart       # JWT tokens
│   ├── user.dart                # Hồ sơ người dùng
│   ├── event.dart               # Sự kiện + Nhắc nhở
│   ├── relative.dart            # Người thân
│   ├── notification_model.dart  # Thông báo
│   ├── home_response.dart       # Dữ liệu trang chủ
│   └── group_summary.dart       # Thống kê nhóm
│
├── services/                    # Gọi API
│   ├── auth_service.dart        # Xác thực
│   ├── user_service.dart        # Hồ sơ
│   ├── event_service.dart       # CRUD sự kiện
│   ├── home_service.dart        # Trang chủ
│   ├── notification_service.dart # Thông báo
│   └── relative_service.dart    # CRUD người thân
│
├── providers/                   # Quản lý trạng thái
│   ├── auth_provider.dart       # Trạng thái xác thực
│   ├── home_provider.dart       # Trạng thái trang chủ
│   ├── event_provider.dart      # Trạng thái sự kiện
│   ├── relative_provider.dart   # Trạng thái người thân
│   ├── notification_provider.dart # Trạng thái thông báo
│   └── locale_provider.dart     # Ngôn ngữ
│
└── ui/                          # Giao diện
    ├── screens/
    │   ├── splash_screen.dart           # Màn hình chờ
    │   ├── auth/
    │   │   ├── login_screen.dart        # Đăng nhập
    │   │   └── register_screen.dart     # Đăng ký
    │   ├── home/
    │   │   └── home_screen.dart         # Trang chủ
    │   ├── events/
    │   │   ├── event_list_screen.dart   # DS sự kiện
    │   │   ├── event_detail_screen.dart # Chi tiết sự kiện
    │   │   └── event_form_screen.dart   # Tạo/sửa sự kiện
    │   ├── relatives/
    │   │   ├── relative_list_screen.dart   # DS người thân
    │   │   ├── relative_detail_screen.dart # Chi tiết người thân
    │   │   └── relative_form_screen.dart   # Tạo/sửa người thân
    │   ├── notifications/
    │   │   └── notification_screen.dart # Thông báo
    │   ├── profile/
    │   │   └── profile_screen.dart      # Hồ sơ cá nhân
    │   └── settings/
    │       └── settings_screen.dart     # Cài đặt
    └── widgets/
        └── bottom_nav_scaffold.dart     # Thanh điều hướng dưới
```

---

## 🏗 Kiến trúc ứng dụng

```
┌──────────────────────────────────────────┐
│              UI (Screens)                │
│  Glassmorphism • Animations • Material 3 │
├──────────────────────────────────────────┤
│         Providers (ChangeNotifier)       │
│    Auth • Event • Relative • Notif       │
├──────────────────────────────────────────┤
│          Services (API Layer)            │
│   Gọi endpoint, parse JSON → Model      │
├──────────────────────────────────────────┤
│         DioClient (HTTP + JWT)           │
│  Auto-refresh token • Error handling     │
├──────────────────────────────────────────┤
│        Spring Boot Backend (:8080)       │
└──────────────────────────────────────────┘
```

### Luồng xác thực JWT

1. Đăng nhập → nhận `accessToken` + `refreshToken`
2. Mỗi request gắn header `Authorization: Bearer <accessToken>`
3. Nếu server trả 401 → DioClient tự động gọi `/auth/refresh`
4. Nếu refresh thành công → lưu token mới → retry request gốc
5. Nếu refresh thất bại → chuyển về màn hình đăng nhập

---

## 📱 Màn hình chính

| Màn hình | Mô tả |
|---|---|
| **Splash** | Animation logo, kiểm tra đăng nhập |
| **Đăng nhập** | Form email/password, glassmorphism card |
| **Đăng ký** | Form họ tên/email/password, validation |
| **Trang chủ** | Lời chào, sự kiện sắp tới, sự kiện của tôi, người thân |
| **DS Sự kiện** | Filter chips (loại), danh sách card màu theo loại |
| **Chi tiết SK** | Header gradient, ngày/giờ, nhắc nhở, ghi chú |
| **Tạo/Sửa SK** | Form đầy đủ: loại, ngày, giờ, lặp lại, nhắc nhở |
| **DS Người thân** | Tìm kiếm, filter nhóm, badge đếm ngược sinh nhật |
| **Chi tiết NT** | Avatar, thông tin grid, sở thích, sự kiện liên quan |
| **Tạo/Sửa NT** | Form: tên, nhóm, giới tính, ngày sinh, sở thích (tag) |
| **Thông báo** | Phân trang, trạng thái đọc/chưa đọc, mark all |
| **Hồ sơ** | Avatar, thống kê, menu cài đặt/đăng xuất |
| **Cài đặt** | Chế độ tối, ngôn ngữ, ảnh đại diện, thông tin tài khoản |

---

## 🔗 Kết nối Backend

### Danh sách API Endpoints (27)

#### Xác thực (Auth)
| Method | Path | Mô tả |
|---|---|---|
| POST | `/api/v1/auth/register` | Đăng ký |
| POST | `/api/v1/auth/login` | Đăng nhập |
| POST | `/api/v1/auth/refresh` | Refresh token |
| POST | `/api/v1/auth/logout` | Đăng xuất |
| PUT | `/api/v1/auth/users/me` | Cập nhật hồ sơ |
| PUT | `/api/v1/auth/users/me/settings` | Cập nhật cài đặt |
| POST | `/api/v1/auth/users/me/avatar` | Upload ảnh đại diện |

#### Người dùng (User)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/api/v1/users/me` | Lấy hồ sơ |

#### Sự kiện (Events)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/api/v1/events` | DS sự kiện (có filter) |
| GET | `/api/v1/events/upcoming` | Sự kiện sắp tới |
| GET | `/api/v1/events/{id}` | Chi tiết sự kiện |
| POST | `/api/v1/events` | Tạo sự kiện |
| PUT | `/api/v1/events/{id}` | Sửa sự kiện |
| DELETE | `/api/v1/events/{id}` | Xoá sự kiện |

#### Trang chủ (Home)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/api/v1/home` | Dữ liệu dashboard |
| GET | `/api/v1/home/my-events` | Sự kiện của tôi |

#### Thông báo (Notifications)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/api/v1/notifications` | DS thông báo (phân trang) |
| GET | `/api/v1/notifications/unread-count` | Số chưa đọc |
| PUT | `/api/v1/notifications/{id}/read` | Đánh dấu đã đọc |
| PUT | `/api/v1/notifications/read-all` | Đọc tất cả |

#### Người thân (Relatives)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/api/v1/relatives` | DS người thân |
| GET | `/api/v1/relatives/groups` | Thống kê nhóm |
| GET | `/api/v1/relatives/{id}` | Chi tiết người thân |
| POST | `/api/v1/relatives` | Tạo người thân |
| PUT | `/api/v1/relatives/{id}` | Sửa người thân |
| DELETE | `/api/v1/relatives/{id}` | Xoá người thân |

---

## ⚙️ Tuỳ chỉnh

### Đổi URL Backend

Mở `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8080'; // Emulator
// static const String baseUrl = 'http://192.168.1.100:8080'; // Thiết bị thật
```

### Đổi màu chủ đạo

Mở `lib/core/constants/app_colors.dart` và thay đổi:
```dart
static const Color primaryLight = Color(0xFF6C5CE7); // Màu chính sáng
static const Color primaryDark = Color(0xFFA29BFE);  // Màu chính tối
```

### Thêm ngôn ngữ

1. Tạo file `lib/core/l10n/app_xx.arb` (xx = mã ngôn ngữ)
2. Thêm locale vào `app.dart`:
```dart
supportedLocales: const [
  Locale('vi'),
  Locale('en'),
  Locale('xx'), // Ngôn ngữ mới
],
```

---

## ❗ Xử lý lỗi thường gặp

| Lỗi | Nguyên nhân | Cách fix |
|---|---|---|
| `SocketException` | Backend chưa chạy | Khởi động Spring Boot trước |
| `Connection refused` | Sai URL hoặc port | Kiểm tra `api_constants.dart` |
| `401 Unauthorized` | Token hết hạn | App tự refresh, nếu lỗi sẽ chuyển về login |
| `10.0.2.2 not working` | Chạy trên thiết bị thật | Đổi sang IP máy tính |
| `flutter pub get` lỗi | Version conflict | Chạy `flutter pub upgrade` |

---

## 📄 License

MIT License

---

> Được tạo bởi AI Assistant • Flutter 3.x • Dart 3.x
# event_app_anti
