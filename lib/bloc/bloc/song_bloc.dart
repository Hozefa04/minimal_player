import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'song_event.dart';
part 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer audioPlayer = AudioPlayer();

  SongBloc() : super(const SongLoading()) {
    on<GetSongs>(_onGetSongs);
    on<SetSong>(_onSetSong);
    on<PauseSong>(_onPauseSong);
    on<ResumeSong>(_onResumeSongs);
  }

  late List<SongModel> songs;

  Future<void> _onGetSongs(event, Emitter<SongState> emit) async {
      songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    emit(SongLoaded(songs));
  }

  Future<void> _onSetSong(event, Emitter<SongState> emit) async {
    emit(SongChanged(event.song));
    await audioPlayer.setUrl(event.song.uri!);
    audioPlayer.play();
    emit(const SongResumed());
  }

  Future<void> _onPauseSong(event, Emitter<SongState> emit) async {
    await audioPlayer.pause();
    emit(const SongPaused());
  }

  Future<void> _onResumeSongs(event, Emitter<SongState> emit) async {
    await audioPlayer.play();
    emit(const SongResumed());
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }

}
