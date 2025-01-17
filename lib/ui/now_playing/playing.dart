import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController; // Quản lý hoạt ảnh xoay ảnh album
  late AudioPlayerManager _audioPlayerManager; // Quản lý phát nhạc
  late int _selectedItemIndex; // Chỉ số bài hát đang được chọn
  late Song _song; // Bài hát hiện tại
  late double _currentAnimationPosition = 0.0; // Vị trí hiện tại của hoạt ảnh
  bool _isShuffle = false; // Trạng thái trộn bài
  late LoopMode _loopMode; // Chế độ lặp lại bài hát

  //Đoạn code trên nằm trong phương thức initState() của một StatefulWidget trong Flutter. Phương thức này được gọi một lần khi widget được khởi tạo và được sử dụng để thiết lập trạng thái ban đầu của widget.
  // Đoạn mã này chủ yếu được thiết kế cho một ứng dụng phát nhạc, có các chức năng như quản lý bài hát, thiết lập hoạt ảnh (animation), và cấu hình chế độ phát nhạc.
  @override
  void initState() {
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.playingSong;//Lấy bài hát hiện tại
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    _audioPlayerManager = AudioPlayerManager(); //Quản lý các hành động như phát, dừng, chuẩn bị bài hát mới, và xử lý các sự kiện liên quan đến âm thanh.


    if (_audioPlayerManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }

    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    // Xác định chỉ số bài hát
    _loopMode = LoopMode.off;// Mặc định là không lặp
  }

  //giải phóng bộ nhớ
  @override
  void dispose() {
    _imageAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'Now Playing',
          ),
          trailing:
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_song.album),
                const SizedBox(
                  height: 16,
                ),
                const Text('_ ___ _ '),
                const SizedBox(
                  height: 48,
                ),

                // ảnh nhạc xoay
                RotationTransition(
                  turns:
                  Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/itunes_256.png', //Ảnh chờ
                      image: _song.image,
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/itunes_256.png',//Ảnh thay thế nếu lô
                          width: screenWidth - delta,
                          height: screenWidth - delta,
                        );
                      },
                    ),
                  ),
                ),

                // nút share + tên + nút tim
                Padding(
                  padding: const EdgeInsets.only(top: 64, bottom: 16),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // nút share
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                          color: Theme.of(context).colorScheme.primary,
                        ),

                        // tên
                        Column(
                          children: [
                            Text(
                              _song.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              _song.artist,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            )
                          ],
                        ),

                        //nút tim
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_outline),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      ],
                    ),
                  ),
                ),

                Padding(
                  // thanh load tiến trình phát
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  child: _progressBar(),
                ),
                Padding(
                  // các nút tương tác nhạc
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                  ),
                  child: _mediaButtons(),
                )
              ],
            ),
          ),
        ));
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 36),
          MediaButtonControl(
              function: _setupRepeatOption,
              icon: _repeatingIcon(),
              color: _getRepeatingIconColor(),
              size: 24),
        ],
      ),
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  void _setNextSong() {
    // Nếu chế độ Shuffle (phát ngẫu nhiên) đang bật
    if (_isShuffle) {
      var random = Random(); // Tạo đối tượng Random để chọn bài ngẫu nhiên
      _selectedItemIndex = random.nextInt(widget.songs.length);
      // Chọn ngẫu nhiên một chỉ số bài hát từ danh sách `songs`
    }

    // Nếu không ở chế độ Shuffle, chuyển sang bài tiếp theo nếu còn bài
    else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex; // Tăng chỉ số bài hát hiện tại lên 1 (chuyển bài)
    }

    // Xử lý khi danh sách bài hát đã phát hết và chế độ Loop All đang bật
    else if (_loopMode == LoopMode.all &&
        _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0; // Quay lại bài đầu tiên trong danh sách

      // Xử lý chỉ số bài hát vượt quá số lượng bài (phòng trường hợp bất ngờ)
      if (_selectedItemIndex >= widget.songs.length) {
        _selectedItemIndex = _selectedItemIndex % widget.songs.length;
        // Lấy phần dư để đảm bảo chỉ số không vượt quá phạm vi danh sách
      }

      // Lấy bài hát kế tiếp dựa trên chỉ số đã cập nhật
      final nextSong = widget.songs[_selectedItemIndex];

      // Cập nhật URL bài hát cho trình phát
      _audioPlayerManager.updateSongUrl(nextSong.source);

      // Cập nhật trạng thái bài hát hiện tại và thông báo giao diện
      setState(() {
        _song = nextSong; // Lưu bài hát hiện tại vào biến `_song`
      });
    }
  }

  void _setPrevSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }
    else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  void _setupRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }

  //phần seekbar
  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      // Lắng nghe stream từ _audioPlayerManager.durationState
      // Đây là nơi cung cấp thông tin về thời lượng (progress, buffered, total) của media.
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          // Lấy dữ liệu từ snapshot của stream
          final durationState = snapshot.data;

          // Tiến trình hiện tại của bài hát (đã phát được bao nhiêu thời gian)
          final progress = durationState?.progress ?? Duration.zero;

          // Tiến trình đã được buffer (tải trước) để phát mà không bị giật
          final buffered = durationState?.buffered ?? Duration.zero;

          // Tổng thời lượng của bài hát
          final total = durationState?.total ?? Duration.zero;

          // Trả về widget ProgressBar hiển thị tiến trình của media
          return ProgressBar(
            // Tiến trình hiện tại (dựa trên progress)
            progress: progress,

            // Tổng thời lượng của media
            total: total,

            // Phần đã buffer (nếu có)
            buffered: buffered,

            // Hàm xử lý khi người dùng kéo để seek tới thời gian khác
            onSeek: _audioPlayerManager.player.seek,

            // Chiều cao của thanh tiến trình
            barHeight: 5.0,

            // Hình dạng của đầu thanh tiến trình (bo tròn)
            barCapShape: BarCapShape.round,

            // Màu nền của thanh tiến trình
            baseBarColor: Colors.grey.withOpacity(0.3),

            // Màu thanh tiến trình hiển thị phần đã phát
            progressBarColor: Colors.green,

            // Màu thanh tiến trình hiển thị phần đã buffer
            bufferedBarColor: Colors.grey.withOpacity(0.3),

            // Màu của nút điều khiển (thumb)
            thumbColor: Colors.deepPurple,

            // Màu sáng khi nút điều khiển được chọn (glow effect)
            thumbGlowColor: Colors.green.withOpacity(0.3),

            // Bán kính của nút điều khiển
            thumbRadius: 10.0,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      // Stream lắng nghe trạng thái của player
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          // Lấy dữ liệu PlayerState từ snapshot
          final playState = snapshot.data;

          // Lấy trạng thái xử lý của player (loading, buffering, ready, completed, ...)
          final processingState = playState?.processingState;

          // Kiểm tra xem player có đang phát nhạc không
          final playing = playState?.playing;

          // Xử lý khi player đang tải (loading) hoặc buffer (buffering)
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8), // Căn lề xung quanh nút
              width: 48, // Chiều rộng của container
              height: 48, // Chiều cao của container
              child: const CircularProgressIndicator(), // Hiển thị vòng tròn xoay (loading)
            );
          }

          // Xử lý khi player không phát (paused hoặc chưa phát)
          else if (playing != true) {
            return MediaButtonControl(
              // Hàm được gọi khi nhấn nút Play
                function: () {
                  _audioPlayerManager.player.play(); // Bắt đầu phát nhạc

                  // Tiến hành hoạt động với animation:
                  // Tiếp tục hoạt ảnh từ vị trí hiện tại và lặp lại
                  _imageAnimController.forward(from: _currentAnimationPosition);
                  _imageAnimController.repeat();
                },
                icon: Icons.play_arrow, // Icon nút Play
                color: null, // Màu của nút (null: sử dụng mặc định)
                size: 48); // Kích thước của nút
          }

          // Xử lý khi player đang phát nhưng chưa hoàn tất bài hát
          else if (processingState != ProcessingState.completed) {
            return MediaButtonControl(
              // Hàm được gọi khi nhấn nút Pause
                function: () {
                  _audioPlayerManager.player.pause(); // Tạm dừng phát nhạc

                  // Dừng hoạt ảnh
                  _imageAnimController.stop();

                  // Lưu vị trí hiện tại của hoạt ảnh
                  _currentAnimationPosition = _imageAnimController.value;
                },
                icon: Icons.pause, // Icon nút Pause
                color: null,
                size: 48);
          }

          // Xử lý khi bài hát đã hoàn tất phát
          else {
            // Khi trạng thái là completed => Dừng và reset animation
            if (processingState == ProcessingState.completed) {
              _imageAnimController.stop(); // Dừng hoạt ảnh
              _currentAnimationPosition = 0.0; // Reset vị trí hoạt ảnh về 0
            }
            return MediaButtonControl(
              // Hàm được gọi khi nhấn nút Replay
                function: () {
                  // Bắt đầu lại hoạt ảnh
                  _imageAnimController.forward(from: _currentAnimationPosition);
                  _imageAnimController.repeat();

                  // Phát lại bài hát từ đầu
                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay, // Icon nút Replay
                color: null,
                size: 48);
          }
        });
  }

}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
