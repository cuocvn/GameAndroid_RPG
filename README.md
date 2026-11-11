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

### 2.5. Hệ Thống Chuyển Sinh (Prestige / Ngộ Đạo)
- **Điều kiện mở khóa**: Đạt **Level 30** HOẶC vượt qua **Tầng 15 Tháp Vô Tận** (Endless Tower).
- **Cơ chế Chuyển Sinh**:
  - Reset Level về 1, điểm chỉ số phân bổ về mặc định, trang bị trở về khởi đầu, vàng về 0.
  - **Giữ lại vĩnh viễn**: Điểm Ngộ Đạo, các node đã nâng trên Cây Ngộ Đạo, thành tựu, kỷ lục tầng Tháp Vô Tận, Kim Cương 💎.
  - **Công thức tính Điểm Ngộ Đạo**:
    $$\text{Điểm} = \left\lfloor \frac{\text{Level}}{5} \right\rfloor + \left\lfloor \frac{\text{EndlessFloor}}{3} \right\rfloor + (\text{Số Boss Vùng Đã Hạ}) \times 2$$
    - Hệ số Chuyển Sinh lần thứ $N$: Nhân thêm $1.0 + (N - 1) \times 0.2$ (khuyến khích người chơi chuyển sinh nhiều lần).
- **Cây Ngộ Đạo (Prestige Tree)**: Gồm 10 nhánh ngọc ấn vĩnh viễn:
  1. *Khai Sáng*: +10% EXP nhận được mỗi cấp (Tối đa 5 cấp).
  2. *Tài Lộc*: +10% Vàng nhận được mỗi cấp (Tối đa 5 cấp).
  3. *Sức Mạnh Cổ Đại*: +5% tất cả chỉ số nhân vật (Tối đa 10 cấp).
  4. *Kho Báu*: +1 slot bán đồ trong Cửa Hàng mỗi ngày (Tối đa 1 cấp).
  5. *Tốc Độ*: +10% tốc độ đánh cơ bản (Tối đa 5 cấp).
  6. *May Mắn*: +5% tỉ lệ rơi trang bị Rare+ (Tối đa 5 cấp).
  7. *Bền Bỉ*: +15% Max HP (Tối đa 5 cấp).
  8. *Khởi Đầu*: Bắt đầu chu kỳ với +5 điểm chỉ số tự do (Tối đa 3 cấp).
  9. *Hào Quang*: +1 ô kỹ năng xuất trận (Tối đa 6 ô xuất trận).
  10. *Bất Tử*: Tự động hồi sinh 1 lần mỗi trận đấu với 50% HP (Tối đa 1 cấp).
- **Tẩy Điểm Cây Ngộ Đạo**: Cho phép hoàn trả toàn bộ điểm Ngộ Đạo với chi phí 5 💎 để thử nghiệm các build khác nhau.

### 2.6. Hệ Thống Bộ Trang Bị (Set Bonus) & Bộ Sưu Tập
Thêm 4 bộ trang bị hoàng kim (3 món: Vũ khí + Giáp + Phụ kiện), mang đến hiệu ứng kích hoạt chiến đấu mạnh mẽ:
- 🔥 **Bộ Viêm Long**:
  - *2 món*: +20% sát thương kỹ năng hệ Hỏa.
  - *3 món (Full)*: Mỗi đòn đánh cơ bản gây thêm 1 stack Thiêu Đốt (Burn) kéo dài 3 giây.
- ❄️ **Bộ Hàn Băng**:
  - *2 món*: +15% kháng sát thương phép thuật.
  - *3 món (Full)*: Đòn đánh có 20% tỉ lệ làm chậm tốc đánh đối thủ 30% trong 2 giây.
- ⚡ **Bộ Lôi Đình**:
  - *2 món*: +10% tỉ lệ chí mạng.
  - *3 món (Full)*: Mỗi khi đánh chí mạng sẽ giáng thêm 1 tia sét Lôi Đình gây 50% sát thương kèm theo.
