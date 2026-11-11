class ArenaMatchRecord {
  final String id;
  final String opponentName;
  final String opponentAvatar;
  final bool isWin;
  final int apChange;
  final int timestamp;

  const ArenaMatchRecord({
    required this.id,
    required this.opponentName,
    required this.opponentAvatar,
    required this.isWin,
    required this.apChange,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'opponentName': opponentName,
        'opponentAvatar': opponentAvatar,
        'isWin': isWin,
        'apChange': apChange,
        'timestamp': timestamp,
      };

  factory ArenaMatchRecord.fromJson(Map<String, dynamic> json) => ArenaMatchRecord(
        id: json['id'] as String? ?? '',
        opponentName: json['opponentName'] as String? ?? 'Đối Thủ',
        opponentAvatar: json['opponentAvatar'] as String? ?? '',
        isWin: json['isWin'] as bool? ?? false,
        apChange: json['apChange'] as int? ?? 0,
        timestamp: json['timestamp'] as int? ?? 0,
      );
}
