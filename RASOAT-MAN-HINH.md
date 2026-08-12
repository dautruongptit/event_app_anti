# 🔍 Báo cáo rà soát các màn hình — Flutter Event App

> Đối chiếu app Flutter (`flutter_event_app`) với tài liệu backend Spring Boot (`Nhắc Sự Kiện App — Backend`).
> Ngày rà soát: **2026-08-12**. Phạm vi: 15 màn hình + services + models + router.

## 📌 Tóm tắt trạng thái

| Nhóm | Nội dung | Trạng thái |
|------|----------|-----------|
| 🔴 Nhóm 1 | Lỗi chức năng chặn người dùng | ✅ **Đã sửa** |
| 🟠 Nhóm 2 | Lệch hợp đồng API với backend | ⏳ Chờ xử lý (cần response API thật) |
| 🟡 Nhóm 3 | Dark mode hỏng ở nhiều màn hình | ✅ **Đã sửa** |
| ⚪ Nhóm 4 | Nhỏ / dọn dẹp code | ⏳ Chưa xử lý |

---

## 🔴 Nhóm 1 — Lỗi chức năng chặn người dùng ✅ ĐÃ SỬA

| # | Vấn đề | Cách sửa | File |
|---|--------|----------|------|
| 1 | Không đăng ký được (màn Register chỉ có nút Google chết, hiện snackbar "đang phát triển") | Viết lại thành **form email đầy đủ** (họ tên, email, mật khẩu, nhập lại) + validation, gọi `authProvider.register()` → vào `/home` | `lib/ui/screens/auth/register_screen.dart` |
| 1b | Splash không có đường tới đăng nhập email | Nút "Tiếp tục với Google" (chết) → đổi thành **"Đăng nhập"** trỏ `/login` | `lib/ui/screens/splash_screen.dart` |
| 2 | Không thêm được Người thân (route `/relatives/create` không nơi nào gọi) | Thêm **FAB "Thêm người thân"** → `/relatives/create` | `lib/ui/screens/relatives/relative_list_screen.dart` |
| 3 | Nút Sửa/Xóa/Thêm sự kiện ở màn chi tiết Người thân trống (chỉ có comment) | Sửa → `/relatives/:id/edit`; Xóa → dialog xác nhận + `deleteRelative` + pop; Thêm sự kiện → `/events/create?type=relative` | `lib/ui/screens/relatives/relative_detail_screen.dart` |
| 4 | Màn "Chọn loại sự kiện" không dùng được; tab Sự kiện không tạo được sự kiện | Home "Thêm sự kiện" → `/events/new`; thêm **FAB "Thêm sự kiện"** vào tab Sự kiện → `/events/new` | `lib/ui/screens/home/home_screen.dart`, `lib/ui/screens/events/event_list_screen.dart` |

**Kết quả:** luồng đã thông — Splash → Đăng nhập / Tạo tài khoản (email); tab Người thân/Sự kiện đều có nút tạo; màn chi tiết Người thân sửa/xóa/thêm sự kiện được.

**Lưu ý:**
- Đăng ký/đăng nhập hiện đi qua API email/password (`/auth/register`, `/auth/login`). Google login chưa cài (thuộc Nhóm 2).
- Nút "+ Thêm sự kiện" từ màn chi tiết Người thân chưa preselect người thân đó trong form (có thể bổ sung qua query param `relativeId` nếu cần).

---

## 🟠 Nhóm 2 — Lệch hợp đồng API với backend ⏳ CHỜ XỬ LÝ

> Cần đối chiếu với response JSON thật từ backend trước khi sửa (đặc biệt mục 5 & 6).

