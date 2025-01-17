// Import thư viện 'just_audio' để phát âm thanh và 'rxdart' để xử lý luồng dữ liệu.
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// Lớp quản lý AudioPlayer.
class AudioPlayerManager {
  // Constructor nội bộ để đảm bảo chỉ tạo một instance duy nhất.
  AudioPlayerManager._internal();

  // Tạo instance singleton để sử dụng toàn cục.
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  // Phương thức factory để trả về instance duy nhất.
  factory AudioPlayerManager() => _instance;

  // Khởi tạo đối tượng AudioPlayer từ thư viện 'just_audio'.
  final player = AudioPlayer();

  // Biến stream để cung cấp trạng thái tiến trình âm thanh.
  Stream<DurationState>? durationState;

  // URL của bài hát hiện tại.
  String songUrl = "";

  // Phương thức chuẩn bị phát bài hát.
  void prepare({bool isNewSong = false}) {
    // Kết hợp luồng vị trí phát và sự kiện phát để tạo ra trạng thái tiến trình.
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream, // Luồng vị trí phát.
        player.playbackEventStream, // Luồng sự kiện phát.
            (position, playbackEvent) =>
            DurationState( // Tạo một đối tượng DurationState.
                progress: position, // Thời gian đã phát.
                buffered: playbackEvent.bufferedPosition, // Thời gian đã tải trước.
                total: playbackEvent.duration)); // Tổng thời gian bài hát.

    // Nếu là bài hát mới, thiết lập URL cho player.
    if (isNewSong) {
      player.setUrl(songUrl);
    }
  }

  // Phương thức cập nhật URL của bài hát.
  void updateSongUrl(String url) {
    songUrl = url; // Gán URL mới cho biến songUrl.
    prepare(); // Gọi lại phương thức prepare.
  }

  // Phương thức giải phóng tài nguyên khi không còn sử dụng.
  void dispose() {
    player.dispose(); // Dừng và giải phóng AudioPlayer.
  }
}

// Lớp lưu trữ trạng thái của thời lượng bài hát.
class DurationState {
  const DurationState({
    required this.progress, // Thời gian đã phát.
    required this.buffered, // Thời gian đã tải trước.
    this.total, // Tổng thời gian bài hát (có thể null).
  });

  final Duration progress; // Tiến trình phát.
  final Duration buffered; // Tiến trình tải.
  final Duration? total; // Tổng thời gian (có thể null nếu chưa xác định).
}
