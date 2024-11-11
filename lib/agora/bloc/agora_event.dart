part of 'agora_bloc.dart';

sealed class AgoraEvent extends Equatable {
  const AgoraEvent();
}

final class AgoraRequestPermissions extends AgoraEvent {
  @override
  List<Object> get props => [];
}

final class AgoraInitializeEngine extends AgoraEvent {
  @override
  List<Object> get props => [];
}

final class AgoraJoinChannel extends AgoraEvent {
  final String channelName;

  const AgoraJoinChannel(this.channelName);

  @override
  List<Object> get props => [channelName];
}

final class AgoraLeaveChannel extends AgoraEvent {
  @override
  List<Object> get props => [];
}