| # | Vấn đề | Chi tiết | Rủi ro |
|---|--------|----------|--------|
| 5 | **`eventType` (chuỗi cứng) vs `category_id`** | Backend V13/V14 đã "migrate event_type → category_id" + có API `GET /event-categories` (icon/màu động từ DB). Flutter vẫn parse `json['eventType']` và gửi `'eventType'`. | 🔴 Cao — có thể hỏng parse/tạo/sửa sự kiện |
| 6 | **Endpoint hồ sơ sai prefix** | Flutter dùng `/auth/users/me`, `/auth/users/me/settings`, `/auth/users/me/avatar`. Backend liệt kê nhóm User: `/users/me`, `/users/me/settings`, `/users/me/avatar` (không có `/auth`). | 🟠 Có thể 404 khi update hồ sơ/settings/avatar |
| 7 | **Push notification (FCM) chưa cài** | `pubspec.yaml` không có `firebase_core`/`firebase_messaging`. Backend có `/users/me/devices` + `ReminderScheduler` đẩy noti thật. App chỉ đọc list qua `GET /notifications`. | 🟠 Thiếu tính năng lõi "nhắc nhở qua push" |
| 8 | **Google Calendar gọi endpoint chưa tồn tại** | `connectGoogleCalendar` → `/auth/users/me/google-calendar`, nhưng backend để trong Backlog (chưa làm). | 🟡 Gọi sẽ lỗi |
| 9 | **Lịch sử đăng nhập dùng mock** | `login_history_screen.dart` mock data + `// TODO`. Backend đã có `/users/me/login-history`. | 🟡 Dữ liệu giả |
| 10 | **Thiếu hỗ trợ Âm lịch** | Backend có `/lunar-calendar/*`, `LUNAR_YEARLY`, `lunar_day/month` cho ngày giỗ. Flutter chỉ có toggle `isRecurring`, không nhập/hiển thị ngày âm. | 🟡 Thiếu tính năng |

**Việc cần bạn cung cấp:** 1 response mẫu của `GET /api/v1/events` và `PUT /users/me` để xác nhận tên field (`eventType` vs `categoryId`) và prefix đúng.

---

## 🟡 Nhóm 3 — Dark mode ✅ ĐÃ SỬA

Các màn hard-code nền sáng (`bgLight`, `Colors.white`, `grey[200]`) và chữ tối (`textPrimaryLight`) → chế độ tối bị chữ đen/nền trắng. Nay điều kiện hóa theo `isDark`, dùng token dark có sẵn trong theme.

| Màn hình | Sửa gì |
|----------|--------|
| `event_list_screen.dart` | Nền Scaffold, filter chip, card sự kiện (nền `cardDark`/viền `white12`/tiêu đề), popup menu, chữ nhóm tháng, empty state |
| `event_form_screen.dart` | AppBar, nền, 4 heading, ô nhập, container ngày/giờ, khối nhắc nhở + divider, chip người thân & loại sự kiện, nhãn toggle, chữ giờ đã chọn |
| `relative_list_screen.dart` | Nền, ô tìm kiếm, 4 card nhóm, card người thân (nền + viền) |
| `relative_detail_screen.dart` | Nền, AppBar (chữ + icon), card hồ sơ/thông tin, chip sở thích, card sự kiện liên quan |

**Quy ước màu:** `cardDark`/`surfaceDark` (nền), `textPrimaryDark`/`textSecondaryDark` (chữ), `Colors.white12` (viền). Header gradient và chữ trắng trên gradient giữ nguyên.

---

## ⚪ Nhóm 4 — Nhỏ / dọn dẹp code ⏳ CHƯA XỬ LÝ

- **Comment "AI note" còn sót** + màu hard-code `0xFF9C27B0` trong `splash_screen.dart` (dòng ~124) thay vì `AppColors`.
- **Nhãn loại sự kiện không nhất quán**: `event_form_screen.dart` map `HOA_DON→'Đóng tiền điện'`, `NHA_O→'Đóng tiền phòng'`; còn `event.dart` map `HOA_DON→'Hóa đơn'`, `NHA_O→'Nhà ở'`.
- **Logout không đồng nhất**: Profile về `/splash`, Settings về `/login`.
- **Badge "Tôi" ở bottom nav** đếm noti chưa đọc nhưng `unreadCount` chỉ nạp khi mở màn Thông báo → badge trống lúc mới mở app.
- **Deprecation**: `login_screen.dart` dùng `withOpacity`; `Switch.activeColor` và `MaterialStateProperty` (`relative_form_screen.dart`) đã deprecated; `use_build_context_synchronously` ở `event_form_screen.dart`.

---

## ✅ Kiểm tra biên dịch

`flutter analyze` trên toàn bộ file đã sửa: **không có lỗi biên dịch**. Chỉ còn info/warning mức lint có sẵn từ trước (thuộc Nhóm 4).
