import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class TrpcClient {
  final String url;
  late final WebSocketChannel _channel;
  bool _connected = false;
  int _idCounter = 0;

  final Map<int, void Function(dynamic)> _listeners = {};

  TrpcClient(this.url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    // 监听服务端消息
    _channel.stream.listen(
      (event) {
        _connected = true;
        print('收到服务器消息: $event');
        final data = jsonDecode(event);
        final id = data['id'];
        if (id != null && _listeners.containsKey(id)) {
          _listeners[id]!(data['result']);
        }
      },
      onDone: () {
        _connected = false;
        print('WebSocket 连接已关闭');
      },
    );
  }

  int _nextId() => ++_idCounter;

  /// query / mutation
  Future<dynamic> request(String method, String path, {dynamic input}) {
    final id = _nextId();
    final completer = Completer<dynamic>();

    _listeners[id] = (result) {
      completer.complete(result);
      _listeners.remove(id);
    };

    final payload = {
      'id': id,
      'method': method,
      'params': {'path': path, 'input': input},
    };

    _channel.sink.add(jsonEncode(payload));

    return completer.future;
  }

  /// subscription
  Stream<dynamic> subscribe(String path, {dynamic input}) {
    final controller = StreamController<dynamic>();
    final id = _nextId();
    _listeners[id] = (result) {
      // 添加这行日志来调试

      if (result != null && result['type'] == 'data') {
        controller.add(result['data']);
      } else if (result != null && result['type'] == 'stopped') {
        controller.close();
      }
    };

    final payload = jsonEncode({
      'id': id,
      'method': 'subscription',
      'params': {
        'path': path,
        'input': {'json': input ?? {}},
      },
    });

    _channel.sink.add(payload);

    controller.onCancel = () {
      _channel.sink.add(jsonEncode({'id': id, 'method': 'subscription.stop'}));
      _listeners.remove(id);
    };

    return controller.stream;
  }

  /// 关闭连接
  void dispose() {
    _channel.sink.close();
  }
}
