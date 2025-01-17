// Import các thư viện cần thiết
import 'dart:convert'; // Để chuyển đổi giữa JSON và Dart objects
import 'package:flutter/services.dart'; // Thư viện Flutter hỗ trợ các tiện ích
import '../model/song.dart'; // Import model Song để ánh xạ dữ liệu JSON thành đối tượng
import 'package:http/http.dart' as http; // Thư viện để thực hiện các yêu cầu HTTP

// Định nghĩa một interface `DataSource` để làm nguồn dữ liệu
abstract interface class DataSource {
  // Phương thức trừu tượng `loadData` để tải danh sách bài hát
  Future<List<Song>?> loadData();
}

// Triển khai interface `DataSource` trong `RemoteDataSource`
class RemoteDataSource implements DataSource {
  // Ghi đè phương thức `loadData` để tải dữ liệu từ nguồn từ xa
  @override
  Future<List<Song>?> loadData() async {
    // URL của API chứa danh sách bài hát
    const url = 'https://thantrieu.com/resources/braniumapis/songs.json';
    final uri = Uri.parse(url); // Chuyển đổi URL thành đối tượng URI

    // Gửi yêu cầu GET đến server
    final response = await http.get(uri);

    // Kiểm tra mã trạng thái của phản hồi
    if (response.statusCode == 200) {
      // Nếu phản hồi thành công (statusCode == 200)

      // Chuyển đổi ký tự UTF-8 để xử lý tiếng Việt
      final bodyContent = utf8.decode(response.bodyBytes);

      // Phân tích chuỗi JSON thành một map
      var songWrapper = jsonDecode(bodyContent) as Map;

      // Lấy danh sách các bài hát từ key 'songs'
      var songList = songWrapper['songs'] as List;

      // Chuyển danh sách JSON thành danh sách các đối tượng Song
      List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();

      // Trả về danh sách các bài hát
      return songs;
    } else {
      // Nếu phản hồi không thành công, trả về null
      return null;
    }
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    try {
      // Đọc tệp JSON từ thư mục assets
      final String response = await rootBundle.loadString('assets/songs.json');
      print("Tệp JSON đã được tải: $response");

      // Phân tích cú pháp JSON
      final jsonBody = jsonDecode(response) as Map;
      final songList = jsonBody['songs'] as List;
      print("Danh sách bài hát: $songList");

      // Chuyển đổi sang đối tượng Song
      return songList.map((song) => Song.fromJson(song)).toList();
    } catch (e) {
      print("Lỗi khi tải dữ liệu từ tệp cục bộ: $e");
      return null;
    }
  }
}
