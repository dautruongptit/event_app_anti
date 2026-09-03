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
