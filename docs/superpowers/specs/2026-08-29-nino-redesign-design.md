# Thiết kế lại giao diện — "Nino" (coral/mint/amber), toàn bộ 13 màn hình

## Bối cảnh

Ngay trước đợt này, app vừa hoàn thành Phase 1 "Zalo-blue" (`docs/superpowers/specs/2026-08-26-zalo-blue-redesign.md`) — đổi màu chủ đạo sang xanh dương. Chủ app sau đó đã tự thiết kế (Claude Design, project "Mobile app với 8 màn hình", id `4511de75-e68d-4771-acb3-a4f93dfa65b8`) một hệ giao diện đầy đủ hơn nhiều — bảng màu coral/mint/amber/violet mang tên thương hiệu **NINO** (thực chất là bản hoàn thiện của bảng màu gốc *trước* Zalo-blue), có logo chính thức, và phủ **13 màn hình khác nhau** (không phải 8 — tên project đặt từ lúc khởi tạo, trước khi scope phình ra), gồm cả 1 màn hoàn toàn mới (Lịch nghỉ lễ).

Đợt này **thay thế/đảo ngược Zalo-blue**, áp dụng toàn bộ hệ Nino cho cả 13 màn trong một lượt (đã chốt qua brainstorm — xem 3 quyết định ở mục dưới).

Nguồn thiết kế: file `Nino App.dc.html` (toàn bộ 13 màn dạng HTML/CSS tương tác, light+dark, kèm dữ liệu mẫu và logic state) và `Nino Logo.dc.html` (3 phương án logo) trong project Claude Design nói trên, đọc qua MCP `claude_design`. Ảnh export tĩnh tương ứng nằm ở `exports/*.png` trong cùng project, dùng để đối chiếu QA.

## Quyết định đã chốt (qua brainstorm)

1. **Phạm vi**: làm cả 13 màn (light + dark) trong một đợt triển khai, không chia phase.
2. **Logo**: dùng hướng **1a — "Near Ones"** (ô vuông bo góc gradient coral, chữ N, vành tròn ôm quanh, chấm mint góc phải trên — biểu tượng "Never Ignore Near Ones").
3. **Dữ liệu Lịch nghỉ lễ**: tính âm-dương lịch **động** (client-side), không hard-code bảng ngày lễ theo năm.

## Đòn bẩy kỹ thuật hiện có

Kiến trúc theme hiện tại (`AppColors` + `AppTheme`, xem spec Zalo-blue) vẫn dùng được nguyên xi — chỉ thay giá trị token và bổ sung token mới. Quan trọng hơn: model/API đã có sẵn gần hết dữ liệu thiết kế cần — `EventModel` đã có `lunarDay`/`lunarMonth`/`isRecurring`/`recurrenceType`/`reminders`; `RelativeModel` đã có `hobbies`/`heightCm`/`weightKg`/`dateOfBirth`/`location`. **Đây chủ yếu là việc reskin UI**, không cần đổi schema hay endpoint backend, trừ tính năng Lịch nghỉ lễ (mới, tính client-side, không gọi API).

## A. Design tokens (`app_colors.dart` / `app_theme.dart`)

Viết lại hoàn toàn `AppColors` theo bảng dưới (thay vì "sửa giá trị" như Zalo-blue, vì cấu trúc token cũng đổi — thêm `page` tách biệt với `bg`, thêm tông "soft" cho 4 màu nhấn, và gradient dùng thật 2-màu-chéo thay vì gradient phẳng).

