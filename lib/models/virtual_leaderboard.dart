import 'dart:math';
import '../data/asset_mapping.dart';
import 'arena_rank.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final String title;
  final String avatarAsset;
  final int ap;
  final bool isPlayer;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarAsset,
    required this.ap,
    this.isPlayer = false,
  });

  ArenaRankInfo get rankInfo => ArenaRankInfo.fromAp(ap);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'avatarAsset': avatarAsset,
        'ap': ap,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Vô Danh',
        title: json['title'] as String? ?? 'Dũng Sĩ',
        avatarAsset: json['avatarAsset'] as String? ?? AssetMapping.heroMainPortrait,
        ap: json['ap'] as int? ?? 2000,
      );
}

class VirtualLeaderboard {
  static const List<Map<String, String>> initialAiData = [
    {'name': 'Độc Cô Cầu Bại', 'title': 'Kiếm Ma Vô Địch'},
    {'name': 'Tây Môn Xuy Tuyết', 'title': 'Kiếm Thần Vạn Cổ'},
    {'name': 'Tiêu Phong', 'title': 'Hàng Long Chưởng Môn'},
    {'name': 'Dương Quá', 'title': 'Thần Điêu Hiệp Khách'},
    {'name': 'Lệnh Hồ Xung', 'title': 'Độc Cô Cửu Kiếm'},
    {'name': 'Đoàn Dự', 'title': 'Lục Mạch Thần Kiếm'},
    {'name': 'Hư Trúc', 'title': 'Tiêu Dao Chưởng Môn'},
    {'name': 'Trương Vô Kỵ', 'title': 'Thái Cực Tông Sư'},
    {'name': 'Quách Tĩnh', 'title': 'Bắc Hiệp Đại Nghĩa'},
    {'name': 'Hoàng Dược Sư', 'title': 'Đông Tà Đảo Chủ'},
    {'name': 'Hồng Thất Công', 'title': 'Cửu Chỉ Thần Cái'},
    {'name': 'Âu Dương Phong', 'title': 'Tây Độc Bạch Đà Sơn'},
    {'name': 'Chu Bá Thông', 'title': 'Lão Ngoan Đồng'},
    {'name': 'Vô Danh', 'title': 'Thiên Nhân Hợp Nhất'},
    {'name': 'Bộ Kinh Vân', 'title': 'Bất Khốc Tử Thần'},
    {'name': 'Nhiếp Phong', 'title': 'Phong Trung Chi Thần'},
    {'name': 'Hùng Bá', 'title': 'Thiên Hạ Hội Chủ'},
    {'name': 'Kiếm Ma', 'title': 'Vạn Kiếm Quy Tông'},
    {'name': 'Đao Thần', 'title': 'Ma Đao Xuất Thế'},
    {'name': 'Diệp Cô Thành', 'title': 'Bạch Vân Thành Chủ'},
    {'name': 'Lục Tiểu Phụng', 'title': 'Tứ Dực Linh Hồ'},
    {'name': 'Hoa Mãn Lâu', 'title': 'Lưu Vân Tá Nguyệt'},
    {'name': 'Sở Lưu Hương', 'title': 'Đạo Soái Đạp Nguyệt'},
    {'name': 'Lý Tầm Hoan', 'title': 'Tiểu Lý Phi Đao'},
    {'name': 'A Phi', 'title': 'Khoái Kiếm Thiếu Niên'},
    {'name': 'Yến Thập Tam', 'title': 'Thập Ngũ Kiếm Diệt Thế'},
    {'name': 'Tạ Hiểu Phong', 'title': 'Tam Thiếu Gia'},
    {'name': 'Phó Hồng Tuyết', 'title': 'Bạt Đao Thuật'},
    {'name': 'Tiêu Thập Nhất Lang', 'title': 'Cát Lộc Đao'},
    {'name': 'Phong Thần', 'title': 'Vô Địch Kiếm Khách'},
  ];

  /// Generates initial list of 30 virtual opponents with AP descending from 8000 down to 2000
  static List<LeaderboardEntry> generateInitialAiEntries() {
    final list = <LeaderboardEntry>[];
    final portraits = AssetMapping.characterPortraits.values.toList();

    for (int i = 0; i < initialAiData.length; i++) {
      final info = initialAiData[i];
      // Distribute AP from 8000 down to ~2050
      final baseAp = 8000 - (i * 200) + (Random(i * 13).nextInt(80) - 40);
      final portrait = portraits[i % portraits.length];

      list.add(LeaderboardEntry(
        id: 'ai_lb_$i',
        name: info['name']!,
        title: info['title']!,
        avatarAsset: portrait,
        ap: max(2000, baseAp),
      ));
    }

    list.sort((a, b) => b.ap.compareTo(a.ap));
    return list;
  }

  /// Simulates virtual rank climbing when app opens on new days
  static List<LeaderboardEntry> simulateDailyClimbing(
    List<LeaderboardEntry> current, {
    int daysPassed = 1,
  }) {
    final rand = Random();
    final updated = current.map((entry) {
      if (entry.isPlayer) return entry;
      final gainPerDay = 8 + rand.nextInt(28); // 8-35 AP per day
      final totalGain = (gainPerDay * min(daysPassed, 7)).toInt();
      return LeaderboardEntry(
        id: entry.id,
        name: entry.name,
        title: entry.title,
        avatarAsset: entry.avatarAsset,
        ap: entry.ap + totalGain,
      );
    }).toList();

    updated.sort((a, b) => b.ap.compareTo(a.ap));
    return updated;
  }
}
