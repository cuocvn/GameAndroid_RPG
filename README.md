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

### 2.8. Hệ Thống Khảm Ngọc (Gem Sockets)
- **Số ô khảm (Socket) theo bậc hiếm**:
  - *Common / Uncommon*: 0 socket.
  - *Rare*: 1 socket.
  - *Epic*: 2 sockets.
  - *Legendary*: 3 sockets.
  - *Set items (Viêm Long, Hàn Băng, Lôi Đình, Huyết Ma)*: $+1$ socket cộng thêm.
- **5 Loại Ngọc $\times$ 5 Cấp**:
  - 🔴 **Hồng Ngọc (Ruby)**: $+5 / +10 / +15 / +25 / +40$ Sức tấn công (ATK). Rơi từ quái và mua ở Cửa hàng.
  - 🔵 **Lam Ngọc (Sapphire)**: $+100 / +200 / +350 / +550 / +800$ Máu tối đa (Max HP). Rơi từ quái và Tháp Vô Tận.
  - 🟢 **Lục Ngọc (Emerald)**: $+3 / +6 / +10 / +15 / +25$ Phòng thủ (DEF). Rơi từ quái và Cửa hàng.
  - 🟡 **Hoàng Ngọc (Topaz)**: $+2\% / +3\% / +4\% / +6\% / +8\%$ Tỉ lệ chí mạng (Crit Rate). Rơi từ Boss ải.
  - 🟣 **Tím Ngọc (Amethyst)**: $+0.5 / +1.0 / +1.5 / +2.5 / +4.0$ Hồi mana/giây. Rơi từ các tầng chẵn Tháp Vô Tận.
- **Khảm / Tháo & Nâng Cấp**:
  - Chạm vào ô socket trống trên thẻ trang bị để chọn ngọc từ kho và gắn vào ngay lập tức.
  - **Tháo ngọc miễn phí 100% không mất ngọc** (QoL quan trọng).
  - Nâng cấp trực tiếp trên trang bị (khi có đủ 2 viên cùng loại trong túi) hoặc trong **Kho Ngọc** (Sheet 5x5 grid 25 ô).
  - Tính năng **"Ghép Tất Cả" (Fuse All)**: Tự động gom và ghép tất cả ngọc cấp $N$ đủ 3 viên lên cấp $N+1$ (phí $50 \times N$ vàng).

### 2.9. Hệ Thống Chế Tạo Trang Bị (Crafting)
- **4 Loại Nguyên Liệu Mới**:
  - 🔩 **Sắt Cổ (`iron`)**: Rơi từ quái Vùng 1-2.
  - 💠 **Pha Lê Ma Pháp (`crystal`)**: Rơi từ quái Vùng 3-4.
  - 🌑 **Hắc Kim (`steel`)**: Rơi từ quái Vùng 5 và Tháp Vô Tận Tầng 10+.
  - ✨ **Tinh Hoa Hỗn Mang (`essence`)**: Rơi từ Boss các vùng và Tháp Vô Tận Tầng 20+ (Rare).
- **Màn hình Chế Tạo (`CraftingScreen`)**:
  - Gồm 8 công thức mở khóa theo cấp độ người chơi (từ Lv 5+ đến Lv 30+).
  - Cho phép chế tạo Vũ khí, Giáp, Phụ kiện từ bậc Uncommon, Rare, Epic, Legendary đến Mảnh Set Hoàng Kim ngẫu nhiên.
  - Có tỉ lệ may mắn rèn ra trang bị kèm theo socket bonus hoặc Set Piece. Lưu trữ danh sách công thức đã từng chế tạo thành công.

### 2.10. Hệ Thống Reforge (Tẩy / Đổi Dòng Chỉ Số Phụ)
- Trang bị bậc **Rare+** tự động sở hữu 1-2 dòng chỉ số phụ ngẫu nhiên (Affix).
- **Bể Chỉ Số Phụ (Affix Pool)**:
  - $+X\%$ Sức tấn công ATK ($3\% - 15\%$).
  - $+X\%$ Máu tối đa Max HP ($5\% - 20\%$).
  - $+X\%$ Sát thương chí mạng Crit DMG ($10\% - 35\%$).
  - $+X\%$ Tốc độ đánh Attack Speed ($5\% - 15\%$).
  - $+X\%$ Kháng nguyên tố Elemental Resist ($5\% - 20\%$).
  - $+X\%$ Hút máu Lifesteal ($2\% - 8\%$).