| Token | Light | Dark |
|---|---|---|
| `page` (nền ngoài, dùng cho `page`/scaffold container nếu có) | `#EFEDEA` | `#0C0E11` |
| `bg` (nền cuộn chính) | `#FBFAF9` | `#15171B` |
| `card` | `#FFFFFF` | `#1E2126` |
| `txt` (chữ chính) | `#1F2530` | `#F2F4F7` |
| `mut` (chữ phụ) | `#8A94A6` | `#98A0AE` |
| `fnt` (chữ mờ/placeholder) | `#B4BBC7` | `#6C7480` |
| `line` / `line2` (viền) | `rgba(31,37,48,.06)` / `.10` | `rgba(255,255,255,.07)` / `.13` |
| `pri` (coral — thương hiệu chính) | `#FF5A5F` | `#FF7075` |
| `priS` (coral soft, nền icon/pill) | `rgba(255,90,95,.10)` | `rgba(255,112,117,.16)` |
| `mint` | `#2F9E97` | `#5CD0C8` |
| `mintS` | `rgba(78,205,196,.13)` | `rgba(92,208,200,.16)` |
| `amber` | `#D69C13` | `#F0BC48` |
| `amberS` | `rgba(255,201,60,.16)` | `rgba(240,188,72,.16)` |
| `violet` | `#8B6BE0` | `#B79DFF` |
| `violetS` | `rgba(167,139,250,.13)` | `rgba(183,157,255,.18)` |
| `neutS` (nền trung tính nhạt, dùng cho track toggle tắt, badge lặp lại) | `rgba(31,37,48,.05)` | `rgba(255,255,255,.06)` |
| `danger` | `#FF4757` | `#FF6B78` |
| `dangerS` | `rgba(255,71,87,.07)` | `rgba(255,107,120,.12)` |
| `navbg` (nền bottom-nav/sticky-bar, có blur) | `rgba(255,255,255,.94)` | `rgba(30,33,38,.94)` |

**Gradient** (dùng gradient thật, không phẳng như Zalo-blue để lại):
- `primaryGradient` (logo, avatar-badge, CTA nổi bật): `linear-gradient(150deg, #FF8285, #FF5A5F)`.
- Thẻ "sự kiện sắp tới" trên Home: mỗi thẻ một cặp màu riêng theo loại sự kiện (đỏ/coral, amber/cam, violet, mint) — xem mục C (Home).
- Nút "Đăng ký với Google" ở màn Đăng ký: `linear-gradient(100deg, #FF6A70, #4ECDC4)` (coral → mint ngang).
- `darkGradient`/nền phụ khác: giữ nguyên như hiện tại nếu không được thiết kế mới đề cập.

**Avatar người thân/bản thân**: nền là tông "soft" xoay vòng theo 4 màu nhấn (coral/mint/violet/amber), chữ cái đầu tên làm màu đậm tương ứng — không có ảnh đại diện thật thì luôn dùng initials + màu, gán theo `id % 4` (hoặc theo `groupType` nếu muốn nhất quán hơn — quyết định cụ thể để lúc viết plan).

**Radius**: card 18–22px, ô icon-badge vuông bo 10–14px, avatar tròn 50%, pill (tab/badge/nút nhỏ) 999px, bottom-sheet góc trên 24px, khối logo 24–34px.

**Shadow**: 1 lớp mềm — `sh`: light `0 2px 10px rgba(31,37,48,.05)`, dark `0 2px 12px rgba(0,0,0,.45)`, dùng cho hầu hết card. Nút CTA chính (Lưu, Tạo sự kiện...) có shadow màu theo `priS`: `0 8px 20px var(--priS)`.

**Typography**: giữ nguyên Inter (`google_fonts`, đã có sẵn), giữ nguyên cỡ chữ hiện tại của app (không phóng to — nhất quán với quyết định của Zalo-blue). Trọng số 400/500/600/700; tiêu đề lớn dùng letter-spacing âm nhẹ (-0.02 → -0.04em) nếu `TextStyle` hỗ trợ dễ dàng, không bắt buộc pixel-perfect.

## B. Component pattern dùng chung

Tách thành widget tái dùng trong `lib/ui/widgets/nino/` (thư mục mới, tách khỏi `lib/ui/widgets/` hiện có để dễ theo dõi phần thuộc redesign này):

