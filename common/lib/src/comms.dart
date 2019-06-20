abstract class CommsServer {
  void start(int port, void onConnection(Socket socket, ClientInfo client));
  void close();
}

abstract class CommsClient {
  void start(String host, int port, void onConnected(Socket socket));
  void close();
}

abstract class Socket {
  void send(data);
  void listen(void onMessage(data));
  void close();
}

abstract class ClientInfo {
  String get address;
  int get port;
}
