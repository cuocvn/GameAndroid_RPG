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
│   │   ├── seed_enemies.dart    (5 vùng đất, quái scale HP x1.6, ATK x1.4 & 5 Boss cuối)
│   │   ├── seed_equipment.dart  (Kho trang bị cố định & khởi đầu theo độ hiếm)
│   │   └── seed_skills.dart     (21 kỹ năng: 5 đánh thường, 8 chủ động, 8 bị động)
│   ├── models/
│   │   ├── stats.dart           (5 chỉ số STR, INT, VIT, AGI, LUK & công thức phái sinh)
│   │   ├── skill.dart           (Kỹ năng, chi phí mana, hồi chiêu, hồi máu, tỉ lệ & hiệu ứng)
│   │   ├── equipment.dart       (Trang bị 3 slot, cấp nâng cấp ⚡ +10%/cấp, 5 cấp Rarity)
│   │   ├── enemy.dart           (Kháng phép 40%, Phản đòn 20%, Hồi máu 5%/s theo vùng)
│   │   ├── player.dart          (Nhân vật duy nhất, EXP, vàng, đá quý 💎, mốc ải, tutorial)
│   │   └── battle_state.dart    (Trạng thái chiến đấu, banner chiêu thức, floating damage text)
│   ├── providers/
│   │   └── game_providers.dart  (Riverpod Notifier: nâng cấp đồ ⚡, mua shop, mốc ải, auto-save)
│   ├── services/
│   │   ├── battle_service.dart  (Động cơ chiến đấu auto: tính dame, né, crit, burn, mana, kháng/phản)
│   │   ├── loot_service.dart    (Tỉ lệ rơi đồ giảm 18%, Rare+ chỉ từ Boss Vùng 3+, cap LUK 50%)
│   │   └── save_service.dart    (Lưu tiến trình offline tự động qua Hive + SharedPreferences)
│   ├── screens/
│   │   ├── home_screen.dart     (Giao diện gọn gàng, level, HP, ATK, DEF, tiến độ mốc ải, vào đấu)
│   │   ├── build_screen.dart    (3 tabs: Chỉ số / Kho đồ & Nâng cấp ⚡ / Bảng Kỹ Năng)
│   │   ├── shop_screen.dart     (Cửa hàng 4 tab: Vũ khí, Giáp, Phụ kiện, Đá Quý 💎, reset 30p)
│   │   ├── battle_screen.dart   (Đấu trường auto, banner chiêu thức 0.8s, thanh skill, text bay)
│   │   └── map_screen.dart      (Bản đồ 5 vùng đất, chọn ải khiêu chiến, mở khóa)
│   ├── widgets/
│   │   ├── hp_bar.dart          (Thanh máu có tích hợp khiên hấp thụ Shield & gradient)
│   │   ├── mana_bar.dart        (Thanh năng lượng tự động tích lũy)
│   │   ├── stat_row.dart        (Hiển thị chỉ số + nút cộng điểm tự do)
│   │   ├── equipment_card.dart  (Thẻ trang bị hiển thị cấp nâng cấp ⚡, nút Mặc/Tháo/Bán/Nâng)
│   │   ├── skill_card.dart      (Thẻ kỹ năng, mô tả, nút Nâng cấp + Trang bị chiến đấu)
│   │   └── damage_text_widget.dart (Hiệu ứng chữ bay sát thương, crit, né, thiêu đốt, phản đòn)
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
| **Phụ kiện huyền thoại** | `assets/img/sacred_soul_ring.png` | Nhẫn Linh Hồn Thánh Điển | Rơi từ Boss: +30% Sát thương Lửa, +15 INT, +10 LUK, hồi mana |
| **Phụ kiện sử thi** | `assets/img/equipment/trangsuc1.jpg` | Dây Chuyền Cổ Ngữ | Trang bị Sử Thi: +15% Sát thương Lửa, +12 INT, +5% Crit |
| **Phụ kiện hiếm** | `assets/img/equipment/vongtay1.jpg` | Vòng Tay Ma Pháp | Trang bị Hiếm: +4.0 Mana hồi phục/giây, +8 INT |
| **Áo giáp sử thi** | `assets/img/equipment/ao1.jpg` | Áo Choàng Viêm Ma | Trang bị Sử Thi: +300 HP, +22 DEF, +14 VIT |
| **Giày tốc độ** | `assets/img/equipment/giay1.jpg` | Chiến Hài Thần Tốc | Trang bị Hiếm: +12 AGI, +150 HP, +10 DEF |
| **Mũ sử thi** | `assets/img/equipment/non1.jpg` | Vương Miện Hỏa Long | Trang bị Sử Thi: +200 HP, +15 DEF, +12 INT |
| **Quần hộ thể** | `assets/img/equipment/quan1.jpg` | Hộ Thể Thần Quần | Trang bị Hiếm: +220 HP, +14 DEF, +10 VIT |
| **Quái Vùng 1** | `assets/img/monsters/monster1.jpg` | Rừng Ma Quái | Quái rừng: Yêu Tinh, Sói Rừng, Dị Điểu, Trùm Thú Vương Cuồng Nộ (4x HP, 1.8x ATK) |
| **Quái Vùng 2** | `assets/img/monsters/monster2.jpg` | Dung Nham Rực Lửa | Ấu Trùng Nham Thạch, Hỏa Báo, Trùm Hỏa Ma Vương Ifrit |
| **Quái Vùng 3** | `assets/img/monsters/monster3.jpg` | Đỉnh Núi Băng Giá | [Kháng Phép 40%] Băng Long, Trùm Cổ Thần Ymir |
| **Quái Vùng 4** | `assets/img/monsters/monster4.jpg` | Hầm Ngục Hắc Ám | [Phản Đòn 20%] Huyết Ma, Trùm Minh Vương Hades |
| **Quái Vùng 5** | `assets/img/monsters/monster5.jpg` | Tháp Hủy Diệt | [Hồi Máu 5%/s] Ác Ma, Trùm Cuối Diablo Ma Vương |