| Widget | Dùng ở |
|---|---|
| `NinoLogo` | Splash, Welcome, header Home (badge nhỏ cạnh "Xin chào"), Tôi (footer "nino · version") |
| `InitialsAvatar` | Home, Người thân (list/chi tiết/form), Tôi |
| `CardRow` (icon vuông + title/meta + trailing) | Home (2 tab), Người thân, Chi tiết người thân (sự kiện), Sự kiện, Thông báo, Lịch nghỉ lễ |
| `PillTabs` | Home (2 tab), Lịch nghỉ lễ (3 filter dạng segmented) |
| `FilterChipsRow` (pill rời, không segmented) | Sự kiện (4 filter) |
| `BottomOptionSheet` | Chọn quan hệ, danh mục sự kiện, lặp lại, nhắc nhở, năm lịch nghỉ lễ, chọn người thân — 1 widget nhận `title` + `List<OptionItem>` |
| `StickySaveBar` | Thêm sự kiện (nút "Lưu sự kiện" dính đáy) |
| `HolidayActionBar` | Lịch nghỉ lễ khi chọn 1 ngày lễ (nút 🔔 + "+ Tạo sự kiện") |
| `DeleteConfirmSheet` | Xoá người thân (tái dùng được cho xoá sự kiện sau này) |
| `NinoToast` | Thông báo nổi đáy màn hình, tự ẩn ~1.9s — thay cho `SnackBarTheme` mặc định vì vị trí/hình dạng khác (pill nổi, không full-width) |
| `SoftToggle` | Track/knob tự vẽ, dùng cho "Cả ngày", "Theo lịch âm", "Chế độ tối", "Đồng bộ Google Calendar" |
| Bottom nav (sửa trực tiếp `bottom_nav_scaffold.dart`, không tách widget mới) | 4 tab, pill-highlight quanh icon khi active, dùng path SVG tương đương từ thiết kế (có thể thay bằng `Icons.*_rounded` tương đương nếu đủ giống, không bắt buộc SVG thô) |

## C. Mapping 13 màn hình → file hiện có / mới

| # | Màn (thiết kế) | File | Ghi chú thiết kế chính |
|---|---|---|---|
| 1 | Chào mừng | `ui/screens/auth/login_screen.dart` | Logo lớn giữa màn, 3 feature card, nút "Tiếp tục với Google" viền, nút "Tạo tài khoản mới" viền đứt nét coral |
| 2 | Đăng ký | `ui/screens/auth/register_screen.dart` | Card "Ý nghĩa NINO" (3 lựa chọn N·I·N·O — chỉ để giải thích thương hiệu, không phải input bắt buộc), 4 perk, nút gradient coral→mint |
| 3 | Home | `ui/screens/home/home_screen.dart` | Header avatar+"Hi, {tên}", carousel ngang "Sự kiện sắp tới" (thẻ gradient theo loại), 2 pill-tab Người thân/Sự kiện của tôi, danh sách card-row |
| 4 | Người thân (list) | `ui/screens/relatives/relative_list_screen.dart` | Card-row avatar+tên+quan hệ+"còn N ngày" |
| 5 | Chi tiết người thân | `ui/screens/relatives/relative_detail_screen.dart` | Avatar lớn giữa, card thông tin (giới tính/ngày sinh/nơi ở/chiều cao/cân nặng/sở thích chip), danh sách sự kiện của người đó |
| 6-7 | Thêm/Sửa người thân | `ui/screens/relatives/relative_form_screen.dart` | Tên **khoá không sửa được** khi ở chế độ Sửa (chỉ đổi quan hệ), input ngày sinh tách 3 ô Ngày/Tháng/Năm (mở bottom-sheet chọn số), chip sở thích thêm được |
| 8 | Sự kiện (list) | `ui/screens/events/event_list_screen.dart` | Entry point vào Lịch nghỉ lễ (card ở đầu), 4 filter pill (Tất cả/Sắp tới/Định kỳ/Âm lịch), group theo nhãn thời gian (vd "Tuần này", "Âm lịch sắp tới", "Tháng tới") |
| 9 | Loại sự kiện | `ui/screens/events/event_type_selection_screen.dart` | 2 lựa chọn lớn: "Liên kết với Người thân" / "Sự kiện cho Bản thân" |
| 10 | Thêm sự kiện | `ui/screens/events/event_form_screen.dart` | Toggle "Cả ngày", toggle "Theo lịch âm" (tự khoá bật nếu danh mục là danh mục âm lịch), lặp lại có tuỳ chỉnh "Mỗi N [Ngày/Tuần/Tháng/Năm]", nhắc nhở dạng chip nhiều lựa chọn, sticky save bar |
| 11 | **Lịch nghỉ lễ** | `ui/screens/holidays/holiday_screen.dart` (**mới**) | Xem mục D |
| 12 | Tôi | `ui/screens/profile/profile_screen.dart` | Avatar+tên+email, stat row (số người thân/sự kiện/hôm nay), toggle Google Calendar, toggle Chế độ tối, menu (thông báo/ngôn ngữ/hiển thị lịch âm/về ứng dụng), nút Đăng xuất |
| 13 | Thông báo | `ui/screens/notifications/notification_screen.dart` | Card-row có border nhấn khi chưa đọc, chấm đỏ, nút "Đọc hết"/"Xoá tất cả", empty-state minh hoạ |

