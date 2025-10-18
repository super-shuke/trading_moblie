import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

enum TrpcConnectionState { connecting, connected, disconnected, error }

class TrpcClient {
  final String url;
  late final WebSocketChannel _channel;
  bool _connected = false;
  int _idCounter = 0;

  /// 监听器
  final Map<int, void Function(dynamic)> _listeners = {};

  // 连接状态流
  final _stateController = StreamController<TrpcConnectionState>.broadcast();

  // 外部可监听连接状态变化
  Stream<TrpcConnectionState> get connectionStateStream =>
      _stateController.stream;

  Timer? _heartbeatTimer;
  DateTime _lastPing = DateTime.now();

  TrpcClient(this.url) {
    _connect();
  }
  void _connect() {
    _stateController.add(TrpcConnectionState.connecting);
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen(
      (event) {
        final data = jsonDecode(event);
        print('📩 收到 tRPC 消息: $data');

        // === 首次收到消息就标记连接成功 ===
        if (!_connected) {
          _connected = true;
          _stateController.add(TrpcConnectionState.connected);
          print('✅ tRPC 连接成功');
        }

        // === 调度 listener ===
        final id = data['id'];
        if (id != null && _listeners.containsKey(id)) {
          _listeners[id]!(data['result']);
        }
      },
      onDone: () {
        _connected = false;
        _stateController.add(TrpcConnectionState.disconnected);
        print('❌ tRPC 已关闭');
        _reconnect();
      },
      onError: (error) {
        _connected = false;
        _stateController.add(TrpcConnectionState.error);
        print('⚠️ tRPC 错误: $error');
        _reconnect();
      },
    );
  }

  Timer startHeartbeat({Duration interval = const Duration(seconds: 20)}) {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(interval, (timer) {
      if (_connected) {
        try {
          final pingMsg = jsonEncode({
            'id': 9999,
            'method': 'ping',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          _channel.sink.add(pingMsg);
          print('💓 已发送 ping');
        } catch (e) {
          print('发送心跳失败: $e');
          _reconnect();
        }
      }
    });

    return _heartbeatTimer!;
  }

  void _reconnect() async {
    if (_connected) return;
    _heartbeatTimer?.cancel();
    print("🔁 5秒后尝试重连...");
    await Future.delayed(const Duration(seconds: 5));
    _connect();
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
