import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/data/repository/repository.dart';
import 'package:music_app/ui/home/home.dart';

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   var repository = DefaultRepository();
//   var songs = await repository.loadData();
//   if(songs !=null){
//     for(var song in songs){
//       debugPrint(song.toString());
//     }
//   }
// }
//
// class MusicApp extends StatelessWidget {
//   const MusicApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Làm trong suốt
      statusBarIconBrightness: Brightness.light, // Icon màu trắng
    ),
  );
  runApp(const MusicApp());
}
