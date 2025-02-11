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
  late AnimationController
      _imageAnimController; // Quản lý hoạt ảnh xoay ảnh album
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
    _song = widget.playingSong; //Lấy bài hát hiện tại
    // _imageAnimController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 12000),
    // );
    // Lấy AnimationController từ AudioPlayerManager
    // Lắng nghe trạng thái của AudioPlayer
    _imageAnimController = AudioPlayerManager().rotationController ??
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 10), // Xoay 1 vòng trong 10 giây
        ); // Lặp vô hạn

    // Cập nhật lại controller để dùng lần sau
    AudioPlayerManager().rotationController = _imageAnimController;

    // 🛑 Chỉ xoay nếu nhạc đang phát
    if (AudioPlayerManager().isPlaying) {
      _imageAnimController.repeat();
    }

    _audioPlayerManager =
        AudioPlayerManager(); //Quản lý các hành động như phát, dừng, chuẩn bị bài hát mới, và xử lý các sự kiện liên quan đến âm thanh.

    if (_audioPlayerManager.songUrl?.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }

    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    // Xác định chỉ số bài hát
    _loopMode = LoopMode.off; // Mặc định là không lặp
  }

  //giải phóng bộ nhớ
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
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
                const SizedBox(
                  height: 16,
                ),
                Text(_song.album),
                const SizedBox(
                  height: 16,
                ),
                const Text('_ ___ _ '),
                const SizedBox(
                  height: 48,
                ),

                // Ảnh nhạc xoay có viền đĩa và lỗ trung tâm
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Viền đĩa nhạc
                    Container(
                      width: screenWidth - delta + 20,
                      // Kích thước lớn hơn ảnh một chút
                      height: screenWidth - delta + 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        // Màu nền giống đĩa nhạc
                        border:
                            Border.all(color: Colors.grey.shade800, width: 4),
                        // Viền ngoài
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // Ảnh nhạc xoay bên trong
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_imageAnimController),
                      child: ClipOval(
                        // Cắt ảnh thành hình tròn
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/itunes_256.png',
                          // Ảnh chờ
                          image: _song.image,
                          width: screenWidth - delta,
                          height: screenWidth - delta,
                          fit: BoxFit.cover,
                          // Đảm bảo ảnh đầy đủ trong vùng
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/itunes_256.png', // Ảnh thay thế nếu lỗi
                              width: screenWidth - delta,
                              height: screenWidth - delta,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    // // Lỗ nhỏ ở giữa đĩa nhạc
                    // Container(
                    //   width: 20, // Kích thước lỗ nhỏ
                    //   height: 20,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: Colors.black,
                    //     // Màu đen để tạo cảm giác lỗ trên đĩa
                    //     border: Border.all(
                    //         color: Colors.grey.shade600,
                    //         width: 2), // Viền nhẹ để nổi bật
                    //   ),
                    // ),
                  ],
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
    if (widget.songs.isEmpty) return; // Nếu danh sách rỗng, thoát

    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all) {
      _selectedItemIndex = 0;
    }

    // Lấy bài hát mới
    final nextSong = widget.songs[_selectedItemIndex];

    print("🎵 Chuyển sang bài hát mới: ${nextSong.title}"); // Debug log

    // Cập nhật trình phát
    _audioPlayerManager.updateSongUrl(nextSong.source);

    // Cập nhật UI
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    if (widget.songs.isEmpty) return; // Nếu danh sách rỗng, thoát

    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all) {
      _selectedItemIndex = widget.songs.length - 1;
    }

    // Lấy bài hát mới
    final prevSong = widget.songs[_selectedItemIndex];

    // Cập nhật trình phát
    _audioPlayerManager.updateSongUrl(prevSong.source);

    // Cập nhật UI
    setState(() {
      _song = prevSong;
    });
  }

  void _setupRepeatOption() {
    setState(() {
      if (_loopMode == LoopMode.off) {
        _loopMode = LoopMode.one;
      } else if (_loopMode == LoopMode.one) {
        _loopMode = LoopMode.all;
      } else {
        _loopMode = LoopMode.off;
      }

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
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Hiển thị loading khi chưa có dữ liệu
        }

        final durationState = snapshot.data!;
        // final progress = durationState.progress ?? Duration.zero;
        // final buffered = durationState.buffered ?? Duration.zero;
        // final total = durationState.total ?? Duration.zero;

        return ProgressBar(
          progress: durationState.progress,
          total: durationState.total ?? Duration.zero,
          buffered: durationState.buffered,
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 5.0,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.grey.withOpacity(0.3),
          progressBarColor: Colors.green,
          bufferedBarColor: Colors.grey.withOpacity(0.3),
          thumbColor: Colors.deepPurple,
          thumbGlowColor: Colors.green.withOpacity(0.3),
          thumbRadius: 10.0,
        );
      },
    );
  }

  // StreamBuilder<PlayerState> _playButton() {
  //   return StreamBuilder(
  //     // Stream lắng nghe trạng thái của player
  //       stream: _audioPlayerManager.player.playerStateStream,
  //       builder: (context, snapshot)
  //       {
  //         // Lấy dữ liệu PlayerState từ snapshot
  //         final playState = snapshot.data;
  //
  //         // Lấy trạng thái xử lý của player (loading, buffering, ready, completed, ...)
  //         final processingState = playState?.processingState;
  //
  //         // Kiểm tra xem player có đang phát nhạc không
  //         final playing = playState?.playing;
  //
  //         // Xử lý khi player đang tải (loading) hoặc buffer (buffering)
  //         if (processingState == ProcessingState.loading ||
  //             processingState == ProcessingState.buffering) {
  //           return Container(
  //             margin: const EdgeInsets.all(8), // Căn lề xung quanh nút
  //             width: 48, // Chiều rộng của container
  //             height: 48, // Chiều cao của container
  //             child: const CircularProgressIndicator(), // Hiển thị vòng tròn xoay (loading)
  //           );
  //         }
  //
  //         // Xử lý khi player không phát (paused hoặc chưa phát)
  //         else if (playing != true) {
  //           return MediaButtonControl(
  //             // Hàm được gọi khi nhấn nút Play
  //               function: () {
  //                 _audioPlayerManager.player.play(); // Bắt đầu phát nhạc
  //
  //                 // Tiến hành hoạt động với animation:
  //                 // Tiếp tục hoạt ảnh từ vị trí hiện tại và lặp lại
  //                 _imageAnimController.forward(from: _currentAnimationPosition);
  //                 _imageAnimController.repeat();
  //               },
  //               icon: Icons.play_arrow, // Icon nút Play
  //               color: null, // Màu của nút (null: sử dụng mặc định)
  //               size: 48); // Kích thước của nút
  //         }
  //
  //         // Xử lý khi player đang phát nhưng chưa hoàn tất bài hát
  //         else if (processingState != ProcessingState.completed) {
  //           return MediaButtonControl(
  //             // Hàm được gọi khi nhấn nút Pause
  //               function: () {
  //                 _audioPlayerManager.player.pause(); // Tạm dừng phát nhạc
  //
  //                 // Dừng hoạt ảnh
  //                 _imageAnimController.stop();
  //
  //                 // Lưu vị trí hiện tại của hoạt ảnh
  //                 _currentAnimationPosition = _imageAnimController.value;
  //               },
  //               icon: Icons.pause, // Icon nút Pause
  //               color: null,
  //               size: 48);
  //         }
  //
  //         // Xử lý khi bài hát đã hoàn tất phát
  //         else {
  //           if (processingState == ProcessingState.completed) {
  //             _imageAnimController.stop();
  //             _currentAnimationPosition = 0.0;
  //
  //             // Kiểm tra nếu đang ở chế độ lặp toàn bộ thì phát bài tiếp theo
  //             if (_loopMode == LoopMode.all || _loopMode == LoopMode.off) {
  //               _setNextSong(); // Hàm chuyển bài
  //             } else {
  //               // Nếu lặp 1 bài thì phát lại từ đầu
  //               _audioPlayerManager.player.seek(Duration.zero);
  //               _audioPlayerManager.player.play();
  //               _imageAnimController.forward(from: 0);
  //               _imageAnimController.repeat();
  //             }
  //           }
  //           return const SizedBox.shrink(); // Ẩn nút Replay khi auto chuyển bài
  //         }
  //
  //         //   // Xử lý khi bài hát đã hoàn tất phát
  //         //   else {
  //         // // Khi trạng thái là completed => Kiểm tra chế độ lặp
  //         // if (processingState == ProcessingState.completed) {
  //         // _imageAnimController.stop(); // Dừng hoạt ảnh
  //         // _currentAnimationPosition = 0.0; // Reset vị trí hoạt ảnh về 0
  //         // }
  //         //
  //         // return MediaButtonControl(
  //         // function: () {
  //         // // Nếu không ở LoopMode.all, phát lại bài hiện tại
  //         // _imageAnimController.forward(from: _currentAnimationPosition);
  //         // _imageAnimController.repeat();
  //         //
  //         // // Phát lại bài hát từ đầu
  //         // _audioPlayerManager.player.seek(Duration.zero);
  //         // },
  //         // icon: Icons.replay, // Icon thay đổi tùy theo chế độ
  //         // color: null,
  //         // size: 48,
  //         // );
  //         // }
  //       });
  // }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        }

        // Nếu player chưa phát
        if (playing != true) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.play();
              _imageAnimController.forward(from: _currentAnimationPosition);
              _imageAnimController.repeat();
            },
            icon: Icons.play_arrow,
            color: null,
            size: 48,
          );
        }

        // Nếu player đang phát
        if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              _imageAnimController.stop();
              _currentAnimationPosition = _imageAnimController.value;
            },
            icon: Icons.pause,
            color: null,
            size: 48,
          );
        }

        // Khi bài hát kết thúc
        if (processingState == ProcessingState.completed) {
          // _imageAnimController.stop();
          // _currentAnimationPosition = 0.0;

          if (_loopMode == LoopMode.all || _loopMode == LoopMode.off) {
            // Chuyển sang bài hát tiếp theo
            Future.microtask(() {
              setState(() {
                _setNextSong();
              });
            });
          } else {
            // Lặp lại bài hát
            _audioPlayerManager.player.seek(Duration.zero);
            _audioPlayerManager.player.play();
            _imageAnimController.forward(from: 0);
            _imageAnimController.repeat();
          }
        }

        return const SizedBox.shrink(); // Ẩn nút khi auto chuyển bài
      },
    );
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
