import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:languages_dart/languages_dart.dart';
import 'package:nanana_app/src/models/lyrics.dart';

class DatesNanana {
  static final dateDefault = DateTime(2024, 04, 04);
}

class CaptureDummy {
  static final captures = <Capture>[
    Capture(
      id: 1,
      artist: 'Salif Keita',
      song: 'Mandjou',
      youtubeUrl: '',
      // TODO: upload package language as a standalone and inherit in native
      language: Languages.bambara,
      userId: 'dummyUser',
      lyrics: LyricsDummy.mandjou,
      isPublished: true,
    ),
    Capture(
      id: 2,
      userId: 'dummyUser',
      artist: 'El Fudge',
      song: "Rockin'it",
      youtubeUrl: '',
      language: Languages.english,
      lyrics: LyricsDummy.rockinIt,
      isPublished: true,
    ),
    Capture(
      id: 3,
      userId: 'dummyUser',
      artist: 'Nougaro',
      song: 'Tu verras',
      youtubeUrl: '',
      language: Languages.french,
      lyrics: LyricsDummy.tuVerras,
      isPublished: true,
    ),
    Capture(
      id: 4,
      userId: 'dummyUser',
      artist: 'Sting',
      song: "It's probably me",
      youtubeUrl: '',
      language: Languages.english,
      lyrics: LyricsDummy.itsProbablyMe,
      isPublished: true,
    ),
    Capture(
      id: 5,
      userId: 'dummyUser',
      artist: 'Sekouba Bambino',
      song: "Famou",
      youtubeUrl: 'https://youtu.be/ZNT9fmH8-Tk?si=h8borKfankfJcFnE',
      language: Languages.bambara,
      lyrics: LyricsDummy.famou,
      isPublished: true,
      videoPath:
          "C:/Users/PierreGancel/Documents/nanana_songs/Sekouba Bambino - Famou (Clip Officiel)_ZNT9fmH8-Tk.mp4",
    )
  ];
}

enum LyricsOrigin {
  transcribedByMyself,
  officialLyricVideo,
  anotherWebsite,
  albumBooklet,
  other,
  unknown
}

class Capture {
  final int id;
  final String artist, album, song, youtubeUrl, userId, lyrics;
  final Language language;
  final DateTime? dateCreate, dateUpdate;
  final LyricsOrigin lyricsOrigin;
  final bool isPublished;
  final String videoPath; // localOnly not needed in backend

  const Capture({
    required this.id,
    required this.artist,
    this.album = '',
    required this.song,
    required this.youtubeUrl,
    required this.language,
    required this.userId,
    this.dateCreate,
    this.dateUpdate,
    this.lyrics = '',
    this.lyricsOrigin = LyricsOrigin.unknown,
    this.isPublished = false,
    this.videoPath = '',
  });

  Capture copyWith({
    int? id,
    String? artist,
    String? album,
    String? song,
    String? youtubeUrl,
    Language? language,
    String? userId,
    DateTime? dateCreate,
    DateTime? dateUpdate,
    String? lyrics,
    LyricsOrigin? lyricsOrigin,
    bool? isPublished,
    String? videoPath,
  }) {
    return Capture(
      id: id ?? this.id,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      song: song ?? this.song,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      language: language ?? this.language,
      userId: userId ?? this.userId,
      dateCreate: dateCreate ?? this.dateCreate,
      dateUpdate: dateUpdate ?? this.dateUpdate,
      lyrics: lyrics ?? this.lyrics,
      lyricsOrigin: lyricsOrigin ?? this.lyricsOrigin,
      isPublished: isPublished ?? this.isPublished,
      videoPath: videoPath ?? this.videoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artist': artist,
      'album': album,
      'song': song,
      'youtubeUrl': youtubeUrl,
      'language': language.toMap(),
      'userId': userId,
      'dateCreate': dateCreate?.toIso8601String(),
      'dateUpdate': dateUpdate?.toIso8601String(),
      'lyrics': lyrics,
      'lyricsOrigin': lyricsOrigin.toString(),
      'isPublished': isPublished,
      'videoPath': videoPath,
    };
  }

  factory Capture.fromMap(Map<String, dynamic> map) {
    return Capture(
      id: map['id']?.toInt() ?? 0,
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      song: map['song'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      language: Language.fromMap(map['language']),
      userId: map['userId'] ?? '',
      dateCreate: DateTime.tryParse(map['dateCreate'] ?? ''),
      dateUpdate: DateTime.tryParse(map['dateUpdate'] ?? ''),
      lyrics: map['lyrics'] ?? '',
      lyricsOrigin: LyricsOrigin.values
              .firstWhereOrNull((e) => e == (map['lyrics'] ?? '')) ??
          LyricsOrigin.unknown,
      isPublished: map['isPublished'] ?? false,
      videoPath: map['videoPath'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Capture.fromJson(String source) =>
      Capture.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Notation(id: $id, artist: $artist, album: $album, song: $song, youtubeUrl: $youtubeUrl, language: $language, userId: $userId, dateCreate: $dateCreate, dateUpdate: $dateUpdate, lyrics: $lyrics, isPublished: $isPublished, videoPath: $videoPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Capture &&
        other.id == id &&
        other.artist == artist &&
        other.album == album &&
        other.song == song &&
        other.youtubeUrl == youtubeUrl &&
        other.language == language &&
        other.userId == userId &&
        other.dateCreate == dateCreate &&
        other.dateUpdate == dateUpdate &&
        other.lyrics == lyrics &&
        isPublished == isPublished &&
        videoPath == videoPath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        artist.hashCode ^
        album.hashCode ^
        song.hashCode ^
        youtubeUrl.hashCode ^
        language.hashCode ^
        userId.hashCode ^
        dateCreate.hashCode ^
        dateUpdate.hashCode ^
        lyrics.hashCode ^
        isPublished.hashCode ^
        videoPath.hashCode;
  }
}
