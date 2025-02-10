// Import thư viện 'just_audio' để phát âm thanh và 'rxdart' để xử lý luồng dữ liệu.
import 'package:flutter/animation.dart';
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
  String? songUrl;

  // Tạo AnimationController để duy trì trạng thái xoay ảnh album
  AnimationController? rotationController;

  bool isPlaying = false; // 🟢 Trạng thái nhạc (đang phát hoặc dừng)

  // Phương thức chuẩn bị phát bài hát.
  Future<void> prepare({bool isNewSong = false}) async{
    // Nếu chưa có URL, không làm gì cả
    if (songUrl == null || songUrl!.isEmpty) return;
    // Kết hợp luồng vị trí phát và sự kiện phát để tạo ra trạng thái tiến trình.
    durationState = Rx.combineLatest2<Duration, Duration?, DurationState>(
        player.positionStream, // Vị trí phát ht.
        player.durationStream, // Tổng thời lượng bh.
            (position, total) =>
            DurationState( // Tạo một đối tượng DurationState.
                progress: position, // Thời gian đã phát.
                buffered: player.bufferedPosition, // Thời gian đã tải trước.
                total: total ?? Duration.zero,)); // Tổng thời gian bài hát.

    // Nếu là bài hát mới, thiết lập URL cho player.
    if (isNewSong) {
      await player.setUrl(songUrl!);
    }
  }

  // Phương thức cập nhật URL của bài hát.
  Future<void> updateSongUrl(String url) async{
    if (url != songUrl) {
      songUrl = url;
      await prepare(isNewSong: true);
    }else {
      await prepare(isNewSong: false); // Gọi lại prepare() để đảm bảo trình phát hoạt động
    }
  }

  // // Phương thức phát nhạc
  // Future<void> play() async {
  //   if (player.playing) return;
  //   await player.play();
  // }
  //
  // // Phương thức tạm dừng nhạc
  // Future<void> pause() async {
  //   await player.pause();
  // }
  //
  // // Phương thức dừng nhạc
  // Future<void> stop() async {
  //   await player.stop();
  // }

  // Phương thức giải phóng tài nguyên khi không còn sử dụng.
  void dispose() {
    //player.dispose(); // Dừng và giải phóng AudioPlayer.
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
