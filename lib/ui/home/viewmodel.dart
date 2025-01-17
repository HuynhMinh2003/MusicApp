// Import các thư viện cần thiết
import 'dart:async'; // Sử dụng thư viện để làm việc với Stream và StreamController
import 'package:music_app/data/repository/repository.dart'; // Import lớp Repository để sử dụng
import '../../data/model/song.dart'; // Import model Song để làm việc với danh sách bài hát

// Định nghĩa lớp MusicAppViewModel
class MusicAppViewModel {
  // StreamController để quản lý luồng dữ liệu danh sách bài hát
  StreamController<List<Song>> songStream = StreamController();

  // Phương thức để tải danh sách bài hát
  void loadSongs() {
    // Khởi tạo một repository mặc định
    final repository = DefaultRepository();
    // Gọi phương thức loadData từ repository để tải dữ liệu
    repository.loadData().then((value) =>
    // Đẩy dữ liệu (value) vào StreamController
    songStream.add(value!)
    );
  }
}
