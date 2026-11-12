# Nhật Ký Thay Đổi (Changelog) - Vô Ảnh Chiến Ký

Tất cả các thay đổi và tính năng nổi bật của dự án **Vô Ảnh Chiến Ký** (Tactical Idle RPG) được ghi nhận chi tiết tại đây.

---

## [1.0.0] - 2026-11-12 (Phiên Bản Phát Hành Chính Thức)

### 🌟 Nhận Diện Ứng Dụng (App Identity)
- **Tên trò chơi chính thức**: "Vô Ảnh Chiến Ký" (Android Label: `Vo Anh Chien Ky`, Package: `com.cuocvn.voanhchienky`).
- **Biểu tượng ứng dụng (App Icon)**: Thiết kế đồ họa chuyên biệt với con mắt rồng cách điệu và chữ "影" hoàng kim trên nền huyền bí `#0D0B14`, hỗ trợ Android Adaptive Icons đa kích thước (hdpi đến xxxhdpi).
- **Màn hình khởi động (Splash Screen)**: Tích hợp `flutter_native_splash` kết hợp `SplashScreen` tầng 2 hiệu ứng loading thanh mảnh và chuyển cảnh mượt mà vào Home.
- **Khóa chiều xoay**: Cố định màn hình dọc (`portraitUp`) tối ưu trải nghiệm chơi game 1 tay.

---

### ⚔️ Hệ Thống Chiến Đấu & Ải Cốt Truyện
- **5 Vùng Cốt Truyện Độc Đáo**:
  - *Vùng 1: Rừng Hắc Ám* — Quái rừng nhập môn, Thú Vương Cuồng Nộ.
  - *Vùng 2: Dung Nham Rực Lửa* — Quái lửa, Hỏa Ma Vương Ifrit.
  - *Vùng 3: Đỉnh Núi Tuyết* — Kháng phép 40%, Cổ Thần Băng Ymir.
  - *Vùng 4: Vực Thẳm Diệt Vong* — Phản đòn 20%, Minh Vương Hades.
  - *Vùng 5: Vùng Đất Hỗn Mang* — Hồi máu 5%/giây, Boss Diablo Cuồng Nộ dưới 30% HP (+50% Công, +30% Tốc đánh).
- **Tháp Vô Tận (Endless Tower)**: 30+ tầng leo tháp không giới hạn, scale độ khó 1.25x mỗi tầng, thủ vệ đặc biệt mỗi 5 tầng kèm modifier khắc chế.
- **Cơ chế chống lạm dụng (Anti-Trivialize)**: Vượt ải thần tốc dưới 8 giây tự động tăng +15% độ khó cho ải kế tiếp.

---

### 🛡️ Chiều Sâu Trang Bị (Deep Gear Progression)
- **5 Phẩm Cấp**: Thường (Common), Tinh Anh (Uncommon), Hiếm (Rare), Sử Thi (Epic), Huyền Thoại (Legendary) & Thần Thoại (Mythic).
- **Hệ Thống Socket Ngọc (Gem Sockets)**:
  - 0-3 socket theo phẩm cấp, thêm +1 socket cho trang bị Bộ.
  - 5 loại ngọc x 5 cấp: Hồng Ngọc (+ATK), Lam Ngọc (+Max HP), Lục Ngọc (+DEF), Hoàng Ngọc (+Crit Rate), Tím Ngọc (+Mana Regen).
  - Ghép 3 viên cùng cấp lên cấp cao hơn, tháo ngọc an toàn 100% không mất mát.
- **Hệ Thống Chế Tạo (Crafting)**: 4 công thức rèn trang bị từ nguyên liệu rơi từ quái (Sắt, Da thú, Tinh thể, Huyết thạch).
- **Tẩy Luyện Thuộc Tính (Reforge)**: Tẩy ngẫu nhiên các dòng affixes (Hút máu, Né tránh, Chí mạng, Kháng phép) không trùng lặp.
- **Hợp Nhất Trang Bị (Transmutation)**: Dung hợp 3 trang bị cùng phẩm lên bậc cao hơn hoặc thu hồi 70% bụi luyện kim.
- **4 Bộ Trang Bị Huyền Thoại**:
  - *Bộ Viêm Long*: Kích hoạt hiệu ứng Thiêu Đốt (Burn DoT).
  - *Bộ Hàn Băng*: Tỷ lệ Đóng Băng làm chậm đối thủ 50%.
  - *Bộ Lôi Đình*: Sốc Điện gây thêm sát thương lan.
  - *Bộ Huyết Ma*: Hút Máu 10% sát thương đòn đánh.

---

