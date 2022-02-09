import 'dart:developer';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimal_player/cubit/song_cubit.dart';
import 'package:minimal_player/utils/app_colors.dart';
import 'package:minimal_player/utils/text_styles.dart';
import 'package:minimal_player/widgets/custom_slider.dart';
import 'package:on_audio_query/on_audio_query.dart';

double minValue = 0.0;
double maxValue = 0.0;
double currentValue = 0.0;

String currentTime = "00:00";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<SongCubit>().getSongs();
    log("rebuild");

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: const CustomAppBar(),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5),
        child: Row(
          children: const [
            BlocSongBuilder(),
            SideBar(),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "Minimal Player",
        style: TextStyles.primaryBold,
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BlocSongBuilder extends StatelessWidget {
  const BlocSongBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _songCubit = BlocProvider.of<SongCubit>(context);
    return Expanded(
      flex: 4,
      child: BlocBuilder<SongCubit, SongState>(
        buildWhen: (previous, current) => current is SongLoaded,
        builder: (context, state) {
          if (state is SongLoaded) {
            return ListView.builder(
              itemCount: state.songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    _songCubit.currentIndex = index;
                    _songCubit.setSong(state.songs[index]);
                  },
                  title: SongTitleText(
                    title: state.songs[index].title,
                    index: index,
                  ),
                  subtitle: Text(
                    state.songs[index].artist ?? "No Artist",
                    style: TextStyles.artistText,
                  ),
                  leading: QueryArtworkWidget(
                    id: state.songs[index].id,
                    type: ArtworkType.AUDIO,
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class SongTitleText extends StatelessWidget {
  final String title;
  final int index;
  const SongTitleText({
    Key? key,
    required this.title,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _songCubit = BlocProvider.of<SongCubit>(context);
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        if (state is CurrentSong) {
          return Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: _songCubit.currentIndex == index
                ? TextStyles.primaryRegular.copyWith(color: Colors.red)
                : TextStyles.primaryRegular,
          );
        }
        return Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.primaryRegular,
        );
      },
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SongProgress(),
          Spacer(),
          RepeatButton(),
          PreviousButton(),
          NextButton(),
          SizedBox(height: 20.0),
          PlayPauseButton(),
        ],
      ),
    );
  }
}

class SongProgress extends StatelessWidget {
  const SongProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _songCubit = BlocProvider.of<SongCubit>(context);

    return RotatedBox(
      quarterTurns: 3,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SliderTheme(
          data: const SliderThemeData(
            thumbColor: Colors.white,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            trackHeight: 1.0,
          ),
          child: PlayerBuilder.realtimePlayingInfos(
            player: _songCubit.audioInstance,
            builder: (context, infos) {
              if (infos.currentPosition < infos.duration) {
                return CustomSlider(
                  currentPosition: infos.currentPosition,
                  duration: infos.duration,
                  index: _songCubit.currentIndex,
                  seekTo: (duration) {
                    _songCubit.audioInstance.seek(duration);
                  },
                );
              } else {
                if (_songCubit.currentIndex >= _songCubit.allSongs.length - 1) {
                  _songCubit.currentIndex = 0;
                  _songCubit
                      .setSong(_songCubit.allSongs[_songCubit.currentIndex]);
                } else {
                  _songCubit.currentIndex++;
                  _songCubit
                      .setSong(_songCubit.allSongs[_songCubit.currentIndex]);
                }
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
      ),
      child: BlocBuilder<SongCubit, SongState>(
        buildWhen: (previousState, currentState) {
          if (currentState is SongPaused || currentState is SongResumed) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          var _songCubit = BlocProvider.of<SongCubit>(context);
          bool isPlaying = _songCubit.isPlaying;
          log(isPlaying.toString());

          return IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            iconSize: 38.0,
            color: AppColors.primaryColor,
            onPressed: () {
              isPlaying
                  ? _songCubit.pauseSong()
                  : _songCubit
                      .resumeSong(_songCubit.allSongs[_songCubit.currentIndex]);
            },
          );
        },
      ),
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shuffle_rounded),
      iconSize: 24.0,
      color: Colors.grey,
      onPressed: () {},
    );
  }
}

class RepeatButton extends StatefulWidget {
  const RepeatButton({
    Key? key,
  }) : super(key: key);

  @override
  State<RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<RepeatButton> {
  @override
  Widget build(BuildContext context) {
    var _songCubit = BlocProvider.of<SongCubit>(context);
    return IconButton(
      icon: const Icon(Icons.repeat_rounded),
      iconSize: 24.0,
      color: _songCubit.isRepeating ? Colors.white : Colors.grey,
      onPressed: () {
        _songCubit.toggleRepeat();
        setState(() {});
      },
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _songCubit = BlocProvider.of<SongCubit>(context);
    return IconButton(
      icon: const Icon(Icons.skip_next_rounded),
      iconSize: 32.0,
      color: const Color.fromRGBO(255, 255, 255, 1),
      onPressed: () {
        if (_songCubit.currentIndex >= _songCubit.allSongs.length - 1) {
          _songCubit.currentIndex = 0;
          _songCubit.setSong(_songCubit.allSongs[_songCubit.currentIndex]);
        } else {
          _songCubit.currentIndex++;
          _songCubit.setSong(_songCubit.allSongs[_songCubit.currentIndex]);
        }
      },
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _songCubit = BlocProvider.of<SongCubit>(context);
    return IconButton(
      icon: const Icon(Icons.skip_previous_rounded),
      iconSize: 32.0,
      color: Colors.white,
      onPressed: () {
        if (_songCubit.currentIndex <= 0) {
          _songCubit.currentIndex = 0;
          _songCubit.setSong(_songCubit.allSongs[_songCubit.currentIndex]);
        } else {
          _songCubit.currentIndex--;
          _songCubit.setSong(_songCubit.allSongs[_songCubit.currentIndex]);
        }
      },
    );
  }
}
