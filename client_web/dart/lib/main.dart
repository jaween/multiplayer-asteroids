import 'package:multiplayer_asteroids_client_core/client_core.dart';
import 'package:multiplayer_asteroids_client_web/comms/comms_client_js.dart';

void main() {
  final host = "ws://localhost";
  final port = 8081;
  final comms = CommsClientJs();
  final _gameClient = GameClient(host, port, comms);
  _gameClient.start(onConnectionStateChanged: (connected) {
    print("Connected");
  }, onWorldStateUpdated: (worldState) {
    print("World state updated");
  }, onDebugInfoUpdated: (debugInfo) {
    print("Debug info");
  });
}
