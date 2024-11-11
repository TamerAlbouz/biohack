part of 'agora_bloc.dart';

sealed class AgoraState extends Equatable {
  const AgoraState();
}

final class AgoraInitial extends AgoraState {
  @override
  List<Object> get props => [];
}

final class AgoraLoading extends AgoraState {
  @override
  List<Object> get props => [];
}

final class AgoraLoaded extends AgoraState {
  final RtcEngine engine;
  final bool localUserJoined;
  final int? remoteUid;

  const AgoraLoaded(
      {required this.engine, this.remoteUid, this.localUserJoined = false});

  @override
  List<Object> get props => [engine, localUserJoined];
}

final class AgoraError extends AgoraState {
  final String message;

  const AgoraError(this.message);

  @override
  List<Object> get props => [message];
}
