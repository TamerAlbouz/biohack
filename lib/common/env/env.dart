import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
final class Env {
  @EnviedField(varName: 'AGORA_APP_ID')
  static final String agoraAppId = _Env.agoraAppId;
}
