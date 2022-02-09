part of 'song_bloc.dart';

abstract class SongState extends Equatable {
  const SongState();
}

List<SongModel> songsList = [];
List<SongModel> get getSongs => songsList;

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
  const SongResumed();

  @override
  List<Object> get props => [];
}

