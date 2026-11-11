class StoryChapter {
  final int chapterNumber;
  final int requiredLevel;
  final String title;
  final String content;

  const StoryChapter({
    required this.chapterNumber,
    required this.requiredLevel,
    required this.title,
    required this.content,
  });
}

class HeroStory {
  final String heroId;
  final String heroName;
  final String heroTitle;
  final String avatarAsset;
  final List<StoryChapter> chapters;

  const HeroStory({
    required this.heroId,
    required this.heroName,
    required this.heroTitle,
    required this.avatarAsset,
    required this.chapters,
  });

  static const List<HeroStory> allStories = [
    HeroStory(
      heroId: 'cyra',
      heroName: 'Cyra',
      heroTitle: 'Hỏa Thuật Sư',
      avatarAsset: 'assets/img/characters/013_Cyra_MID.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Lửa Hỏa Sơn Khởi Nguyên',
          content:
              'Sinh ra nơi miệng núi lửa Solaria cổ đại, Cyra từ nhỏ đã có thể lắng nghe tiếng thì thầm của nham thạch rực cháy. Trong khi những đứa trẻ khác sợ hãi ngọn lửa tàn phá, nàng lại tìm thấy sự bình yên và sức sống mãnh liệt bên trong những đốm lửa bập bùng. Năm tròn mười lăm tuổi, một thảm họa địa chấn đánh thức tà linh hắc ám chôn vùi dưới lòng đất, thiêu rụi toàn bộ ngôi làng của nàng thành tro tàn.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Lời Nguyền Hỏa Tâm',
          content:
              'Để cứu sống những linh hồn dân làng đang bị giam cầm trong hỏa ngục vô tận, Cyra đã dâng hiến trái tim của chính mình để dung hợp với Hạch Tâm Lửa Bất Diệt. Ngọn lửa thiêng cứu vớt quê hương nhưng cũng để lại lời nguyền nghiệt ngã: mỗi lần nàng thi triển pháp thuật hủy diệt, linh hồn nàng lại bị ngọn lửa thiêu đốt từ sâu bên trong da thịt.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Phụng Hoàng Tái Sinh',
          content:
              'Vượt qua hàng vạn dặm hoang mạc chết chóc và đối mặt với Chúa Tể Diablo, Cyra đã hoàn toàn thức tỉnh chân lý tối thượng: Ngọn lửa không chỉ để hủy diệt, mà còn là ánh sáng tái sinh muôn loài từ đống tro tàn. Nàng bước vào Vực Thẳm Vô Tận để biến ngọn lửa của mình thành bức tường kiên cố nhất bảo vệ nhân gian.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'inari',
      heroName: 'Inari',
      heroTitle: 'Hồ Ly Pháp Sư',
      avatarAsset: 'assets/img/characters/001_Inari_MID.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Linh Hồn Rừng Thần',
          content:
              'Dưới cội cây Anh Đào Ngàn Năm trên đỉnh núi linh thiêng, Cửu Vĩ Linh Hồ Inari tu luyện linh lực thuần khiết qua hàng thế kỷ. Nàng là người bảo hộ những giấc mơ thanh bình của cư dân vùng thung lũng, sử dụng ngọc hồ linh lung để chữa lành vết thương cho vạn vật muôn loài.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Huyễn Cảnh Vỡ Tan',
          content:
              'Khi thế lực hắc ám từ Cực Bắc tràn xuống, kết giới ngàn năm của khu rừng linh thú bị đập vỡ vụn. Những đồng tộc hồ ly bị biến chất thành ma thú cuồng nộ. Đau xót trước cảnh tượng hoang tàn, Inari đã tự chặt đứt một chiếc đuôi chứa đựng ký ức tươi đẹp nhất để đổi lấy sức mạnh cấm thuật hồ hỏa thanh tẩy.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Cửu Vĩ Thiên Hồ Quy Tông',
          content:
              'Linh lực đạt tới cảnh giới thông thiên, Inari tái tạo chín đuôi bằng tiên khí thuần khiết. Nàng gia nhập hàng ngũ dũng sĩ dấn thân vào chiến trường khốc liệt nhất, thề sẽ phong ấn vĩnh viễn ác ma bóng tối để rừng thiêng lại nở hoa dưới ánh trăng rằm.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'violetta',
      heroName: 'Violetta',
      heroTitle: 'Bóng Ma Rừng Sâu',
      avatarAsset: 'assets/img/characters/002_Violetta_JUNG.webp',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Tiếng Hát Trong Sương',
          content:
              'Ẩn sâu trong màn sương mù vĩnh cửu của Rừng Đen, Violetta là truyền thuyết đáng sợ đối với những kẻ xâm nhập bất chính. Với thanh đoản kiếm tẩm độc hoa dạ lan và bước chân không tạo ra bất kỳ âm thanh nào trên lá rụng, nàng bảo vệ ranh giới cổ đại không một sai sót.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Bí Mật Máu Độc',
          content:
              'Ít ai biết rằng nàng từng là công chúa của một vương quốc rừng già bị phản bội bởi chính gia thần. Bị ném xuống đầm lầy chứa kịch độc ngàn năm, nàng không chết mà hòa làm một thể với độc tố, cơ thể trở thành cỗ máy ám sát lạnh lùng và cô độc nhất nhân gian.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Ám Ảnh Hoàng Gia',
          content:
              'Rũ bỏ nỗi oán hận cá nhân, Violetta nhận ra kẻ giật dây sau vụ diệt quốc năm xưa chính là lũ tà thần vực thẳm. Nàng chuyển mục tiêu lưỡi kiếm độc sang những thực thể ma quỷ tối thượng, trở thành cơn ác mộng rình rập giữa các tầng tháp vô tận.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'valeria',
      heroName: 'Valeria',
      heroTitle: 'Sát Thủ Bóng Tối',
      avatarAsset: 'assets/img/characters/003_Valeria_JUNG.webp',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Đứa Con Hư Vô',
          content:
              'Được nuôi dạy từ tấm bé trong tổ chức sát thủ Dạ Ẩn lừng danh, Valeria chỉ biết đến một quy tắc sinh tồn duy nhất: Kẻ chậm hơn một cái chớp mắt sẽ là kẻ phải nằm xuống. Lưỡi dao song sinh của nàng cắt đứt bóng tối nhanh hơn cả vận tốc của gió.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Lưỡi Đao Phản Phệ',
          content:
              'Khi giáo đoàn hạ lệnh trừ khử một ngôi làng vô tội chỉ để phong tỏa tin tức về cổng không gian quỷ dị, Valeria đã lần đầu tiên chống lại mệnh lệnh sư phụ. Nàng một mình huyết chiến với mười đại hộ pháp của Dạ Ẩn, thoát khỏi tổ chức với vết thương khắc sâu trên ngực trái.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Tuyệt Nghệ Hư Không',
          content:
              'Nắm giữ bí kíp dịch chuyển hư không tối thượng, Valeria giờ đây chiến đấu không vì bạc vàng hay thù hận, mà vì niềm kiêu hãnh của một kiếm khách tự do bảo vệ những người vô tội trước sự săn lùng của ma tộc.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'kaelen',
      heroName: 'Kaelen',
      heroTitle: 'Thiết Huyết Chiến Binh',
      avatarAsset: 'assets/img/characters/004_Kaelen_TOP.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Thành Trì Kiên Cố',
          content:
              'Kaelen là đội trưởng cấm vệ quân của Cổng Sắt Vĩ Đại, nơi trấn giữ ranh giới giữa thế giới loài người và sa mạc chết. Tấm khiên thép nặng trăm cân trên tay chàng chưa từng lùi bước trước bất kỳ đợt công thành nào của lũ quái vật man rợ.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Trận Địa Huyết Thệ',
          content:
              'Trong đêm định mệnh mùa đông giá rét, lũ quỷ dữ phá vỡ bức tường phòng thủ. Toàn bộ đồng đội của chàng ngã xuống. Kaelen một mình cắm chặt khiên thép xuống đất, chịu đựng hàng trăm vết thương rỉ máu suốt ba ngày ba đêm cho đến khi viện binh tới nơi.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Bất Khuất Quân Thần',
          content:
              'Cơ thể phủ kín vết sẹo chiến tích nhưng ý chí sắt đá không bao giờ lung lay, Kaelen nâng búa tạ và khiên thần tiến sâu vào lãnh địa địch, trở thành biểu tượng hộ mệnh vững chắc nhất che chở cho đồng đội sau lưng.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'carmilla',
      heroName: 'Carmilla',
      heroTitle: 'Huyết Ma Nữ Vương',
      avatarAsset: 'assets/img/characters/005_Carmilla_JUNG.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Lâu Đài Đêm Trăng',
          content:
              'Trị vì dòng tộc ma cà rồng cổ đại tại Lâu Đài Huyết Nguyệt, Carmilla sở hữu vẻ đẹp kiêu sa bất tử cùng năng lực thao túng huyết dịch đáng kinh ngạc. Nàng luôn duy trì hòa ước cấm sát sinh con người suốt ba trăm năm bình yên.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Ma Dục Thức Tỉnh',
          content:
              'Sự trỗi dậy của Chúa Tể Diablo đã kích hoạt nguồn năng lượng tha hóa trong mạch máu huyết tộc, khiến nhiều thuộc hạ của nàng phát điên cắn xé lẫn nhau. Carmilla buộc phải ra tay thanh trừng những người thân thiết nhất bằng chính móng vuốt huyết ma của mình.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Quyền Năng Thuần Khiết',
          content:
              'Kiểm soát hoàn toàn bản năng khát máu, Carmilla biến dòng máu đỏ rực thành vũ khí trừng phạt tà thần. Nàng tham chiến để đoạt lại sự kiêu hãnh và thanh tẩy nguồn gốc ma thuật huyết tộc khỏi sự thao túng hắc ám.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'elysia',
      heroName: 'Elysia',
      heroTitle: 'Thánh Nữ Ánh Sáng',
      avatarAsset: 'assets/img/characters/006_Elysia_SP.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Phép Màu Bình Minh',
          content:
              'Được tìm thấy dưới chân bức tượng Thần Mặt Trời khi còn là đứa trẻ sơ sinh, Elysia mang trong mình nguồn năng lượng thánh quang thuần khiết nhất điện thờ. Lời cầu nguyện của nàng có thể xua tan mọi bóng ma và làm lành những vết thương chí mạng.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Thử Thách Đức Tin',
          content:
              'Khi đại dịch tà khí bùng phát khắp đại lục, thánh quang của giáo hội bị hoen ố bởi lòng tham của các giám mục thoái hóa. Elysia nhận ra ánh sáng thật sự không nằm trong giáo đường nguy nga, mà tỏa sáng nơi chiến trường cứu giúp những sinh linh lầm than.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Cứu Rỗi Tuyệt Đối',
          content:
              'Mang theo Quyền Trượng Rạng Đông, Elysia bước chân vào nơi tăm tối nhất của thế giới. Nơi đâu có nàng xuất hiện, bóng tối buộc phải lùi bước, trao lại sự sống và hy vọng bất diệt cho toàn nhân loại.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'sylvia',
      heroName: 'Sylvia',
      heroTitle: 'Xạ Thủ Thần Tiễn',
      avatarAsset: 'assets/img/characters/007_Sylvia_AD.webp',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Cung Tên Gió Cuốn',
          content:
              'Là thợ săn tài ba nhất của thảo nguyên phương Bắc, Sylvia có thể bắn trúng mắt chim ưng bay giữa trời lốc xoáy ở cự ly ngàn bước. Cây cung gỗ linh sam gắn liền với nàng từ những ngày đầu theo cha săn thú.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Mũi Tên Băng Phong',
          content:
              'Để bảo vệ bầy đàn trước sự tàn sát của quái vật băng giá Ymir, nàng đã leo lên đỉnh núi cấm lấy Mũi Tên Pha Lê Băng để hợp nhất với linh cung. Giá lạnh ngấm vào đầu ngón tay khiến mỗi phát bắn của nàng mang theo băng tuyết ngưng đọng thời gian.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Thần Tiễn Xuyên Vân',
          content:
              'Đạt tới cảnh giới tâm nhãn hợp nhất, Sylvia không cần nhìn bằng mắt mà cảm nhận nhịp thở của vạn vật qua từng ngọn gió. Mũi tên của nàng sẵn sàng xuyên thủng trái tim của mọi ác thần ngự trị trên đỉnh tháp.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'selene',
      heroName: 'Selene',
      heroTitle: 'Nguyệt Quang Nữ Thần',
      avatarAsset: 'assets/img/characters/008_Selene_SP.webp',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Ánh Trăng Dịu Êm',
          content:
              'Selene ngự trị trên đền thờ Nguyệt Điện ngàn trượng, bảo hộ những lữ khách lạc lối trong đêm thâu. Ánh trăng bàng bạc của nàng vỗ về những tâm hồn rạn vỡ và soi rọi sự thật ẩn giấu sau dối trá của trần gian.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Nguyệt Thực Đẫm Lệ',
          content:
              'Một hiện tượng nguyệt thực vĩnh cửu xảy ra khi ma vương phong ấn vầng trăng tròn, kéo theo hàng ngàn quái thú hư không tràn vào đền thánh. Selene đã hòa tan linh thể vào ánh trăng tàn để cứu thoát các tư tế trung thành.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Nguyệt Thần Giáng Lâm',
          content:
              'Tái tạo hình hài từ ánh nguyệt quang huyền ảo, Selene khoác lên mình tấm áo dệt từ muôn vì tinh tú. Nàng giáng trần để dẫn dắt các dũng sĩ đập tan màn đêm vĩnh cửu, đón chào ánh trăng tự do quay lại.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'aurora',
      heroName: 'Aurora',
      heroTitle: 'Băng Tuyết Nữ Vương',
      avatarAsset: 'assets/img/characters/009_Aurora_TOP.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Cung Điện Băng Giá',
          content:
              'Sinh ra trên vùng đất băng vĩnh cửu nơi không một mầm cây nào sống sót, Aurora nắm giữ quyền năng tối cao điều khiển băng giá từ hơi thở. Trái tim băng lãnh của nàng bảo vệ ngai vàng phương Bắc trước mọi cuộc xâm lăng.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Lửa Thiêu Đất Lạnh',
          content:
              'Hỏa Ma Vương Ifrit dẫn đầu bầy quỷ lửa đốt cháy dãy núi băng tuyết ngàn năm, đe dọa biến quê hương nàng thành biển lửa tro tàn. Aurora đã mở phong ấn Băng Cực Cấm Thuật, hi sinh sự ấm áp vĩnh viễn của cơ thể để đóng băng cả đoàn quân lửa dữ.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Tuyệt Đối Linh Độ',
          content:
              'Cầm trong tay quyền trượng Băng Tuyết Hoàng Gia, Aurora có thể đóng băng cả thời gian và không gian trong tích tắc. Nàng tiến về chiến trường để chứng minh sự kiên cường sắt đá của vùng đất băng tuyết vĩ đại.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'lucia',
      heroName: 'Lucia',
      heroTitle: 'Thợ Săn Hắc Ám',
      avatarAsset: 'assets/img/characters/010_Lucia_JUNG.webp',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Vết Thẹo Quá Khứ',
          content:
              'Gia đình bị ma tộc tàn sát khi nàng vừa lên sáu, Lucia lớn lên với khẩu nỏ săn bạc và lòng căm thù vô bờ bến dành cho sinh vật bóng tối. Nàng đi khắp nẻo đường truy lùng và tiêu diệt mọi dấu vết ma quái.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Ranh Giới Thiện Ác',
          content:
              'Trong một trận phục kích dưới hầm mộ cổ, Lucia bị nhiễm nọc độc của quỷ chúa. Thay vì khuất phục trước tà niệm, nàng dùng ý chí sắt đá giam cầm độc chất trong cánh tay trái, biến sức mạnh bóng tối thành vũ khí phụng sự cho ánh sáng công lý.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Thợ Săn Tối Thượng',
          content:
              'Không còn bị chi phối bởi thù hận mù quáng, Lucia chiến đấu với sự bình thản tuyệt đối của một thợ săn bậc thầy. Từng mũi tên bạc của nàng gieo rắc sự trừng phạt công minh lên mọi tội ác trên trần đời.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'marina',
      heroName: 'Marina',
      heroTitle: 'Hải Dương Hộ Vệ',
      avatarAsset: 'assets/img/characters/011_Marina_SP.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Tiếng Gọi Biển Sâu',
          content:
              'Là hậu duệ cuối cùng của vương triều Người Cá cổ đại, Marina lắng nghe được tiếng gầm của đại dương bao la. Nàng nắm giữ sức mạnh của những đợt triều dâng và những dòng xoáy bảo vệ san hô biển.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Vực Thẳm Đen Kịt',
          content:
              'Tà khí vực thẳm thẩm thấu làm biến chất nguồn nước ngầm, giết chết những đàn cá vô tội và biến vương quốc đáy biển thành nghĩa địa. Marina giơ cao Cây Đinh Ba Hải Thần, dốc hết tinh lực tạo màng chắn nước thanh lọc biển khơi.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Triều Cường Vĩ Đại',
          content:
              'Rời khỏi đại dương thân yêu để bước lên đất liền, Marina mang theo sức mạnh cuồn cuộn của ngàn con sóng. Nàng quyết tâm xóa sổ ngọn nguồn tà khí đang đe dọa sự sống của cả đất mẹ và biển cả.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'seraphina',
      heroName: 'Seraphina',
      heroTitle: 'Chiến Tướng Thiên Giới',
      avatarAsset: 'assets/img/characters/012_Seraphina_JUNG.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Đôi Cánh Rực Lửa',
          content:
              'Chỉ huy quân đoàn thiên thần hộ vệ Thiên Đàng, Seraphina mang đôi cánh thiên thần rực lửa thánh và thanh gươm công lý không tì vết. Nàng đã dẫn đầu hàng trăm chiến dịch đẩy lùi quân đoàn quỷ dữ khỏi ranh giới trần gian.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Sa Ngã Cứu Chuộc',
          content:
              'Để cứu vớt hàng ngàn linh hồn chiến binh bị cầm tù dưới Cửu U Hắc Ngục, Seraphina đã dám vi phạm luật trời, tự xé bỏ một phần đôi cánh thánh thần để đáp xuống địa ngục phá tan xiềng xích ma vương.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Thánh Kiếm Phán Quyết',
          content:
              'Được phong tặng danh hiệu Chiến Thần Bất Tử, Seraphina giờ đây đại diện cho ý chí quật cường của cả thần giới và nhân loại. Lưỡi gươm rực cháy của nàng sẽ phán xét mọi tội ác tại đáy vực thẳm.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'giselle',
      heroName: 'Giselle',
      heroTitle: 'Hỏa Pháo Xạ Thủ',
      avatarAsset: 'assets/img/characters/014_Giselle_AD.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Khói Lửa Công Nghệ',
          content:
              'Thiên tài cơ khí bậc nhất học viện Hextech, Giselle tự tay chế tạo khẩu đại bác Hỏa Long với sức công phá kinh thiên động địa. Nàng luôn đam mê nghiên cứu sự kết hợp giữa ma pháp nguyên tố và cơ học chính xác.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Vụ Nổ Định Mệnh',
          content:
              'Trong một vụ tấn công bất ngờ của quái vật vào xưởng chế tạo, người thầy yêu quý của nàng hi sinh thân mình để che chắn lò phản ứng năng lượng. Kìm nén nước mắt, Giselle vác khẩu pháo mới hoàn thiện bắn tan nát bầy quái vật trả thù.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Bão Đạn Hủy Diệt',
          content:
              'Nâng cấp cỗ máy chiến tranh lên tầm cao mới, Giselle biến chiến trường thành màn pháo hoa rực sáng. Nàng tiến bước cùng đồng đội với lời hứa sẽ dùng khoa học và dũng khí quét sạch bóng tối khỏi quê hương.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'freya',
      heroName: 'Freya',
      heroTitle: 'Thần Nữ Valkyrie',
      avatarAsset: 'assets/img/characters/015_Freya_TOP.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Tiếng Tù Và Valhalla',
          content:
              'Người dẫn lối những linh hồn dũng cảm về đại điện Valhalla, Freya cưỡi tuấn mã thiên lý bay lượn trên chiến trường đẫm máu. Với ngọn giáo thần và tấm khiên vàng, nàng bảo hộ danh dự của những chiến binh kiên cường nhất.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Buổi Hoàng Hôn Thần Tộc',
          content:
              'Điềm báo Ragnarok giáng xuống, các cổ thần lần lượt chìm vào giấc ngủ ngàn thu trước sự tấn công của Rồng Hỗn Mang. Freya từ chối bỏ trốn, ở lại chiến tuyến cuối cùng tử thủ cùng những linh hồn trung nghĩa.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Valkyrie Bất Tử',
          content:
              'Ngọn giáo thần trong tay Freya thắp sáng niềm hy vọng mới cho kỷ nguyên nhân loại. Nàng thề sẽ đánh bại Rồng Ragnarok và chấn hưng trật tự hòa bình cho tam giới.',
        ),
      ],
    ),
    HeroStory(
      heroId: 'mai',
      heroName: 'Mai',
      heroTitle: 'Nữ Kiếm Tôn',
      avatarAsset: 'assets/img/characters/016_Mai_TOP.jpg',
      chapters: [
        StoryChapter(
          chapterNumber: 1,
          requiredLevel: 5,
          title: 'Chương 1: Nhát Kiếm Đơn Độc',
          content:
              'Luyện kiếm từ khi chập chững biết đi dưới chân rặng hoa đào tuyết phủ, Mai coi thanh kiếm Katana như chính sinh mệnh của mình. Phong thái thanh tao nhưng đường kiếm nhanh như chớp giật khiến mọi kiếm khách đương thời phải bái phục.',
        ),
        StoryChapter(
          chapterNumber: 2,
          requiredLevel: 15,
          title: 'Chương 2: Tâm Kiếm Thức Tỉnh',
          content:
              'Võ đường gia tộc bị Ma Tôn san phẳng trong một đêm trăng máu. Trải qua nỗi đau tột cùng, Mai ngộ ra chân lý Kiếm Đạo: Kiếm thuật không phải để khoe khoang hay báo thù, mà là công cụ để bảo vệ sự sống và chính nghĩa.',
        ),
        StoryChapter(
          chapterNumber: 3,
          requiredLevel: 30,
          title: 'Chương 3: Vạn Kiếm Quy Tông',
          content:
              'Hòa nhập tâm hồn với thanh linh kiếm truyền thừa, Mai đã đạt cảnh giới Người và Kiếm là Một. Mỗi đường kiếm chém ra mang theo anh hoa rực rỡ, sẵn sàng trảm trừ mọi ma chướng trên con đường chính đạo.',
        ),
      ],
    ),
  ];

  static HeroStory? getById(String id) {
    try {
      return allStories.firstWhere((s) => s.heroId == id);
    } catch (_) {
      return allStories.first;
    }
  }
}
