import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false, //xóa cái banner debug
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}


// cái khung gồm các tab
class _MusicHomePageState extends State<MusicHomePage> {
  //mỗi widget đại diện cho 1 tab
  final List<Widget> _tabs = [
    const HomeTab(),
    const Discovery(),
    const SettingsTab(),
    const AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Music App'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

//muốn thay đổi gì thì thay đổi trực tiếp ở đây
class _HomeTabPageState extends State<HomeTabPage> {
  // Danh sách bài hát, ban đầu được khởi tạo rỗng
  List<Song> songs = [];

  // ViewModel chịu trách nhiệm tải dữ liệu bài hát và cung cấp luồng dữ liệu
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    // Khởi tạo ViewModel
    _viewModel = MusicAppViewModel();

    // Gọi phương thức loadSongs để bắt đầu tải danh sách bài hát
    _viewModel.loadSongs();

    // Lắng nghe dữ liệu từ stream
    observeData();

    // Gọi phương thức initState của lớp cha
    super.initState();
  }

  @override
  void dispose() {
    // Đóng stream để giải phóng tài nguyên
    _viewModel.songStream.close();

    // Giải phóng trình quản lý AudioPlayer
    AudioPlayerManager().dispose();

    // Gọi phương thức dispose của lớp cha
    super.dispose();
  }

  // Lắng nghe luồng dữ liệu từ ViewModel và cập nhật danh sách bài hát
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        // Thêm các bài hát mới vào danh sách
        songs.addAll(songList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Trả về một Scaffold chứa body được tạo từ getBody()
    return Scaffold(
      body: getBody(),
    );
  }

  // Phương thức trả về giao diện body chính
  Widget getBody() {
    // Xác định xem danh sách bài hát đã được tải chưa
    bool showLoading = songs.isEmpty;

    // Nếu chưa có bài hát, hiển thị vòng tròn loading
    if (showLoading) {
      return getProgressBar();
    } else {
      // Nếu có bài hát, hiển thị danh sách
      return getListView();
    }
  }

  // Hiển thị vòng tròn loading
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Tạo danh sách cuộn để hiển thị các bài hát
  ListView getListView() {
    return ListView.separated(
      // Tạo từng dòng trong danh sách
      itemBuilder: (context, position) {
        return getRow(position);
      },
      // Chèn đường phân cách giữa các dòng
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      // Số lượng bài hát trong danh sách
      itemCount: songs.length,
      // Tắt tính năng cuộn của danh sách bên trong widget cha
      shrinkWrap: true,
    );
  }

  // Tạo widget hiển thị cho từng bài hát trong danh sách
  Widget getRow(int index) {
    return _SongItemSection(
      parent: this, // Truyền đối tượng cha để gọi lại các hàm từ đây
      song: songs[index], // Truyền bài hát hiện tại
    );
  }

  // Hiển thị một bảng thông báo từ dưới màn hình (bottom sheet)
  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 400, // Chiều cao của bottom sheet
            color: Colors.green, // Màu nền của bottom sheet
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Nội dung bảng thông báo
                  const Text('Modal Bottom Sheet'),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    // Đóng bảng thông báo
                    child: const Text('Close Bottom Sheet'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Điều hướng tới màn hình NowPlaying với bài hát được chọn
  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs, // Truyền danh sách bài hát
        playingSong: song, // Truyền bài hát đang phát
      );
    }));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent, // Tham chiếu đến State của màn hình cha (_HomeTabPageState)
    required this.song, // Thông tin bài hát (tiêu đề, nghệ sĩ, ảnh, v.v.)
  });

  final _HomeTabPageState parent; // Lớp cha để gọi các phương thức điều hướng và hiển thị Bottom Sheet
  final Song song; // Dữ liệu bài hát hiện tại

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24, // Khoảng cách bên trái của item
        right: 8, // Khoảng cách bên phải của item
      ),

      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8), // Bo góc ảnh của bài hát
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes_256.png', // Ảnh placeholder khi đang tải ảnh từ mạng
          image: song.image, // Đường dẫn ảnh bài hát từ dữ liệu bài hát
          width: 48, // Chiều rộng của ảnh
          height: 48, // Chiều cao của ảnh
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes_256.png', // Hiển thị ảnh mặc định nếu tải ảnh từ mạng thất bại
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title), // Hiển thị tiêu đề bài hát
      subtitle: Text(song.artist), // Hiển thị nghệ sĩ bài hát

      trailing: IconButton(
        icon: const Icon(Icons.more_horiz), // Icon nút menu
        onPressed: () {
          parent.showBottomSheet(); // Hiển thị Bottom Sheet khi nhấn nút
        },
      ),
      onTap: () {
        parent.navigate(song); // Điều hướng đến màn hình phát nhạc khi nhấn vào item
      },
    );
  }
}
