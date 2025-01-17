class Song {
  //khai báo thuộc tính
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  String favorite;
  int counter;
  int replay;

  //constructor
  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    required this.favorite,
    required this.counter,
    required this.replay,
  });

  //phương thức chuyển đổi từ Json thành đối tượng
  factory Song.fromJson(Map<String, dynamic> map) {
    //dynamic là kiểu dữ liệu cho phép biến chứa bất kỳ kiểu dữ liệu nào. Không cố định kiểu dữ liệu và có thể thay đổi tại runtime
    return Song(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      source: map['source'],
      image: map['image'],
      duration: map['duration'],
      favorite: map['favorite'],
      counter: map['counter'],
      replay: map['replay'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration, favorite: $favorite, counter: $counter, replay: $replay}';
  }
}
