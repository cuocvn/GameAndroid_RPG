# Tactical Idle RPG (Game AND) - Android Offline RPG

Game nhập vai chiến thuật một nhân vật (Single Character RPG + Idle Auto Battle + Character Builder) viết bằng Flutter + Dart, hoạt động 100% offline, không cần internet.

---

## 1. Cấu Trúc Dự Án (Project Structure)

```text
game AND/
├── assets/ (hoặc asset/)
│   └── img/
│       ├── sacred_soul_ring.png (Trang bị Huyền Thoại)
│       ├── characters/          (16 chân dung danh tướng & vai trò MID, JUNG, TOP, SP, AD)
│       ├── equipment/           (Áo, giáp, giày, mũ, vòng, quần & sprite tách nền)
│       └── monsters/            (Quái vật & Boss theo 5 vùng đất)
├── lib/
│   ├── data/
│   │   ├── asset_mapping.dart   (Map tài nguyên ảnh, safeImage fallback icon/emoji)
│   │   ├── seed_enemies.dart    (5 vùng đất, hệ thống quái tăng dần & 5 Boss cuối)
│   │   ├── seed_equipment.dart  (Kho trang bị cố định & khởi đầu theo độ hiếm)
│   │   └── seed_skills.dart     (Hệ thống kỹ năng Đánh thường, Chủ động, Bị động)
│   ├── models/
│   │   ├── stats.dart           (5 chỉ số STR, INT, VIT, AGI, LUK & công thức phái sinh)
│   │   ├── skill.dart           (Kỹ năng, chi phí mana, hồi chiêu, tỉ lệ & hiệu ứng)
│   │   ├── equipment.dart       (Trang bị 3 slot: Vũ khí, Giáp, Phụ kiện, 5 cấp Rarity)
│   │   ├── enemy.dart           (Quái vật, máu, công, thủ, tốc đánh, chiêu thức đặc biệt)
│   │   ├── player.dart          (Nhân vật duy nhất, cấp độ, EXP, vàng, trang bị, skill)
│   │   └── battle_state.dart    (Trạng thái chiến đấu, nhật ký, floating damage text)
│   ├── providers/
│   │   └── game_providers.dart  (Riverpod Notifier: cộng điểm, lên cấp, trang bị, mở ải)
│   ├── services/
│   │   ├── battle_service.dart  (Động cơ chiến đấu auto: tính dame, né, crit, burn, mana)
│   │   ├── loot_service.dart    (Tỉ lệ rơi đồ theo độ may mắn LUK, zone và Boss)
│   │   └── save_service.dart    (Lưu tiến trình offline tự động qua Hive + SharedPreferences)
│   ├── screens/
│   │   ├── home_screen.dart     (Chân dung tướng, cấp độ, EXP, vàng, đổi ngoại hình, vào đấu)
│   │   ├── build_screen.dart    (3 tabs: Cộng điểm chỉ số / Đổi trang bị / Nâng skill)
│   │   ├── battle_screen.dart   (Đấu trường auto, máu, mana, chiêu thức, text bay, kết quả)
│   │   └── map_screen.dart      (Bản đồ 5 vùng đất, chọn ải khiêu chiến, mở khóa)
│   ├── widgets/
│   │   ├── hp_bar.dart          (Thanh máu có khiên hấp thụ sát thương & gradient)
│   │   ├── mana_bar.dart        (Thanh năng lượng tự động tích lũy)
│   │   ├── stat_row.dart        (Hiển thị chỉ số + nút cộng điểm tự do)
│   │   ├── equipment_card.dart  (Thẻ trang bị viền màu Rarity, chỉ số & nút Dùng/Bán)
│   │   ├── skill_card.dart      (Thẻ kỹ năng, mô tả, nút Nâng cấp + Trang bị chiến đấu)
│   │   └── damage_text_widget.dart (Hiệu ứng chữ bay sát thương, crit, né, thiêu đốt)
│   └── main.dart                (Điểm khởi chạy ứng dụng, Dark Theme RPG)
└── pubspec.yaml                 (Khai báo dependency và đầy đủ thư mục asset)
```

---

## 2. Bảng Mapping Asset Thực Tế Đã Dùng

