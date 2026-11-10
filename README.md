# Tactical Idle RPG (Game AND) - Android Offline RPG

Game nhập vai chiến thuật một nhân vật (**Single Character RPG + Idle Auto Battle + Character Builder**) viết bằng **Flutter + Dart**, hoạt động 100% offline, không cần internet hay server.

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
│   │   ├── seed_enemies.dart    (5 vùng đất scale HP x1.8, ATK x1.55, Boss x6 HP, x2.2 ATK, +20% DEF, Endless Tower)
│   │   ├── seed_equipment.dart  (Kho trang bị cố định & khởi đầu theo 5 bậc Rarity)
│   │   └── seed_skills.dart     (21 kỹ năng: 5 đánh thường, 8 chủ động, 8 bị động)
│   ├── models/
│   │   ├── stats.dart           (5 chỉ số STR, INT, VIT, AGI, LUK & công thức phái sinh)
│   │   ├── skill.dart           (Kỹ năng, chi phí mana, hồi chiêu 15s, hồi máu 25%, tỷ lệ & hiệu ứng)
│   │   ├── equipment.dart       (Trang bị 3 slot, cấp nâng cấp +10%/cấp, 5 cấp Rarity)
│   │   ├── enemy.dart           (Kháng phép 40%, Phản đòn 20%, Hồi máu 5%/s, Diablo Cuồng Nộ)
│   │   ├── player.dart          (Cap gear +150%, Cap Crit DMG 250%, Anti-trivialize +15%, Tháp Vô Tận)
│   │   └── battle_state.dart    (Trạng thái chiến đấu, banner chiêu thức, floating damage text)
│   ├── providers/
│   │   └── game_providers.dart  (Riverpod Notifier: nâng cấp đồ, mua shop, mốc ải, auto-save, đổi chân dung)
│   ├── services/
│   │   ├── battle_service.dart  (Auto-battle engine: AI ưu tiên hồi máu, Diablo Cuồng Nộ, phản đòn)
│   │   ├── loot_service.dart    (Tỷ lệ rơi đồ giảm 18%, Rare+ chỉ từ Boss Vùng 3+ hoặc Endless Tầng 10+)
│   │   └── save_service.dart    (Lưu tiến trình offline tự động qua Hive + SharedPreferences)
│   ├── theme/
│   │   └── app_theme.dart       (Bảng màu Dark Fantasy #0D0B14, GoogleFonts Cinzel & Inter)
│   ├── screens/
│   │   ├── home_screen.dart     (Avatar bồng bềnh + bệ ma pháp, 2x2 stats card, CTA nhịp đập, chọn 16 tướng)
│   │   ├── build_screen.dart    (Pill tabs, 3 ô trang bị vuông phát sáng, kho đồ 4 cột, phân loại skill)
│   │   ├── shop_screen.dart     (Cửa hàng 4 tab: Vũ khí, Giáp, Phụ kiện, Đá Quý 💎, so sánh ▲▼)
│   │   ├── battle_screen.dart   (Sàn đấu 2 bệ đá, breathing animation, HP nhấp nháy, log 📜, popups tutorial)
│   │   └── map_screen.dart      (Bản đồ 5 vùng đất + Chế độ Tháp Vô Tận Endless Tower)
│   ├── widgets/
│   │   ├── hp_bar.dart          (Thanh máu cảnh báo nhấp nháy đỏ khi HP < 30%, khiên & mana)
│   │   ├── stat_row.dart        (Hiển thị chỉ số + nút cộng điểm tròn viền vàng phát sáng)
│   │   ├── equipment_card.dart  (Thẻ trang bị viền màu Rarity glow, chip chỉ số, so sánh)
│   │   ├── skill_card.dart      (Thẻ kỹ năng, tag nguyên tố, nút Trang bị chiến đấu)
│   │   └── damage_text_widget.dart (Chữ bay sát thương viền stroke đen chống chìm ảnh nền)
│   └── main.dart                (Điểm khởi chạy ứng dụng, Dark Fantasy Theme RPG)
└── test/
    ├── balance_test.dart        (5 test mô phỏng độ khó quái & cơ chế khắc chế bắt buộc)
    └── widget_test.dart         (5 test chỉ số người chơi, kho kỹ năng, nâng cấp, Endless Tower)
```

---

## 2. Các Tính Năng Trọng Tâm

### 2.1. Cân Bằng Độ Khó & Cơ Chế Khắc Chế Chiến Thuật
- **Hệ số quái vật 5 Vùng**:
  - Quái thường Vùng $N$: $\text{HP} = \text{HP}_{N-1} \times 1.8$, $\text{ATK} = \text{ATK}_{N-1} \times 1.55$.
  - Boss ải: $\text{HP} = 6 \times \text{quái thường}$, $\text{ATK} = 2.2 \times \text{quái thường}$, $+20\%$ DEF.
- **Nội tại đặc trưng từng vùng**:
  - **Vùng 3 — Kháng Phép 40%**: Sát thương từ skill phép bị giảm 40% (khắc chế build thuần INT).
  - **Vùng 4 — Phản Đòn 20%**: Phản lại 20% sát thương trúng phải về dũng sĩ (khắc chế build thủy tinh/dame to máu giấy, buff cho Tanker).
  - **Vùng 5 — Hồi Máu 5%/giây**: Quái vật liên tục hồi máu (khắc chế build STR dồn dame chậm).
  - **Boss Diablo (Cuồng Nộ)**: Dưới 30% HP kích hoạt Cuồng Nộ: $+50\%$ ATK, $+30\%$ tốc đánh, hiện banner `🔥 DIABLO NỔI GIẬN!`.
- **Tháp Vô Tận (Endless Tower)**:
  - Khiêu chiến không giới hạn các tầng tháp.
  - Mỗi tầng scale $1.25\times$. Cứ mỗi 5 tầng có Thủ Vệ và 1 modifier đặc biệt.
  - Trang bị bậc **Rare+** chỉ rơi từ Tầng 10 trở lên!

### 2.2. Kiểm Soát Sức Mạnh Người Chơi
- Chỉ số cộng thêm từ trang bị bị giới hạn ở mức tối đa **+150%** chỉ số cơ bản của nhân vật.
- Sát thương chí mạng bị cap ở mức **250%**.
- Kỹ năng *Thánh Quang Phục Hồi* có cooldown 15s và hồi tối đa 25% Max HP.
- **Anti-Trivialize**: Nếu vượt ải dưới 8 giây, ải kế tiếp sẽ tự động tăng $+15\%$ độ khó.

### 2.3. Đổi Chân Dung Danh Tướng
- Cho phép người chơi chạm vào ảnh đại diện tại màn hình chính để mở bảng chọn **16 danh tướng** (Cyra, Inari, Violetta, Valeria, Kaelen, Carmilla, Elysia, Sylvia, Selene, Aurora, Lucia, Marina, Seraphina, Giselle, Freya, Mai).

### 2.4. Cửa Hàng Trang Bị & Đá Nâng Cấp
- Mở khóa tại Level 5 với 4 phân loại tab: **Vũ khí ⚔️**, **Giáp 🛡️**, **Phụ kiện 💍**, **Đá quý 💎**.
- Cho phép mua trang bị bằng Vàng và đổi Vàng lấy Đá Cường Hóa để nâng cấp trang bị lên tới +5 (+10% chỉ số mỗi cấp).

---

## 3. Hướng Dẫn Chạy & Kiểm Thử

### Chạy Unit & Balance Tests
```bash
flutter test
```
Tất cả 10/10 tests được đảm bảo 100% Pass:
- Baseline Vùng 1 quái thường làm mất $\ge 40\%$ HP nếu build sai.
- Boss Vùng 1 đánh bại người chơi chưa nâng cấp.
- Pure INT thất bại ở Vùng 3 do Kháng Phép.
- Pure STR thất bại ở Boss Diablo Vùng 5 do Hồi Máu 5%/s.
- Pure VIT Tanker vượt qua Boss Vùng 4 Hades.
- Endless Tower scaling & loot rules.

### Chạy Ứng Dụng Trên Android Emulator hoặc Thiết Bị Thật
```bash
flutter run
```
