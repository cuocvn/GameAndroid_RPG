# Tactical Idle RPG (Game AND) - Android Offline RPG

Game nhập vai chiến thuật một nhân vật (**Single Character RPG + Idle Auto Battle + Character Builder**) viết bằng **Flutter + Dart**, hoạt động 100% offline, không cần internet.

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
│   │   ├── seed_enemies.dart    (5 vùng đất scale HP x1.8, ATK x1.55, Boss x6 HP, x2.2 ATK, +20% DEF)
│   │   ├── seed_equipment.dart  (Kho trang bị cố định & khởi đầu theo 5 bậc Rarity)
│   │   └── seed_skills.dart     (21 kỹ năng: 5 đánh thường, 8 chủ động, 8 bị động)
│   ├── models/
│   │   ├── stats.dart           (5 chỉ số STR, INT, VIT, AGI, LUK & công thức phái sinh)
│   │   ├── skill.dart           (Kỹ năng, chi phí mana, hồi chiêu 15s, hồi máu 25%, tỉ lệ & hiệu ứng)
│   │   ├── equipment.dart       (Trang bị 3 slot, cấp nâng cấp ⚡ +10%/cấp, 5 cấp Rarity)
│   │   ├── enemy.dart           (Kháng phép 40%, Phản đòn 20%, Hồi máu 5%/s, Diablo Cuồng Nộ)
│   │   ├── player.dart          (Cap gear +150%, Cap Crit DMG 250%, Anti-trivialize +15%)
│   │   └── battle_state.dart    (Trạng thái chiến đấu, banner chiêu thức, floating damage text)
│   ├── providers/
│   │   └── game_providers.dart  (Riverpod Notifier: nâng cấp đồ ⚡, mua shop, mốc ải, auto-save)
│   ├── services/
│   │   ├── battle_service.dart  (Auto-battle engine: AI ưu tiên hồi máu, Diablo Cuồng Nộ, phản đòn)
│   │   ├── loot_service.dart    (Tỉ lệ rơi đồ giảm 18%, Rare+ chỉ từ Boss Vùng 3+, cap LUK 50%)
│   │   └── save_service.dart    (Lưu tiến trình offline tự động qua Hive + SharedPreferences)
│   ├── theme/
│   │   └── app_theme.dart       (Bảng màu Dark Fantasy #0D0B14, GoogleFonts Cinzel & Inter)
│   ├── screens/
│   │   ├── home_screen.dart     (Avatar bồng bềnh + bục ma pháp, 2x2 stats card, CTA nhịp đập)
│   │   ├── build_screen.dart    (Pill tabs, 3 ô trang bị vuông phát sáng, kho đồ 4 cột, phân loại skill)
│   │   ├── shop_screen.dart     (Cửa hàng 4 tab: Vũ khí, Giáp, Phụ kiện, Đá Quý 💎, so sánh ▲▼)
│   │   ├── battle_screen.dart   (Sàn đấu 2 bục đá, breathing animation, HP nhấp nháy, log 📜 thu gọn)
│   │   └── map_screen.dart      (Bản đồ ziczac 5 vùng đất, node ải đã qua/khóa/boss)
│   ├── widgets/
│   │   ├── hp_bar.dart          (Thanh máu cảnh báo nhấp nháy đỏ khi HP < 30%, khiên & mana)
│   │   ├── stat_row.dart        (Hiển thị chỉ số + nút cộng điểm tròn viền vàng phát sáng)
│   │   ├── equipment_card.dart  (Thẻ trang bị viền màu Rarity glow, chip chỉ số, so sánh)
│   │   ├── skill_card.dart      (Thẻ kỹ năng, tag nguyên tố, nút Trang bị chiến đấu)
│   │   └── damage_text_widget.dart (Chữ bay sát thương viền stroke đen chống chìm ảnh nền)
│   └── main.dart                (Điểm khởi chạy ứng dụng, Dark Fantasy Theme RPG)
├── test/
│   ├── balance_test.dart        (Bộ kiểm thử cân bằng độ khó 5 kịch bản bắt buộc)
│   └── widget_test.dart         (Bộ kiểm thử đơn vị cấu hình, công thức và nâng cấp đồ)
└── pubspec.yaml                 (Khai báo google_fonts, flutter_riverpod, hive, path_provider)
```

---

## 2. Hệ Thống Cân Bằng Độ Khó (Issue 1 Rebalance)

1. **Công thức quái vật theo vùng**:
   - Quái thường vùng $N$: $\text{HP}_N = \text{HP}_{N-1} \times 1.8$; $\text{ATK}_N = \text{ATK}_{N-1} \times 1.55$.
   - Boss ải cuối: $\text{HP}_{\text{Boss}} = 6 \times \text{HP}_{\text{Quái thường}}$; $\text{ATK}_{\text{Boss}} = 2.2 \times \text{ATK}_{\text{Quái thường}}$; $+20\%$ DEF.
   - Vùng 1 (Baseline): Quái thường lấy đi ít nhất 40% HP của người chơi nếu build kém; Boss 1 đánh bại người chơi chưa nâng cấp trang bị.
2. **Cơ chế nội tại theo vùng**:
   - **Vùng 3 — Kháng Phép 40%**: Sát thương từ kỹ năng phép thuật (INT-based) giảm 40%. Hiển thị huy hiệu `[🛡️ Kháng Phép]`.
   - **Vùng 4 — Phản Đòn 20%**: Phản lại 20% sát thương nhận vào người chơi dưới dạng chữ đỏ `-X (phản đòn)`. Hiển thị huy hiệu `[⚡ Phản Đòn]`.
   - **Vùng 5 — Hồi Máu 5%/giây**: Quái tự hồi 5% HP tối đa mỗi giây (`+X HP` màu xanh lá).
   - **Boss Vùng 5 (Diablo)**: Khi HP $< 30\%$, kích hoạt **Cuồng Nộ** (+50% ATK, +30% tốc đánh, biểu ngữ `🔥 DIABLO NỔI GIẬN!`).
3. **Kiểm soát sức mạnh người chơi**:
   - Cap tổng % tăng chỉ số từ trang bị ở **+150%** chỉ số gốc (chống stack vô hạn).
   - Cap **Sát thương Chí Mạng (Crit DMG)** ở mức tối đa **250%** (150% base + 100% bonus).
   - Kỹ năng hồi máu (Thánh Quang Phục Hồi): Cooldown **15 giây**, hồi tối đa **25% Max HP**.
   - **Anti-trivialize**: Nếu người chơi thắng ải quá nhanh ($< 8$ giây), độ khó ải tiếp theo tự động tăng $+15\%$.
4. **Kiểm thử cân bằng tự động (`test/balance_test.dart`)**:
   - ✅ Build full INT + Thiên Thạch **không thể qua Vùng 3** (do Kháng Phép 40%).
   - ✅ Build full STR + Trảm Thép **không thể thắng Diablo Vùng 5** (do Hồi Máu 5%/s).
   - ✅ Build full VIT (Tank) **phải thắng Boss Vùng 4 (Hades)** nhờ lượng máu và giáp chịu được phản đòn.

---

## 3. Redesign Giao Diện Dark Fantasy (Issue 2)

- **Bảng màu & Theme (`lib/theme/app_theme.dart`)**:
  - Background chính: `#0D0B14` (tím đen cực tối)
  - Surface gradient: `#1A1626` $\rightarrow$ `#252036` (chéo $135^\circ$)
  - Accent vàng gold: `#FFB547` (nút chính, viền phát sáng)
  - Accent đỏ (`#E85D5D`), xanh lam (`#5DA9E8`), xanh lá (`#7FE85D`), tím (`#A85DE8`)
  - 5 cấp độ hiếm (Rarity): Common (bạc), Uncommon (lục bảo), Rare (lam ngọc), Epic (tím ma thuật), Legendary (vàng kim hoàng gia).
- **Typography**:
  - Sử dụng `google_fonts`: **Cinzel** cho tiêu đề fantasy, tên Boss, số sát thương; **Inter** cho nội dung và thông số.
- **HomeScreen**:
  - Avatar nhân vật bồng bềnh lên xuống nhẹ nhàng trên bục ma pháp phát sáng.
  - Thẻ tóm tắt 2x2 grid (Máu, Giáp, Công phép, Chí mạng) với icon màu riêng.
  - Nút "⚔️ CHIẾN ĐẤU" kích thước lớn, hiệu ứng nhịp đập (pulse animation) phát sáng.
  - Thanh công cụ đáy bo tròn gồm Shop, Bản Đồ, Nhân Vật (kèm badge thông báo điểm chưa cộng).
- **BuildScreen**:
  - Pill tabs chuyển đổi mượt mà.
  - 3 ô trang bị hình vuông hiển thị trực quan (Vũ khí, Giáp, Phụ kiện) với viền màu Rarity glow.
  - Tab kỹ năng phân loại 3 mục: Đánh thường, Chủ động, Bị động.
- **BattleScreen**:
  - Sàn đấu 2 bục đá ma pháp dưới chân Hero và Quái vật kèm hiệu ứng thở (breathing idle animation).
  - Thanh HP đối xứng kèm avatar tròn nhỏ, **cảnh báo nhấp nháy đỏ khi HP < 30%**.
  - Sát thương chữ bay (Floating Damage Text) có viền stroke đen bao quanh chống chìm ảnh nền.
  - Banner kỹ năng xuất trận rực rỡ lướt qua màn hình trong 0.8s.
  - Nhật ký chiến đấu thu gọn trong nút floating icon 📜 mở drawer tiện lợi.
- **ShopScreen & MapScreen**:
  - Cửa hàng 4 tab rõ ràng, thẻ so sánh chỉ số mũi tên xanh ▲ đỏ ▼.
  - Bản đồ ziczac hiển thị dấu ✅ đã qua, 🔒 đang khóa và avatar Boss.

---

## 4. Hướng Dẫn Chạy & Kiểm Thử

### Chạy Unit Test & Balance Simulation
```bash
flutter test
```
Tất cả 9 bài test (bao gồm 5 bài test cân bằng độ khó) đều vượt qua 100%.

### Chạy Ứng Dụng Trên Thiết Bị / Emulator
```bash
flutter run
```
