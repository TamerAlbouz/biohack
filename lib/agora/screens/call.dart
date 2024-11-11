import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medtalk/agora/bloc/agora_bloc.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const VideoCallScreen());
  }

  // int? _remoteUid; // The UID of the remote user
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => AgoraBloc()
        ..add(AgoraRequestPermissions())
        ..add(AgoraInitializeEngine())
        ..add(const AgoraJoinChannel(
          "tamer",
        )),
      child: BlocBuilder<AgoraBloc, AgoraState>(
        builder: (context, state) {
          switch (state) {
            case AgoraInitial():
            case AgoraLoading():
              return const Center(child: CircularProgressIndicator());
            case AgoraError():
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'An error occurred while loading the application',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AgoraBloc>().add(AgoraInitializeEngine());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case AgoraLoaded():
              return Scaffold(
                // navigate to previous screen
                appBar: AppBar(
                  automaticallyImplyLeading: true,
                ),
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(child: _remoteVideo(state.engine, state.remoteUid)),
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Center(
                          child: state.localUserJoined
                              ? AgoraVideoView(
                                  controller: VideoViewController(
                                    rtcEngine: state.engine,
                                    canvas: const VideoCanvas(uid: 0),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SvgPicture.asset(
                        'assets/svgs/BottomBarCalls.svg',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        width: double.infinity,
                        placeholderBuilder: (context) =>
                            const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  // Widget to display remote video
  Widget _remoteVideo(RtcEngine engine, int? remoteUid) {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: const RtcConnection(channelId: "tamer"),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