### 📜 Cốt Truyện 16 Danh Tướng (Hero Lore) & Thú Cưng (Companions)
- **16 Danh Tướng**: Mỗi tướng sở hữu 3 chương cốt truyện độc quyền mở khóa theo cấp độ, đạt chương 3 nhận danh hiệu "Nhà Sử Học" và thưởng vĩnh viễn +1% đến +5% toàn bộ chỉ số.
- **3 Thú Đồng Hành**:
  - *Kim Sí Điểu*: Tăng Công vật lý và Tốc đánh.
  - *Hắc Diệu Báo*: Tăng Bạo kích và Sát thương bạo kích.
  - *Huyền Quy*: Tăng Phòng ngự và Máu tối đa.
  - Hệ thống cho ăn (Thịt thú, Thảo dược, Thú hồn thạch) tăng cấp độ thân mật và buff chỉ số (cap tối đa +30%).

---

### 🏆 Đấu Trường PvP Giả Lập & Đại Ma Vương Tuần (World Raid)
- **Đấu Trường PvP Ngoại Tuyến**: Ghép trận thông minh theo thang lực chiến 90-140%, 7 bậc Rank (Đồng đến Cao Thủ).
- **Season Pass Đấu Trường**: Tích lũy điểm AP nhận 15 mốc quà (Vàng, Đá quý, Ngọc cao cấp, Rương trang bị Set).
- **Đại Ma Vương Tuần (Weekly Raid Boss)**:
  - 3 Siêu Boss: Hắc Long Nidhogg (500k HP), Viêm Ma Surtur (750k HP), Cổ Thần Ragnarok (1.2M HP).
  - Cơ chế lưu trữ lượng máu tổn thất liên tục qua nhiều lượt đánh.
  - Hệ thống Thể lực Khiêu chiến (Raid Stamina) tự động hồi phục 5 phút / 1 điểm.

---

### 🌟 Chuyển Sinh / Ngộ Đạo (Prestige System)
- Điều kiện mở khóa: Đạt Level 30 hoặc vượt Tháp Vô Tận Tầng 15.
- Cây Ngộ Đạo 8 nhánh thiên phú: Tăng Công, Thủ, Máu, Bạo kích, Hệ số Vàng, EXP, Thêm ô Tuyệt kỹ chiến đấu, và *Bất Tử Hồi Sinh* (hồi 50% HP 1 lần mỗi trận).

---

### 💤 Tiến Trình Ngoại Tuyến (Offline Progress / AFK Idle)
- Tự động tích lũy EXP, Vàng, Trang bị, Thể lực khi thoát game (tỷ lệ 60% so với online).
- Giới hạn tối đa 8 giờ và 200 trận đánh offline chống lạm phát kinh tế.
- Bật/tắt chế độ Auto-Farm trực tiếp trên bản đồ ải.

---

### 🎨 Tinh Chỉnh Đồ Họa & Âm Thanh (Juice & Polish)
- Rung màn hình (Screen Shake) chân thực khi nổ Crit hoặc Boss gục ngã.
- Chớp trắng (Hit Flash) trên quái vật khi nhận sát thương.
- Số sát thương nhảy múa (Damage Numbers bounce & float) với font số nổi bật.
- Cảnh báo máu thấp: Viền đỏ đập nhịp khi HP < 30% và hiệu ứng tối góc khi HP < 15%.
- Banner thi triển Tuyệt kỹ lướt góc chéo tạo cảm giác uy lực.
- Bật/tắt âm thanh và phản hồi rung xúc giác (Haptic Feedback) tùy chỉnh trong Cài đặt.
- Gợi ý chiến thuật thông minh khi thất bại liên tiếp 3 lần ở cùng một ải.

---

### 🔒 Chất Lượng & Tiện Ích Trải Nghiệm (QA & QoL)
- Tự động trang bị bộ đồ mạnh nhất (Equip Best Gear) chỉ với 1 chạm.
- Giới hạn túi đồ 200 ô ngăn ngừa tràn bộ nhớ; trang bị vượt hạn định tự động quy đổi thành Vàng tương ứng.
- Hộp thoại xác nhận rút lui trong chiến đấu chống chạm nhầm thoát trận.
- **Sao lưu & Khôi phục Dữ liệu**: Hỗ trợ Xuất / Nhập Save JSON qua bộ nhớ tạm (Clipboard), phòng tránh mất dữ liệu khi chuyển thiết bị.
- Tối ưu hóa bộ nhớ: Giới hạn tối đa 20 chữ số sát thương bay đồng thời, tái chế chuỗi hiệu ứng cũ.
- Tối ưu hóa file cài đặt: Proguard / R8 Shrinking, Minify Code, tách APK theo kiến trúc CPU (arm64-v8a, armeabi-v7a, x86_64).
