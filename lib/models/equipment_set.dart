import 'package:flutter/material.dart';

class EquipmentSet {
  final String id;
  final String name;
  final String theme;
  final String icon;
  final Color color;
  final String twoPieceBonusDesc;
  final String threePieceBonusDesc;
  final String dropSource;
  final String shopUnlockDesc;
  final List<String> pieceIds;

  const EquipmentSet({
    required this.id,
    required this.name,
    required this.theme,
    required this.icon,
    required this.color,
    required this.twoPieceBonusDesc,
    required this.threePieceBonusDesc,
    required this.dropSource,
    required this.shopUnlockDesc,
    required this.pieceIds,
  });
}

class EquipmentSetData {
  static const List<EquipmentSet> allSets = [
    EquipmentSet(
      id: 'viem_long',
      name: 'Viêm Long',
      theme: 'Hỏa Diễm / Thiêu Đốt',
      icon: '🔥',
      color: Colors.orangeAccent,
      twoPieceBonusDesc: '+20% Sát thương Lửa',
      threePieceBonusDesc: 'Mỗi đòn đánh thường gây thêm 1 tầng Thiêu Đốt (3s)',
      dropSource: 'Boss Vùng 2 (Hỏa Ma Vương Ifrit) / Tháp Vô Tận tầng chẵn',
      shopUnlockDesc: 'Có tỉ lệ xuất hiện tại Cửa Hàng khi Lv.10+',
      pieceIds: [
        'set_viem_long_weapon',
        'set_viem_long_armor',
        'set_viem_long_acc',
      ],
    ),
    EquipmentSet(
      id: 'han_bang',
      name: 'Hàn Băng',
      theme: 'Băng Tuyết / Làm Chậm',
      icon: '❄️',
      color: Colors.cyanAccent,
      twoPieceBonusDesc: '+15% Kháng Phép nhận vào',
      threePieceBonusDesc: 'Đòn đánh có 20% tỉ lệ làm chậm tốc đánh địch 30% (2s)',
      dropSource: 'Boss Vùng 3 (Cổ Thần Ymir) / Tháp Vô Tận tầng chẵn',
      shopUnlockDesc: 'Có tỉ lệ xuất hiện tại Cửa Hàng khi Lv.15+',
      pieceIds: [
        'set_han_bang_weapon',
        'set_han_bang_armor',
        'set_han_bang_acc',
      ],
    ),
    EquipmentSet(
      id: 'loi_dinh',
      name: 'Lôi Đình',
      theme: 'Lôi Điện / Bạo Kích',
      icon: '⚡',
      color: Colors.amberAccent,
      twoPieceBonusDesc: '+10% Tỉ lệ Chí Mạng',
      threePieceBonusDesc: 'Đòn Chí Mạng giáng thêm 1 tia sét gây 50% sát thương',
      dropSource: 'Boss Vùng 4 (Minh Vương Hades) / Tháp Vô Tận tầng chẵn',
      shopUnlockDesc: 'Có tỉ lệ xuất hiện tại Cửa Hàng khi Lv.20+',
      pieceIds: [
        'set_loi_dinh_weapon',
        'set_loi_dinh_armor',
        'set_loi_dinh_acc',
      ],
    ),
    EquipmentSet(
      id: 'huyet_ma',
      name: 'Huyết Ma',
      theme: 'Huyết Sắc / Hút Máu',
      icon: '🩸',
      color: Colors.redAccent,
      twoPieceBonusDesc: '+10% Hút Máu từ mọi đòn tấn công',
      threePieceBonusDesc: 'Khi Máu dưới 30%, tăng thêm +50% Hút Máu và +20% Sức Tấn Công',
      dropSource: 'Boss Vùng 5 (Diablo) / Tháp Vô Tận tầng chẵn',
      shopUnlockDesc: 'Có tỉ lệ xuất hiện tại Cửa Hàng khi Lv.25+',
      pieceIds: [
        'set_huyet_ma_weapon',
        'set_huyet_ma_armor',
        'set_huyet_ma_acc',
      ],
    ),
  ];

  static EquipmentSet? getById(String id) {
    try {
      return allSets.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
