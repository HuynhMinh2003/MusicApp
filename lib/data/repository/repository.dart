// Import các thư viện cần thiết từ các file khác
import 'package:music_app/data/source/source.dart'; // Import các nguồn dữ liệu (local và remote)
import '../model/song.dart'; // Import model Song để sử dụng trong danh sách bài hát

// Định nghĩa một interface `Repository` để tải danh sách các bài hát
abstract interface class Repository {
  // Phương thức trừu tượng `loadData` để tải danh sách bài hát, trả về một Future chứa danh sách các bài hát hoặc null
  Future<List<Song>?> loadData();
}

// Implement interface Repository bởi `DefaultRepository`
class DefaultRepository implements Repository {
  // Khởi tạo hai nguồn dữ liệu: local và remote
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  // Phương thức tải dữ liệu danh sách các bài hát
  @override
  Future<List<Song>?> loadData() async {
    // Danh sách chứa các bài hát
    List<Song> songs = [];

    // Gọi phương thức loadData từ remoteDataSource
    await _remoteDataSource.loadData().then((remoteSongs) async {
      // Nếu không có dữ liệu từ remote (remoteSongs == null)
      if (remoteSongs == null) {
        // Gọi loadData từ localDataSource
        _localDataSource.loadData().then((localSongs) {
          // Nếu localSongs không null, thêm vào danh sách
          if (localSongs != null) {
            songs.addAll(localSongs);
          }
        });
      } else {
        // Nếu có dữ liệu từ remote, thêm dữ liệu đó vào danh sách
        songs.addAll(remoteSongs);
      }
    });
    // Trả về danh sách bài hát đã thu thập được
    return songs;
  }
}


// Future<List<Song>?> loadData() async {
//   List<Song> songs = [];
//   final remoteSongs = await _remoteDataSource.loadData();
//   if (remoteSongs != null) {
//     songs.addAll(remoteSongs);
//   } else {
//     final localSongs = await _localDataSource.loadData();
//     if (localSongs != null) {
//       songs.addAll(localSongs);
//     }
//   }
//   return songs;
// }

