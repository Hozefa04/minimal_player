part of 'song_cubit.dart';

abstract class SongState extends Equatable {
  const SongState();
}

class SongLoading extends SongState {
  const SongLoading();

  @override
  List<Object> get props => [];
}

class SongLoaded extends SongState {
  final List<SongModel> songs;
  const SongLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class SongChanged extends SongState {
  final SongModel song;
  const SongChanged(this.song);

  @override
  List<Object> get props => [song];
}

class SongPaused extends SongState {
  const SongPaused();

  @override
  List<Object> get props => [];
}

class SongResumed extends SongState {
  final SongModel song;
  const SongResumed(this.song);

  @override
  List<Object> get props => [song];
}

class CurrentSong extends SongState {
  final int index;
  const CurrentSong(this.index);

  @override
  List<Object> get props => [index];
}