| Loại Tài Nguyên | Đường Dẫn Asset | Tên Nhân Vật / Mục / Quái | Mô Tả & Mục Đích Sử Dụng |
|---|---|---|---|
| **Nhân vật chính** | `assets/img/characters/013_Cyra_MID.jpg` | Cyra - Hỏa Thuật Sư | Nhân vật mẫu mặc định, Mid/Mage hệ Hỏa phù hợp với toàn bộ skill lửa |
| **Sprite chiến đấu** | `assets/img/equipment/mid1-removebg-preview.png` | Sprite Trong Suốt | Hiển thị nhân vật trong màn hình giao đấu (Battle Screen) |
| **Dáng đi/đứng** | `assets/img/equipment/mid1-walk.png` | Sprite Pose | Dáng đứng của pháp sư |
| **Chân dung đổi tướng** | `001_Inari_MID.jpg` đến `016_Mai_TOP.jpg` | Inari, Violetta, Valeria, Kaelen, Carmilla, Elysia, Sylvia, Selene, Aurora, Lucia, Marina, Seraphina, Giselle, Freya, Mai | 16 chân dung danh tướng cho người chơi tự do đổi ngoại hình tại Home |
| **Trang bị: Phụ kiện** | `assets/img/sacred_soul_ring.png` | Nhẫn Linh Hồn Thánh Điển | Trang bị Huyền Thoại: +30% Sát thương Lửa, +15 INT, +10 LUK, hồi mana |
| **Trang bị: Phụ kiện** | `assets/img/equipment/trangsuc1.jpg` | Dây Chuyền Cổ Ngữ | Trang bị Sử Thi: +15% Sát thương Lửa, +12 INT, +5% Crit |
| **Trang bị: Phụ kiện** | `assets/img/equipment/vongtay1.jpg` | Vòng Tay Ma Pháp | Trang bị Hiếm: +4.0 Mana Regen/giây, +8 INT |
| **Trang bị: Giáp** | `assets/img/equipment/ao1.jpg` | Áo Choàng Viêm Ma | Trang bị Sử Thi: +300 HP, +22 DEF, +14 VIT |
| **Trang bị: Giáp** | `assets/img/equipment/giay1.jpg` | Chiến Hài Thần Tốc | Trang bị Hiếm: +12 AGI, +150 HP, +10 DEF |
| **Trang bị: Giáp** | `assets/img/equipment/non1.jpg` | Vương Miện Hỏa Long | Trang bị Sử Thi: +200 HP, +15 DEF, +12 INT |
| **Trang bị: Giáp** | `assets/img/equipment/quan1.jpg` | Hộ Thể Thần Quần | Trang bị Hiếm: +220 HP, +14 DEF, +10 VIT |
| **Quái Vùng 1** | `assets/img/monsters/monster1.jpg` | Rừng Ma Quái | Quái rừng: Yêu Tinh, Sói Rừng, Dị Điểu, Trùm Thú Vương Cuồng Nộ |
| **Quái Vùng 2** | `assets/img/monsters/monster2.jpg` | Dung Nham Rực Lửa | Quái nham thạch, Hỏa Báo, Trùm Hỏa Ma Vương Ifrit |
| **Quái Vùng 3** | `assets/img/monsters/monster3.jpg` | Đỉnh Núi Băng Giá | Tiểu Quỷ Băng, Băng Long, Trùm Cổ Thần Băng Giá Ymir |
| **Quái Vùng 4** | `assets/img/monsters/monster4.jpg` | Hầm Ngục Hắc Ám | Kỵ Sĩ Hư Không, Oán Hồn, Huyết Ma, Trùm Minh Vương Hades |
| **Quái Vùng 5** | `assets/img/monsters/monster5.jpg` | Tháp Hủy Diệt | Cận Vệ Hỗn Mang, Tà Thần, Trùm Cuối Tối Thượng Diablo Ma Vương |

*Lưu ý: Mọi ảnh đều có bộ bọc an toàn `AssetMapping.safeImage` tự động dự phòng Icon/Emoji (⚔️, 🔥, 🛡️, 💍, 👑...) nên không bao giờ xảy ra crash nếu thiếu file.*

---

## 3. Các Cơ Chế Cốt Lõi

### 3.1. Hệ Thống 5 Chỉ Số & Công Thức Chiến Đấu
- **STR (Sức mạnh)**: Sát thương vật lý = `STR * 2.5 + Vũ khí`.
- **INT (Trí tuệ)**: Sát thương phép = `INT * 3.0 + Vũ khí`. Mana tối đa = `100 + INT * 2`.
- **VIT (Thể lực)**: Máu tối đa = `VIT * 10 + 100 + Giáp`. Phòng thủ (DEF) = `VIT * 0.5 + Giáp`.
- **AGI (Nhanh nhẹn)**: Giãn cách ra đòn đánh = `1.6 / (1 + AGI * 0.035)` giây (càng cao đánh càng nhanh, tối thiểu 0.5s/đòn). Tỉ lệ né tránh = `AGI * 0.3%` (tối đa 40%).
- **LUK (May mắn)**: Tỉ lệ chí mạng = `LUK * 0.5% + Trang bị + Bị động` (tối đa 50%). Sát thương chí mạng cơ bản = 150% + bonus. Tăng tỉ lệ rơi trang bị Sử Thi/Huyền Thoại.

### 3.2. Hiệu Ứng Combo & Tương Tác Sâu
- **Hỏa Tâm (+15% sát thương lửa)** + **Nhẫn Linh Hồn Thánh Điển (+30% lửa)** → Tổng sát thương Lửa tăng lên **+45%**.
- Khi tung **Thiên Thạch** hoặc **Hỏa Bão**, mục tiêu rơi vào trạng thái **Thiêu đốt (Burn)** trong 3 giây.
- Kỹ năng bị động **Dực Hỏa Thiêu Đốt (+20%)** kích hoạt bổ sung trực tiếp vào mọi đòn đánh trúng mục tiêu đang cháy!
- Khiên Hỏa Giáp tạo màng chắn hấp thụ sát thương trước khi chạm vào HP.

### 3.3. Vòng Lặp Tiến Trình (Game Loop)
```text
CHIẾN ĐẤU AUTO → NHẬN EXP + VÀNG + TRANG BỊ → LÊN CẤP (+3 Stat, +1 Skill) → TÙY BIẾN BUILD MỚI → MỞ KHÓA VÙNG ĐẤT TIẾP THEO
```

---

## 4. Hướng Dẫn Chạy & Build Dự Án

### Cài đặt và chạy trên máy tính / thiết bị:
```bash
# Di chuyển vào thư mục dự án
cd "C:\Users\ADMIN\Desktop\New folder\game AND"

# Tải dependencies
flutter pub get

# Chạy test kiểm thử logic
flutter test

# Chạy trực tiếp trên thiết bị Android / Emulator
flutter run
```

### Build file APK:
```bash
# Build APK Debug
flutter build apk --debug

# Build APK Release tối ưu
flutter build apk --release
```
File APK xuất ra tại: `build/app/outputs/flutter-apk/app-release.apk` (hoặc `app-debug.apk`).