- 🩸 **Bộ Huyết Ma**:
  - *2 món*: +10% tỉ lệ hút máu (Lifesteal) khi tấn công.
  - *3 món (Full)*: Khi HP nhân vật xuống dưới 30%, tăng +50% tỉ lệ hút máu và +20% sức tấn công ATK.
- **Bộ Sưu Tập (Collection Tab)**: Nằm tại màn hình Build, hiển thị chi tiết tiến độ sở hữu các bộ trang bị, nguồn gốc rơi từ Boss từng vùng hay tầng chẵn Tháp Vô Tận.

### 2.7. Boss Patterns, Telegraph Cảnh Báo & Phân Tích Sát Thương
- **Bộ Kỹ Năng Boss Từng Vùng (Independent Cooldowns)**:
  - **Vùng 1 (Thú Vương Cuồng Nộ)**: *Cắn Xé* (150% ATK, CD 8s) & *Gầm Thét* (Giảm 20% DEF của tướng trong 5s, CD 15s).
  - **Vùng 2 (Hỏa Ma Vương Ifrit)**: *Cầu Lửa* (180% ATK phép, CD 8s) & *Thiêu Rụi* (Đốt 10% Max HP/s trong 5s, CD 15s).
  - **Vùng 3 (Cổ Thần Ymir)**: *Băng Phong* (200% ATK phép, CD 8s) & *Đóng Băng* (Khóa tấn công của tướng trong 2s, CD 15s).
  - **Vùng 4 (Minh Vương Hades)**: *Lưỡi Hái Tử Thần* (220% ATK, CD 8s) & *Triệu Hồi Oán Linh* (Hồi phục 15% HP cho Boss, CD 15s).
  - **Vùng 5 (Chúa Tể Diablo)**: *Hủy Diệt* (250% ATK, CD 8s) & *Đòn Tối Thượng* (Tuyệt kỹ 400% ATK, CD 20s).
- **Telegraph Báo Hiệu Trước 1.2 Giây**:
  - Trước khi thi triển kỹ năng 1.2s, màn hình hiện dải biểu ngữ cảnh báo màu đỏ chéo `⚠️ [TÊN CHIÊU THỨC] SẮP TỚI!`.
  - Icon kỹ năng của Boss lóe sáng cạnh khung avatar, Boss dừng đánh thường để vận công.
- **Bảng Phân Tích Sát Thương Chi Tiết (Damage Analytics Breakdown)**:
  - Nhật ký chiến đấu ghi lại từng chiêu thức và lượng sát thương cụ thể.
  - Sau trận chiến hoặc trong lúc thi đấu, nút **"XUẤT PHÂN TÍCH SÁT THƯƠNG"** hiển thị popup biểu đồ % sát thương của từng kỹ năng giúp người chơi tối ưu hóa build trang bị và khắc chế Boss.

---

## 3. Hướng Dẫn Chạy & Kiểm Thử

### Chạy Unit & Balance Tests
```bash
flutter test
```
Tất cả 16/16 tests được đảm bảo 100% Pass:
- Baseline Vùng 1 quái thường làm mất $\ge 40\%$ HP nếu build sai.
- Boss Vùng 1 đánh bại người chơi chưa nâng cấp.
- Pure INT thất bại ở Vùng 3 do Kháng Phép 40%.
- Pure STR thất bại ở Boss Diablo Vùng 5 do Hồi Máu 5%/s.
- Pure VIT Tanker vượt qua Boss Vùng 4 Hades.
- Endless Tower scaling & loot rules.
- Hệ thống Quests, Achievements & Respec.
- Tính toán điểm Ngộ Đạo, điều kiện mở Chuyển Sinh & hệ số prestige cấp $N$.
- Tác động chỉ số của các node trên Cây Ngộ Đạo.
- Kích hoạt đúng hiệu ứng 2 món và 3 món của 4 Bộ Trang Bị Hoàng Kim.
- Kiểm tra toàn diện 5 Boss Vùng với đầy đủ 2 chiêu thức đặc trưng, thời gian hồi chiêu và cơ chế Telegraph.

### Chạy Ứng Dụng Trên Android Emulator hoặc Thiết Bị Thật
```bash
flutter run
```
