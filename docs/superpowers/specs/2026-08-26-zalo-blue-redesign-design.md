# Thiết kế lại giao diện — "Zalo-blue" (Phase 1: Design system + Home)

## Bối cảnh

App NINO (Nhắc Sự Kiện) hiện dùng phong cách gradient cam san hô ↔ teal, tương đối "Tây hoá". Người dùng (chủ app) muốn giao diện đơn giản, dễ dùng hơn cho gia đình nhiều thế hệ (kể cả người lớn tuổi), thẩm mỹ quen thuộc với người Việt, và giữ nguyên thương hiệu NINO (chỉ đổi giao diện, không đổi tên/tagline).

Qua brainstorm có visual companion, đã chốt:
- Hướng màu: **kiểu Zalo** — xanh dương trên nền trắng/xám nhạt, phẳng, tối giản, độ tương phản cao, rất quen thuộc với người Việt (gần như ai cũng dùng Zalo).
- Cỡ chữ/kích thước hiện tại: **giữ nguyên**, không phóng to (ưu tiên gọn, hiện được nhiều nội dung — mục tiêu "dễ dùng cho người lớn tuổi" sẽ đạt qua độ tương phản/rõ ràng thay vì cỡ chữ).
- Tên "NINO" và cấu trúc màn hình: **giữ nguyên**, chỉ đổi màu sắc/độ phẳng.
- Đã duyệt mockup Home hoàn chỉnh theo hướng này (xem lịch sử hội thoại / thư mục `.superpowers/brainstorm/` nếu còn).

## Đòn bẩy kỹ thuật

Toàn bộ 14 màn hình đọc màu qua `lib/core/constants/app_colors.dart` (`AppColors`), và `lib/core/theme/app_theme.dart` (`AppTheme`) đã centralize style cho `ElevatedButton`/`Card`/`InputDecoration`/`BottomNavigationBar`/`Chip`/`Dialog`/`SnackBar` — tất cả đều tham chiếu `AppColors`. Đặc biệt, các gradient token (`headerGradient`, `primaryGradient`, `tealGradient`, `accentGradient`) được dùng chung cho phần "header" trang trí ở **Home, Profile, Event List, Relative List, Login, Event Detail, Event Form** — nên đổi giá trị các token này lan ra gần như cả app cùng lúc, không cần sửa từng file.

## Phạm vi Phase 1 (đợt này)

- Sửa `app_colors.dart`: định nghĩa lại token màu theo bảng dưới.
- Sửa `app_theme.dart` nếu cần khớp lại `ColorScheme`/border input theo token mới (khả năng không cần đổi cấu trúc, chỉ tự động ăn theo `AppColors`).
- Verify kỹ trên **Home** — layout/cấu trúc giữ nguyên, chỉ đổi màu — khớp với mockup đã duyệt.
- Lướt nhanh các màn còn lại (không sửa sâu) để bắt lỗi tương phản/hard-coded color rõ ràng nếu có, nhưng **không** đi sâu polish từng màn — việc đó thuộc đợt "lan ra" sau (spec/plan riêng).

Ngoài phạm vi (không làm ở đợt này): đổi cấu trúc/IA màn hình, đổi cỡ chữ, đổi tên thương hiệu, polish chi tiết cho 13 màn còn lại ngoài Home.

## Bảng màu mới

| Token | Giá trị cũ | Giá trị mới | Ghi chú |
|---|---|---|---|
| `primaryLight` | `#F87171` (cam san hô) | `#0068FF` | Nút bấm, tab active, link, icon chính |
| `primaryDark` | `#EF5350` | `#4C9AFF` | Bản tối — sáng hơn để đủ tương phản trên nền tối |
| `secondaryLight` | `#26A69A` (teal) | `#00A3B8` | Giữ tinh thần "màu phụ" nhưng hài hoà với xanh dương |
| `secondaryDark` | `#4DB6AC` | `#26C6DA` | |
| `accentLight` | `#FD79A8` (hồng) | `#0068FF` (= primary) | Bỏ hue thứ 3, dùng lại primary cho nhất quán/phẳng |
| `accentDark` | `#E84393` | `#4C9AFF` (= primaryDark) | |
| `bgLight` | `#FFF8F8` (hồng nhạt) | `#F5F8FC` | Nền xám-xanh nhạt kiểu Zalo |
| `bgDark` | `#0D1117` | *(giữ nguyên)* | Không đổi — đã trung tính, đủ tốt |
| `surfaceLight` / `cardLight` | `#FFFFFF` | *(giữ nguyên)* | |
| `surfaceDark` / `cardDark` | | *(giữ nguyên)* | |
| Text colors | | *(giữ nguyên)* | Đã trung tính, đủ tương phản |
| `error` / `success` / `warning` / `info` | | *(giữ nguyên)* | Màu trạng thái, không liên quan bảng màu thương hiệu |

**Gradient → phẳng (không đổi cấu trúc code, chỉ đổi điểm dừng màu):**

| Token | Giá trị mới |
|---|---|
| `primaryGradient` | 2 điểm dừng cùng `#0068FF` (phẳng) |
| `headerGradient` | 2 điểm dừng cùng `#0068FF` (phẳng) — thay 4-stop cam↔teal cũ |
| `tealGradient` | 2 điểm dừng cùng `#00A3B8` (phẳng) |
| `accentGradient` | 2 điểm dừng cùng `#0068FF` (phẳng) |
| `darkGradient` | *(giữ nguyên)* |

Lý do dùng "gradient 2 điểm dừng cùng màu" thay vì đổi từ `gradient:` sang `color:` trong từng widget: giữ nguyên API/cấu trúc `BoxDecoration` ở toàn bộ 8+ file đang dùng các token này, giảm diện thay đổi và rủi ro, vẫn ra đúng hiệu ứng phẳng như mockup đã duyệt.

**Màu phân loại (event type / group type):** giữ nguyên phần lớn — đây là màu chức năng để phân biệt danh mục (sinh nhật=đỏ, lễ=vàng, khác=xám...), không phải màu thương hiệu; đỏ cho sinh nhật vẫn hợp thẩm mỹ Việt. Không nằm trong phạm vi sửa của spec này.

## Kiểm thử

Thay đổi thuần hình ảnh — không cần test tự động mới:
- `flutter analyze` sau khi sửa `app_colors.dart`/`app_theme.dart` — đảm bảo không lỗi biên dịch (đặc biệt các `const` constructor tham chiếu màu).
- Build + chạy trên emulator, chụp màn hình Home ở cả light & dark mode, so với mockup đã duyệt.
- Lướt nhanh Login, Event List, Relative List, Profile, Event Detail để xác nhận header/nút đổi màu đúng, không bị vỡ layout/tương phản.

## Rủi ro / lưu ý

- `AppColors.primaryLight` v.v. được khai báo `const` — một số nơi dùng trong `const Icon(..., color: AppColors.secondaryLight)`. Đổi giá trị hex không ảnh hưởng tới việc đây có còn là hằng số hợp lệ hay không (vẫn là `Color` const), nên an toàn.
- Cần rà lại các `Color(0xFF...)` hard-code rời rạc (đã thấy vài chỗ ở `home_screen.dart` dùng `Color(0xFFE0E0E0)`/`Color(0xFF9E9E9E)` cho viền/chữ xám) — cân nhắc thay bằng token nếu tiện, nhưng không bắt buộc phải dọn hết trong đợt này.