- **Quy tắc Reforge**:
  - Đổi ngẫu nhiên 1 dòng affix và **tuyệt đối không bao giờ ra trùng loại affix đã có trên món đồ**.
  - Chi phí theo bậc: Rare (500 vàng + 1 Pha Lê), Epic (1500 vàng + 2 Hắc Kim), Legendary (5000 vàng + 5 Tinh Hoa).
  - Có cơ chế **Khóa Dòng (Lock Affix)** với chi phí thêm 1 💎.
  - Popup so sánh trực quan dòng hiện tại $\rightarrow$ dòng mới với 2 tùy chọn **"Giữ"** (giữ dòng cũ nếu không ưng, chỉ mất phí rèn) hoặc **"Lấy"** (áp dụng dòng mới).

### 2.11. Hệ Thống Biến Đổi Trang Bị (Transmute / Lò Rèn)
- Tích hợp tại Tab 2 màn hình Chế Tạo.
- Cho phép hợp nhất **3 món trang bị cùng bậc hiếm** để tạo ra **1 món trang bị bậc hiếm cao hơn**:
  - 3 Common $\rightarrow$ 1 Uncommon (100 vàng).
  - 3 Uncommon $\rightarrow$ 1 Rare (300 vàng).
  - 3 Rare $\rightarrow$ 1 Epic (1000 vàng).
  - 3 Epic $\rightarrow$ 1 Legendary (3000 vàng, 30% tỉ lệ thành công, thất bại giữ lại 1 món Epic).
- Tiện ích QoL: **"Tự động chọn 3 món rác thấp nhất"** giúp người chơi dọn kho đồ nhanh chóng.

### 2.12. Hệ Thống Đấu Trường PvP Giả Lập (Offline Simulated Arena)
- **Cơ chế Matchmaking theo khung Level (Power Brackets)**:
  - Hoạt động 100% offline không cần server: Hệ thống tự động khởi tạo đối thủ AI dựa trên chỉ số thực tế của người chơi.
  - *Lv 10-15*: Lực chiến đối thủ $\approx 90\% - 110\%$ người chơi, trang bị bậc Rare.
  - *Lv 16-25*: Lực chiến đối thủ $\approx 100\% - 120\%$, trang bị bậc Epic.
  - *Lv 26+*: Lực chiến đối thủ $\approx 110\% - 140\%$, trang bị bậc Legendary.
  - Đối thủ AI sở hữu phân bổ chỉ số ngẫu nhiên theo các trường phái (Chiến Binh, Pháp Sư, Sát Thủ, Hộ Vệ), sở hữu thanh Mana riêng và trang bị 3-5 chiêu thức chủ động.
- **Quy tắc Chiến đấu & Phần thưởng**:
  - Hai nhân vật giao tranh tự động đối xứng, sử dụng mana thi triển kỹ năng.
  - *Thắng trận*: $+1$ Điểm Đấu Trường (AP) + 200 Vàng + 10% cơ hội rơi Ngọc ngẫu nhiên.
  - *Thua trận*: $-1$ AP (tối thiểu 0 AP, không âm), không mất vàng.
  - *Chuỗi Thắng (Streak Bonus)*: Mỗi 5 trận thắng liên tiếp thưởng thêm $+5$ AP và $+1$ 💎.
  - Tách biệt hoàn toàn với tiến trình đi ải chiến dịch (không ảnh hưởng tới mốc map hay Endless Tower).
  - Lưu trữ lịch sử 10 trận đấu gần nhất trực quan.

### 2.13. Hệ Thống Phân Hạng Rank Tier & MMR
- **7 Bậc Hạng (Tiers) dựa trên Điểm AP**:
  - 🥉 **Đồng**: 0 - 99 AP (Đồng III: 0-32, Đồng II: 33-65, Đồng I: 66-99).
  - 🥈 **Bạc**: 100 - 249 AP (Bạc III: 100-149, Bạc II: 150-199, Bạc I: 200-249).
  - 🥇 **Vàng**: 250 - 499 AP (Vàng III: 250-332, Vàng II: 333-415, Vàng I: 416-499).
  - 💎 **Bạch Kim**: 500 - 999 AP (Bạch Kim III, II, I).
  - 💠 **Kim Cương**: 1000 - 1999 AP (Kim Cương III, II, I).
  - 🔮 **Tinh Anh**: 2000 - 3499 AP (Tinh Anh III, II, I).
  - 👑 **Cao Thủ**: 3500+ AP (Bậc tối thượng, không phân nhánh phụ).
