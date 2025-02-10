// Import các thư viện cần thiết
import 'dart:async'; // Sử dụng thư viện để làm việc với Stream và StreamController
import 'package:music_app/data/repository/repository.dart'; // Import lớp Repository để sử dụng
import '../../data/model/song.dart'; // Import model Song để làm việc với danh sách bài hát

// Định nghĩa lớp MusicAppViewModel
class MusicAppViewModel {
  // StreamController để quản lý danh sách bài hát
  final StreamController<List<Song>> songStream = StreamController();

  // Phương thức tải danh sách bài hát từ Repository
  void loadSongs() async {
    final repository = DefaultRepository();
    final songs = await repository.loadData();

    // Kiểm tra nếu songs không null, thì thêm vào Stream
    if (songs != null) {
      songStream.add(songs);
    }
  }

  // Phương thức để giải phóng tài nguyên (tránh rò rỉ bộ nhớ)
  void dispose() {
    songStream.close();
  }
}

