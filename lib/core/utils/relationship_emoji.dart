/// Emoji đại diện quan hệ — dùng chung giữa `RelativeModel`/
/// `RelativeDetailModel` (avatar ở màn Người thân) và `EventModel` (chip
/// chủ sở hữu ở màn Sự kiện) — khớp đúng bộ icon dùng ở picker "Quan hệ"
/// (RelativeFormScreen._groupTypes) để mọi nơi hiển thị đồng nhất.
String emojiForGroupType(String groupType) {
  const map = {
    'GIA_DINH': '👨‍👩‍👧',
    'CON_CAI': '👶',
    'BAN_BE': '👤',
    'BAN_THAN': '🧑',
    'ONG': '👴',
    'BA': '👵',
    'BO': '👨',
    'ME': '👩',
    'VO_CHONG': '💍',
    'ANH_CHI_EM': '🧒',
    'CON': '👶',
    'NGUOI_YEU': '💕',
    'NGUOI_THAN': '👤',
  };
  return map[groupType] ?? '👤';
}

/// Tên hiển thị của quan hệ (VD "Vợ (Chồng)", "Mẹ", "Bạn thân") — dùng
/// chung giữa `RelativeModel`/`RelativeDetailModel` (màn Người thân) và
/// `EventModel` (chip chủ sở hữu ở màn Sự kiện, thay cho tên riêng của
/// người thân — xem `EventModel.relativeGroupTypeDisplay`).
String labelForGroupType(String groupType) {
  const map = {
    // Nhóm cũ — chỉ còn để hiển thị đúng cho người thân có sẵn.
    'GIA_DINH': 'Gia đình',
    'CON_CAI': 'Con cái',
    'BAN_BE': 'Bạn bè',
    // Danh sách quan hệ hiện dùng (khớp picker "Quan hệ với bạn").
    'BAN_THAN': 'Bản thân',
    'ONG': 'Ông',
    'BA': 'Bà',
    'BO': 'Bố',
    'ME': 'Mẹ',
    'VO_CHONG': 'Vợ (Chồng)',
    'ANH_CHI_EM': 'Anh/Chị/Em',
    'CON': 'Con Trai/Con Gái',
    'NGUOI_YEU': 'Người yêu',
    'NGUOI_THAN': 'Người Thân',
  };
  return map[groupType] ?? groupType;
}