---

## 3. Các Cải Tiến Cốt Lõi Vừa Cập Nhật

### 3.1. Cân Bằng Độ Khó & Tỉ Lệ Rơi Đồ
- **Quái vật theo vùng**: HP vùng sau = Vùng trước * 1.6; ATK vùng sau = Vùng trước * 1.4. Boss ải có HP gấp 4 lần và ATK gấp 1.8 lần quái thường.
- **Cơ chế buộc đổi build**:
  - Vùng 3: Kháng phép 40% (buộc phải phối hợp đòn đánh vật lý hoặc xuyên giáp).
  - Vùng 4: Phản đòn 20% sát thương phải chịu ngược lại vào nhân vật.
  - Vùng 5: Hồi phục 5% Máu tối đa mỗi giây liên tục.
- **Rơi đồ**: Quái thường giảm tỉ lệ rơi còn 18% (cap tối đa 50% khi build max LUK). Trang bị cấp Rare trở lên **chỉ rơi từ Boss Vùng 3 trở đi**.
- **Điểm chỉ số**: Khi lên cấp nhận **+2 điểm chỉ số** (thay vì 3) và **+1 điểm kỹ năng**. Trang bị ban đầu yếu, đòi hỏi tính toán chiến thuật.

### 3.2. Đơn Giản Hóa Onboarding
- **Mở khóa theo tiến trình Level**:
  - Level 1-3: Màn Home + Nút "Chiến đấu" + Tab "Chỉ số".
  - Level 4: Mở khóa Tab "Kỹ năng".
  - Level 5: Mở khóa Tab "Trang bị" + "Cửa Hàng (Shop)".
  - Level 6: Mở khóa "Bản đồ (Map)" chọn vùng đất.
- **Tutorial 1 lần nhẹ nhàng**:
  - Popup khi lần đầu vào Home ("Bấm Chiến Đấu để bắt đầu").
  - Popup khi lần đầu thắng ải ("Nhận được điểm chỉ số — vào tab Chỉ số để cộng").
  - Popup khi lần đầu nhặt đồ ("Vào tab Trang bị để mặc hoặc nâng cấp").