Icon: giữ nguyên chiến lược hiện tại của `EventModel.eventTypeIcon` (map `categoryIcon` string → `IconData` Material `_rounded`) cho icon theo danh mục trong card — **không** đổi sang emoji thô dù thiết kế dùng emoji, vì Material icon nhất quán hơn giữa các thiết bị/font và app đã có sẵn cơ chế này. Icon điều khiển (back/chevron/chevron xuống/switch...) dùng `Icons.*` tương đương path SVG trong thiết kế.

## D. Lịch nghỉ lễ (tính năng mới)

- **Thuật toán âm-dương lịch**: port thuật toán chuyển đổi công khai (Hồ Ngọc Đức, chuẩn múi giờ UTC+7 cho Việt Nam) thành `lib/core/utils/lunar_utils.dart` — hàm `solarToLunar(DateTime)` và `lunarToSolar(...)`, không phụ thuộc package ngoài (giảm rủi ro tương thích).
- **Danh sách ngày lễ**: định nghĩa tĩnh trong code (`lib/core/constants/vn_holidays.dart`) gồm tên, loại (`solar`/`lunar`), và với ngày âm — ngày/tháng âm lịch cố định (vd Tết Nguyên Đán = 01/01 ÂL, Giỗ Tổ = 10/03 ÂL, Trung Thu = 15/08 ÂL); ngày dương quy đổi **tại runtime** bằng `lunar_utils` cho năm đang xem — không hard-code bảng theo từng năm như file mock.
- **Màn hình**: route con của tab Sự kiện, ví dụ `/events/holidays` (không phải tab riêng ở bottom-nav — bottom nav vẫn giữ 4 tab Home/Người thân/Sự kiện/Tôi, khớp thiết kế). Có chọn năm (dropdown/bottom-sheet ±2 năm quanh hiện tại), filter Dương lịch/Âm lịch/Tất cả, thẻ "ngày lễ sắp tới" nổi bật, danh sách còn lại.
- **Tương tác**: chạm 1 ngày lễ → thanh hành động đáy màn hiện nút 🔔 (bật/tắt nhắc — lưu local, chưa cần bảng riêng ở backend cho đợt này, có thể dùng `shared_preferences` lưu set tên ngày lễ đã bật nhắc) và "+ Tạo sự kiện" → điều hướng sang màn Thêm sự kiện, prefill `title`/`date`/`category` phù hợp (dùng `EventProvider` thật, không phải mock).
- Ngoài phạm vi đợt này: đồng bộ nhắc-nhở-ngày-lễ với hệ thống push notification thật (Firebase) — chỉ lưu trạng thái bật/tắt cục bộ, việc bắn notification thật cho ngày lễ sẽ là spec riêng nếu cần.

