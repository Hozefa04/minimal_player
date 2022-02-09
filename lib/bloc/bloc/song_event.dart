part of 'song_bloc.dart';

abstract class SongEvent extends Equatable {
  const SongEvent();
}

class GetSongs extends SongEvent {
  const GetSongs();

  @override
  List<Object> get props => [];
}

class SetSong extends SongEvent {
  final SongModel song;

  const SetSong(this.song);

  @override
  List<Object> get props => [song];
}

class PauseSong extends SongEvent {
  const PauseSong();

  @override
  List<Object> get props => [];
}

class ResumeSong extends SongEvent {
  const ResumeSong();

  @override
  List<Object> get props => [];
}