- Huy hiệu Rank hiển thị trực tiếp với màu sắc đặc trưng tại màn hình Home.
- **Phần Thưởng Mùa 7 Ngày**:
  - Hàng tuần cho phép tổng kết nhận quà theo bậc: từ 500 Vàng (Đồng) đến 20,000 Vàng + 50 💎 + Ngọc Cấp 5 + Danh hiệu độc quyền *"Cao Thủ Vô Song"*.

### 2.14. Bảng Xếp Hạng Giả Lập Cạnh Tranh (Virtual Leaderboard)
- Mô phỏng 30 cao thủ ảo với tên tuổi kiếm hiệp huyền thoại (Độc Cô Cầu Bại, Tây Môn Xuy Tuyết, Tiêu Phong, Dương Quá...).
- Điểm AP của các đối thủ dao động từ 2,000 đến 8,000 AP và tự động gia tăng nhẹ sau mỗi ngày để mô phỏng "người chơi khác cũng đang leo rank".
- Vị trí của người chơi được chèn theo thời gian thực dựa vào AP hiện tại.
- Top 3 nhận hiệu ứng hào quang Vàng / Bạc / Đồng. Nếu người chơi ngoài Top 10, thanh trạng thái ghim cố định bên dưới sẽ luôn hiển thị vị trí chính xác của người chơi.

### 2.15. Vé Mùa Đấu Trường (Offline Season Pass)
- Mùa giải kéo dài **30 ngày** (tính từ thời điểm người chơi mở Đấu Trường lần đầu).
- Tiến trình tích lũy bằng **Tổng AP Tích Lũy Mùa** (Cứ mỗi 100 AP mở khóa 1 Mốc, tối đa 3,000 AP cho Mốc 30).
- **30 Mốc Phần Thưởng Đẳng Cấp**:
  - *Mốc 1-10*: Vàng + Kim Cương tăng tiến.
  - *Mốc 11-20*: Ngọc Cấp 2-3 + Trang bị Rare.
  - *Mốc 21-29*: Ngọc Cấp 4 + Trang bị Epic.
  - *Mốc 30 (Đỉnh Phong Mùa)*: 1 Ngọc Cấp 5 + 50 💎 + 1 Mảnh Set Hoàng Kim huyền thoại ngẫu nhiên.

### 2.16. Cốt Truyện & Biên Niên Sử 16 Danh Tướng
- **Cơ chế**: Mỗi vị tướng trong số 16 danh tướng sở hữu cốt truyện riêng biệt gồm 3 chương (200-300 từ mỗi chương) ghi lại nguồn gốc sức mạnh và hành trình chiến đấu.
- **Tiến trình mở khóa theo từng tướng**:
  - *Cấp 5*: Mở khóa Chương 1.
  - *Cấp 15*: Mở khóa Chương 2.
  - *Cấp 30*: Mở khóa Chương 3 + Thưởng buff vĩnh viễn $+1\%$ tất cả chỉ số khi xuất trận cùng tướng đó.
- **Phần thưởng tối thượng**: Hoàn thành Chương 3 của toàn bộ 16 tướng sẽ mở khóa danh hiệu độc quyền **"Nhà Sử Học"** và $+5\%$ toàn bộ chỉ số vĩnh viễn toàn cục.
- **Giao diện**: Tab "📜 Cốt Truyện" trong mục Nhân Vật với giao diện trang sách cổ hoàng kim (Parchment Texture, phông chữ Cinzel & Merriweather cổ điển).

### 2.17. Hệ Thống Thú Đồng Hành (Companion)
- **Cơ chế**: Người chơi có thể mang theo 1 thú cưng đồng hành trợ chiến. Thú cưng không bị quái vật tấn công mà hỗ trợ thông qua nội tại bị động trực tiếp:
  - 🐺 **Sói Con** (Mở khóa Lv.10): $+5\%$ Tốc độ đánh cơ bản.
  - 🦅 **Đại Bàng Lửa** (Mở khóa Lv.15): $+8\%$ Sát thương kỹ năng hệ Hỏa.
  - 🐉 **Long Nhi** (Mở khóa Lv.20): $+10\%$ Máu tối đa (Max HP).
  - 🦊 **Hồ Ly Tinh** (Mở khóa Lv.25): $+5\%$ Tỉ lệ bạo kích (Crit Rate).
  - 👻 **Oán Linh Nhỏ** (Mở khóa Lv.30): $+5\%$ Hút máu khi tấn công (Lifesteal).