## E. Logo NINO (hướng 1a)

`lib/ui/widgets/nino/nino_logo.dart`: `Container` bo góc (24–34px tuỳ size) nền `primaryGradient`, chữ "N" trắng đậm, `Stack` thêm 1 vòng tròn viền mờ ôm giữa và 1 chấm mint nhỏ (viền coral) góc phải-trên khi `showBadge: true`. Nhận `size` để dùng lại ở nhiều chỗ (84px Welcome, 52px Đăng ký, 42/17px header Home, 20px footer Tôi).

App icon (asset build native Android/iOS, `flutter_launcher_icons` hoặc export tay) **không nằm trong phạm vi code của spec này** — sẽ export PNG từ cùng thiết kế và cấu hình icon là một bước riêng, nêu rõ trong plan để người dùng duyệt trước khi đụng vào cấu hình build native.

## F. Testing / kiểm thử

- `flutter analyze` sau mỗi cụm màn hình sửa xong (không dồn hết cuối mới chạy).
- Unit test cho `lunar_utils.dart`: đối chiếu các mốc đã biết — Tết Nguyên Đán 2026 = 17/02/2026, 2027 = 06/02/2027, 2028 = 26/01/2028; Giỗ Tổ Hùng Vương (10/03 ÂL) 2026 = 26/04/2026.
- Build + chạy trên emulator Android (đã xác nhận sẵn sàng: Pixel 8, API 35, `flutter run -d emulator-5554`), chụp Home/Thêm sự kiện/Lịch nghỉ lễ ở cả light & dark, so với `exports/03-home.png`, `exports/14-home-dark.png`, `exports/10-them-su-kien.png`, `exports/15-them-su-kien-dark.png`, `exports/11-lich-nghi-le.png`, `exports/16-lich-nghi-le-dark.png`.
- Lướt toàn bộ 13 màn (kể cả các màn ít thay đổi cấu trúc) để bắt lỗi tương phản/overflow sau khi đổi token — đợt này polish sâu tất cả, khác với Zalo-blue chỉ polish Home.

## Rủi ro / lưu ý

- Đảo ngược Zalo-blue nghĩa là mọi nơi đang tham chiếu `AppColors.primaryLight/Dark` v.v. sẽ tự động đổi màu theo — đúng ý đồ, nhưng cần rà lại các `Color(0xFF...)` hard-code rời rạc còn sót (spec Zalo-blue đã ghi nhận vài chỗ ở `home_screen.dart`) vì chúng sẽ *không* tự đổi theo token mới.
- Cấu trúc gradient token đổi từ "2 điểm dừng cùng màu" (Zalo-blue) sang gradient thật nhiều biến thể theo ngữ cảnh (không còn 1 token gradient dùng chung cho mọi header) — các widget đang gán thẳng `AppColors.headerGradient` cần rà lại xem có còn hợp lý theo thiết kế mới hay phải nhận màu theo ngữ cảnh (vd thẻ "sắp tới" trên Home mỗi thẻ 1 gradient riêng).
- `recurrenceType` hiện là `String?` tự do — cần xác nhận giá trị enum thực tế của "Lặp lại tuỳ chỉnh (Mỗi N đơn vị)" khớp thiết kế có được backend hỗ trợ hay chỉ là UI-state chưa gửi lên (làm rõ ở bước viết plan, đọc kỹ `event_form_screen.dart` hiện tại).
- Tên biến `page` là token mới (nền ngoài khung thiết bị trong bản thiết kế web) — trong app thật gần như luôn trùng với `bg` trừ khi có nơi cố tình lộ viền ngoài (hiếm trong mobile thật); cân nhắc bỏ token này nếu không có chỗ dùng thực tế, tránh token thừa — quyết định cụ thể để ở bước plan sau khi rà từng màn.
