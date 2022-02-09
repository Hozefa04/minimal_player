import 'dart:async';
import 'dart:developer';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'song_state.dart';

class SongCubit extends Cubit<SongState> {
  SongCubit() : super(const SongLoading());

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();

  late List<SongModel> allSongs;

  Future<void> getSongs() async {
    List<SongModel> songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    allSongs = songs;
    emit(SongLoaded(songs));
  }

  bool songState = false;
  bool get isPlaying => songState;

  bool repeating = false;
  bool get isRepeating => repeating;

  int currentIndex = 0;

  AssetsAudioPlayer get audioInstance => _audioPlayer;

  late Audio _audio;

  Future<void> setSong(SongModel song) async {
    _audio = Audio.file(
      song.uri!,
      metas: Metas(
        title: song.title,
        artist: song.artist,
        album: song.album,
      ),
    );
    emit(SongChanged(song));
    _audioPlayer.open(
      _audio,
      showNotification: true,
      notificationSettings: NotificationSettings(
        customNextAction: (player) {
          if (currentIndex + 1 != allSongs.length) {
            currentIndex++;
            setSong(allSongs[currentIndex]);
          } else {
            setSong(allSongs[0]);
            currentIndex = 0;
          }
        },
        customPrevAction: (player) {
          if (currentIndex - 1 > 0) {
            currentIndex--;
            setSong(allSongs[currentIndex]);
          } else {
            setSong(allSongs[0]);
            currentIndex = 0;
          }
        },
        seekBarEnabled: true,
        stopEnabled: false,
      ),
    );
    _audioPlayer.play();
    songState = true;
    emit(SongResumed(song));
    emit(CurrentSong(currentIndex));
  }

  void pauseSong() async {
    await _audioPlayer.pause().then((value) {
      songState = false;
      emit(const SongPaused());
      emit(CurrentSong(currentIndex));
      log("Pause " + state.toString());
    });
  }

  void resumeSong(SongModel song) async {
    await _audioPlayer.play().then((value) {
      songState = true;
      emit(SongResumed(song));
      emit(CurrentSong(currentIndex));
      log("Resume " + state.toString());
    });
  }

  void toggleRepeat() {
    if (repeating) {
      _audioPlayer.setLoopMode(LoopMode.none);
    } else {
      _audioPlayer.setLoopMode(LoopMode.single);
    }
    repeating = !repeating;
    log(_audioPlayer.currentLoopMode.toString());
  }

  void autoNextSong() {}

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