- **Nâng cấp thú cưng**: 10 cấp độ, tiêu hao thức ăn rơi từ quái (*Thịt Khô 🥩, Linh Thảo 🌿, Tinh Thạch Thú 💎*). Mỗi cấp tăng $+2\%$ hiệu ứng nội tại.
- **Ràng buộc cân bằng**: Toàn bộ hiệu ứng bị động từ thú cưng được giới hạn nghiêm ngặt ở mức tối đa **$+30\%$**.
- **Giao diện**: Tab "🐾 Đồng Hành" trong mục Nhân Vật, hiển thị icon thú cưng bồng bềnh viền vàng cạnh avatar người chơi trong sảnh chính và sàn đấu.

### 2.18. Đại Chiến Boss Thế Giới (Endgame Raid Boss)
- **Luân phiên hàng tuần (3 Boss Thế Giới)**:
  - *Tuần 1*: 🐲 **Rồng Hỗn Mang Ragnarok** (500,000 HP, Sát thương cực cao, Hơi Thở Hắc Long gây thiêu rụi).
  - *Tuần 2*: 👁️ **Nhãn Thần Azathoth** (800,000 HP, Kháng phép $50\%$, Tà Nhãn làm giảm DEF và đóng băng).
  - *Tuần 3*: 💀 **Tử Thần Thanatos** (1,000,000 HP, Hút máu $30\%$, Khúc Ca Hắc Ám trừng phạt dũng sĩ).
- **Cơ chế cộng dồn sát thương**: Mỗi lượt khiêu chiến kéo dài tối đa 60 giây hoặc đến khi nhân vật ngã xuống. Sát thương gây ra được trừ trực tiếp vào HP Boss và lưu trữ bền vững suốt tuần (cần từ 3-5 lượt đánh ở giai đoạn Lv 20-25).
- **Cơ chế Thể Lực (Stamina)**:
  - Tối đa 20 điểm thể lực. Tốn 5 điểm cho mỗi lượt tấn công.
  - Tự động hồi phục ngoại tuyến: 1 điểm sau mỗi 5 phút (300,000 ms).
  - Mua thể lực nhanh: 1 💎 = 5 thể lực (tối đa 3 lần/ngày).
- **Phần thưởng Diệt Boss**: Nhận 1 Thần Binh Huyền Thoại (Legendary Weapon) + 100 💎 + Danh hiệu độc quyền theo Boss (*Kẻ Diệt Rồng, Kẻ Trảm Ma, Kẻ Nghịch Thần*).
- **Bảng Xếp Hạng Sát Thương**: Top 10 tổng kết tuần, vị trí Top 1 nhận danh hiệu *"Sát Thần"* và 5,000 Vàng.

---

## 3. Hướng Dẫn Chạy & Kiểm Thử

### Chạy Unit & Balance Tests
```bash
flutter test
```
Tất cả 26/26 tests được đảm bảo 100% Pass:
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
- Hệ thống Khảm Ngọc (Socket, Gem stat scaling, tháo lắp không hao hụt, Ghép tất cả).
- Hệ thống Chế Tạo (Mở khóa công thức, trừ nguyên liệu, chế tạo đồ và Set item).
- Hệ thống Reforge (Đổi dòng ngẫu nhiên không trùng lặp, trừ tài nguyên và cập nhật chỉ số).
- Hệ thống Transmute (Ghép 3 món cùng bậc thành bậc cao hơn, kiểm tra thất bại & validate input).
- Tính toán Bậc Hạng Đấu Trường (Arena Rank Tiers & Sub-ranks I, II, III).
- Matchmaking theo khung Level (Power brackets 90-110%, 100-120%, 110-140%).
- Tiến trình Vé Mùa Season Pass (30 Mốc, chuỗi 5 trận thắng thưởng thêm, nhận thưởng tích lũy).
- Tính toán chỉ số nội tại thú cưng Companion và giới hạn trần nghiêm ngặt $+30\%$.
- Cơ chế trừ máu Boss Raid và bảo toàn sát thương cộng dồn qua nhiều trận đánh.
- Cơ chế hồi thể lực Raid ngoại tuyến (5 phút/1 thể lực) và giới hạn mua thể lực tối đa 3 lần/ngày.

### Chạy Ứng Dụng Trên Android Emulator hoặc Thiết Bị Thật
```bash
flutter run
```