- **Màn Home tinh giản**: Chỉ hiển thị gọn gàng Level, Máu, Công, Giáp, Mana, Vàng, Đá Quý và thanh tiến độ mốc ải.

### 3.3. Cửa Hàng Trang Bị (Shop Screen) & Hệ Thống Nâng Cấp ⚡
- **4 Danh mục tab**:
  - **Vũ khí** (⚔️)
  - **Giáp** (🛡️)
  - **Phụ kiện** (💍)
  - **Đá quý / Nguyên liệu** (💎)
- **Cơ chế**:
  - Bán 6 món ngẫu nhiên mỗi tab, tự động làm mới mỗi 30 phút hoặc dùng 50 Vàng để đổi hàng mới.
  - Phẩm cấp trang bị bán theo Level người chơi (Lv 5-10: Thường/Cao cấp, Lv 11-20: thêm Hiếm, Lv 21+: thêm Sử thi).
  - Có mũi tên ▲▼ so sánh chỉ số trực tiếp với trang bị đang mặc.
- **Nâng cấp trang bị ⚡**:
  - Tiêu tốn **Vàng + Đá Quý (💎)**.
  - Mỗi cấp tăng **+10% chỉ số gốc** (tối đa 5 cấp, đồ Sử Thi/Huyền Thoại tối đa 10 cấp).
- **Quản lý Kho đồ**:
  - Lọc theo Vũ khí / Giáp / Phụ kiện.
  - Nút **"Bán đồ thường"** (bán toàn bộ Common/Uncommon nhanh chóng).

### 3.4. Giao Diện Chiến Đấu Mới & Mốc Thưởng Kỹ Năng
- **Hiển thị trực quan trong trận**:
  - Đánh thường: hiện tên chiêu thức (vd "Hỏa Cầu", "Băng Tiễn") kèm số sát thương.
  - Tung chiêu chủ động: banner lớn phát sáng giữa màn hình trong 0.8 giây (vd **"🔥 THIÊN THẠCH!"**).
  - Quái tấn công: hiện tên đòn đánh của quái (vd "Cắn Xé", "Gầm Thét").
  - Đòn chí mạng: hiện chữ **CRIT!** màu vàng nổi bật.
  - Thanh kỹ năng xuất trận: hiển thị chi phí Mana và phát sáng nhẹ khi đủ Mana chuẩn bị xuất chiêu.
- **Mở rộng 21 Kỹ năng**:
  - 5 kỹ năng đánh thường (Hỏa Cầu, Băng Tiễn, Lôi Kích, Độc Châm, Trảm Thép).
  - 8 kỹ năng chủ động (Thiên Thạch, Hỏa Long Ba, Khiên Hỏa Giáp, Băng Ngục, Lôi Đình, Độc Vụ, Thánh Quang Phục Hồi, Hỏa Bão Tận Thế).
  - 8 kỹ năng bị động (Hỏa Tâm, Dực Hỏa Thiêu Đốt, Băng Thể, Phong Hành, Sát Ý, Huyết Ma, Linh Thể, Dòng Chảy Ma Lực).
- **Thưởng Kỹ Năng theo Mốc Ải (chỉ tính lần đầu phá ải)**:
  - Phá 5 ải: Mở khóa 1 kỹ năng chủ động ngẫu nhiên.
  - Phá 10 ải: Mở khóa 1 kỹ năng bị động ngẫu nhiên.
  - Phá 15 ải: Mở khóa **Ô Kỹ Năng Xuất Trận Thứ 5**.
  - Phá 20 ải: Mở khóa Tuyệt Kỹ Tối Thượng (Hỏa Bão Tận Thế).

---

## 4. Hướng Dẫn Khởi Động Game

```bash
cd "C:\Users\ADMIN\Desktop\New folder\game AND"

# Chạy test kiểm thử logic game
flutter test

# Khởi chạy trên máy thật, máy ảo Android hoặc Windows
flutter run
```
