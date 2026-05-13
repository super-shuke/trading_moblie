// ============================================================================
// realtime.dart —— 全局唯一的 WebSocket 实时通信层
//
// 与 GeoTravel NestJS 后端（@nestjs/platform-socket.io）配套。
// 协议：Socket.IO 4.x，路径 /ws，仅 websocket 传输。
//
// ─── 对外 API ─────────────────────────────────────────────────────────────
//
// ① 初始化（启动时调一次，必须在 Api.main.init() 之后）
//      await Realtime.I.init(url: 'http://localhost:3000');
//
// ② 连接 / 断开
//      await Realtime.I.connect();   // 登录后调
//      Realtime.I.disconnect();      // 登出时调
//      Realtime.I.isConnected;       // bool
//
// ③ 订阅业务频道（连接成功后会自动订阅 user:<me>，无需手动加）
//      Realtime.I.subscribe('city:$cityId');
//      Realtime.I.subscribe('poi:$poiId');
//      Realtime.I.subscribe('itinerary:$itineraryId');
//      Realtime.I.unsubscribe('city:$cityId');
//
// ④ 消费事件 —— 三种风格任选其一
//
//      ▸ Stream（推荐，多页面 / 多 Bloc 同时订阅互不干扰）：
//          Realtime.I.tipCreated.listen((data) => ...);
//          StreamBuilder(stream: Realtime.I.itineraryReordered, ...);
//
//      ▸ Callback（最简单，但每个事件只能有一个监听者）：
//          Realtime.I.onTipCreated = (data) => setState(...);
//
//      ▸ 通用流（一处接管所有事件，适合 Bloc/Redux）：
//          Realtime.I.events.listen((e) {
//            bloc.add(RealtimeRawEvent(e.name, e.data));
//          });
//
// ⑤ 主动发命令
//      Realtime.I.startNavigation(poiId: 'xxx');
//      Realtime.I.updateNavigation(sessionId: 's1', lat: ..., lng: ...);
//      Realtime.I.unityFocusCity(sessionId: 's1', cityId: 'xxx');
//
// ⑥ 连接状态（用于在 UI 显示"实时已连"角标）
//      Realtime.I.onConnectionStateChanged = (state) { ... };
//      Realtime.I.connectionState.listen((state) { ... });
//
// ─── 自动处理 ─────────────────────────────────────────────────────────────
//   - 握手时从 Api.main 拿 accessToken
//   - 断网自动重连（指数退避 1 → 2 → 4 ... 30 秒）
//   - 重连后自动恢复之前订阅的所有频道
//   - 服务端 connection.error 时尝试通过 Api 续期再重连
//   - 心跳由 socket.io 自动处理
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:traveling_app/service/network/dio_quest.dart';


// ─── 公开类型 ───────────────────────────────────────────────────────────────

enum RealtimeConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
}

class RealtimeEvent {
  RealtimeEvent(this.name, this.data);
  final String name;
  final dynamic data;
  @override
  String toString() => 'RealtimeEvent($name, $data)';
}

typedef RealtimeListener<T> = void Function(T data);
typedef ConnectionStateListener =
    void Function(RealtimeConnectionState state);

// ─── 事件名常量（与后端 src/realtime/events.ts 对齐） ───────────────────────

abstract class _Ev {
  // server → client
  static const connectionReady = 'connection.ready';
  static const connectionError = 'connection.error';
  static const userProfileUpdated = 'user.profile.updated';
  static const poiSaved = 'poi.saved';
  static const poiUnsaved = 'poi.unsaved';
  static const tipCreated = 'tip.created';
  static const tipUpdated = 'tip.updated';
  static const tipDeleted = 'tip.deleted';
  static const itineraryUpdated = 'itinerary.updated';
  static const itineraryReordered = 'itinerary.reordered';
  static const navigationUpdated = 'navigation.updated';
  static const unitySceneReady = 'unity.scene.ready';
  static const unityCitySelected = 'unity.city.selected';
  static const unityPoiSelected = 'unity.poi.selected';
  static const unityCameraChanged = 'unity.camera.changed';

  // client → server
  static const cmdSubscribe = 'subscribe';
  static const cmdUnsubscribe = 'unsubscribe';
  static const cmdNavigationStart = 'navigation.start';
  static const cmdNavigationUpdate = 'navigation.update';
  static const cmdNavigationStop = 'navigation.stop';
  static const cmdUnityFocusCity = 'unity.focus_city';
  static const cmdUnityFocusPoi = 'unity.focus_poi';
  static const cmdUnitySetMode = 'unity.set_mode';
  static const cmdUnityCamera = 'unity.camera.changed';
  static const cmdItineraryReorder = 'itinerary.reorder';
}

// ============================================================================
//                                 Realtime
// ============================================================================

class SocketApi {
  // ─── 单例 ──────────────────────────────────────────────────────────────
  SocketApi._();
  static final SocketApi _instance = SocketApi._();
  static SocketApi get main => _instance;

  // ─── 配置 ──────────────────────────────────────────────────────────────
  late String _url;
  String _path = '/ws';
  Duration _reconnectInitial = const Duration(seconds: 1);
  Duration _reconnectMax = const Duration(seconds: 30);
  bool _initialized = false;

  // ─── 状态 ──────────────────────────────────────────────────────────────
  IO.Socket? _socket;
  RealtimeConnectionState _state = RealtimeConnectionState.idle;

  /// 当前订阅的频道（重连时恢复）
  final Set<String> _subscribedChannels = {};

  /// 用户是否希望保持连接（disconnect 后不要自动重连）
  bool _userWantsConnected = false;

  /// 重连次数（指数退避）
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  // ─── Stream 风格 API（broadcast，多订阅者） ───────────────────────────
  final _eventsCtl = StreamController<RealtimeEvent>.broadcast();
  final _connectionStateCtl =
      StreamController<RealtimeConnectionState>.broadcast();

  final _userProfileUpdatedCtl = StreamController<dynamic>.broadcast();
  final _poiSavedCtl = StreamController<dynamic>.broadcast();
  final _poiUnsavedCtl = StreamController<dynamic>.broadcast();
  final _tipCreatedCtl = StreamController<dynamic>.broadcast();
  final _tipUpdatedCtl = StreamController<dynamic>.broadcast();
  final _tipDeletedCtl = StreamController<dynamic>.broadcast();
  final _itineraryUpdatedCtl = StreamController<dynamic>.broadcast();
  final _itineraryReorderedCtl = StreamController<dynamic>.broadcast();
  final _navigationUpdatedCtl = StreamController<dynamic>.broadcast();
  final _unitySceneReadyCtl = StreamController<dynamic>.broadcast();
  final _unityCitySelectedCtl = StreamController<dynamic>.broadcast();
  final _unityPoiSelectedCtl = StreamController<dynamic>.broadcast();
  final _unityCameraChangedCtl = StreamController<dynamic>.broadcast();

  /// 所有服务端事件的统一流（Redux/Bloc 用这个最方便）
  Stream<RealtimeEvent> get events => _eventsCtl.stream;
  Stream<RealtimeConnectionState> get connectionState =>
      _connectionStateCtl.stream;

  Stream<dynamic> get userProfileUpdated => _userProfileUpdatedCtl.stream;
  Stream<dynamic> get poiSaved => _poiSavedCtl.stream;
  Stream<dynamic> get poiUnsaved => _poiUnsavedCtl.stream;
  Stream<dynamic> get tipCreated => _tipCreatedCtl.stream;
  Stream<dynamic> get tipUpdated => _tipUpdatedCtl.stream;
  Stream<dynamic> get tipDeleted => _tipDeletedCtl.stream;
  Stream<dynamic> get itineraryUpdated => _itineraryUpdatedCtl.stream;
  Stream<dynamic> get itineraryReordered => _itineraryReorderedCtl.stream;
  Stream<dynamic> get navigationUpdated => _navigationUpdatedCtl.stream;
  Stream<dynamic> get unitySceneReady => _unitySceneReadyCtl.stream;
  Stream<dynamic> get unityCitySelected => _unityCitySelectedCtl.stream;
  Stream<dynamic> get unityPoiSelected => _unityPoiSelectedCtl.stream;
  Stream<dynamic> get unityCameraChanged => _unityCameraChangedCtl.stream;

  // ─── Callback 风格 API（单监听者） ───────────────────────────────────
  ConnectionStateListener? onConnectionStateChanged;
  RealtimeListener<dynamic>? onUserProfileUpdated;
  RealtimeListener<dynamic>? onPoiSaved;
  RealtimeListener<dynamic>? onPoiUnsaved;
  RealtimeListener<dynamic>? onTipCreated;
  RealtimeListener<dynamic>? onTipUpdated;
  RealtimeListener<dynamic>? onTipDeleted;
  RealtimeListener<dynamic>? onItineraryUpdated;
  RealtimeListener<dynamic>? onItineraryReordered;
  RealtimeListener<dynamic>? onNavigationUpdated;
  RealtimeListener<dynamic>? onUnitySceneReady;
  RealtimeListener<dynamic>? onUnityCitySelected;
  RealtimeListener<dynamic>? onUnityPoiSelected;
  RealtimeListener<dynamic>? onUnityCameraChanged;
  RealtimeListener<dynamic>? onError;

  // ─── 公开只读 ──────────────────────────────────────────────────────────
  bool get isConnected => _state == RealtimeConnectionState.connected;
  RealtimeConnectionState get state => _state;
  Set<String> get subscribedChannels => Set.unmodifiable(_subscribedChannels);

  // ─── 初始化 ────────────────────────────────────────────────────────────

  /// 启动时调一次。
  ///
  /// - [url]  socket.io 服务器地址，**不含路径**，例如 `http://localhost:3000`
  /// - [path] socket.io 挂载路径，默认 `/ws`（与后端一致）
  Future<void> init({
    required String url,
    String path = '/ws',
    Duration reconnectInitial = const Duration(seconds: 1),
    Duration reconnectMax = const Duration(seconds: 30),
  }) async {
    assert(!_initialized, 'Realtime.init() 只能调用一次');
    _url = url;
    _path = path;
    _reconnectInitial = reconnectInitial;
    _reconnectMax = reconnectMax;
    _initialized = true;
  }

  // ─── 连接管理 ──────────────────────────────────────────────────────────

  /// 建立连接。登录成功后调用。幂等。
  Future<void> connect() async {
    _assertInit();

    if (!Api.main.isAuthenticated) {
      debugPrint('[Realtime] 未登录，跳过 connect()');
      return;
    }
    _userWantsConnected = true;
    _cancelReconnect();

    if (_socket != null) {
      if (!_socket!.connected) _socket!.connect();
      return;
    }

    _setState(RealtimeConnectionState.connecting);
    _socket = _buildSocket();
    _bindHandlers(_socket!);
    _socket!.connect();
  }

  /// 主动断开。退出登录时调用。
  void disconnect() {
    _userWantsConnected = false;
    _cancelReconnect();
    _socket?.dispose();
    _socket = null;
    _subscribedChannels.clear();
    _setState(RealtimeConnectionState.disconnected);
  }

  // ─── 订阅管理 ──────────────────────────────────────────────────────────

  /// 订阅频道。
  /// 格式：`user:<id>` / `city:<id>` / `poi:<id>` / `itinerary:<id>` /
  ///       `navigation:<sessionId>` / `unity:<sessionId>`
  ///
  /// 连接断开后会被记住，重连后自动恢复订阅。
  void subscribe(String channel) {
    _subscribedChannels.add(channel);
    _socket?.emit(_Ev.cmdSubscribe, {'channel': channel});
  }

  void unsubscribe(String channel) {
    _subscribedChannels.remove(channel);
    _socket?.emit(_Ev.cmdUnsubscribe, {'channel': channel});
  }

  // ─── 业务命令 ──────────────────────────────────────────────────────────

  void startNavigation({
    required String poiId,
    double? lat,
    double? lng,
    String? sessionId,
  }) {
    _socket?.emit(_Ev.cmdNavigationStart, {
      'poiId': poiId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (sessionId != null) 'sessionId': sessionId,
    });
  }

  void updateNavigation({
    required String sessionId,
    required double lat,
    required double lng,
    double? bearing,
    double? speedMps,
  }) {
    _socket?.emit(_Ev.cmdNavigationUpdate, {
      'sessionId': sessionId,
      'lat': lat,
      'lng': lng,
      if (bearing != null) 'bearing': bearing,
      if (speedMps != null) 'speedMps': speedMps,
    });
  }

  void stopNavigation({required String sessionId}) {
    _socket?.emit(_Ev.cmdNavigationStop, {'sessionId': sessionId});
  }

  void unityFocusCity({required String sessionId, required String cityId}) {
    _socket?.emit(_Ev.cmdUnityFocusCity, {
      'sessionId': sessionId,
      'entityId': cityId,
    });
  }

  void unityFocusPoi({required String sessionId, required String poiId}) {
    _socket?.emit(_Ev.cmdUnityFocusPoi, {
      'sessionId': sessionId,
      'entityId': poiId,
    });
  }

  void unitySetMode({required String sessionId, required String mode}) {
    _socket?.emit(_Ev.cmdUnitySetMode, {'sessionId': sessionId, 'mode': mode});
  }

  void sendUnityCamera({
    required String sessionId,
    required double lat,
    required double lng,
    double? alt,
    double? pitch,
    double? yaw,
  }) {
    _socket?.emit(_Ev.cmdUnityCamera, {
      'sessionId': sessionId,
      'lat': lat,
      'lng': lng,
      if (alt != null) 'alt': alt,
      if (pitch != null) 'pitch': pitch,
      if (yaw != null) 'yaw': yaw,
    });
  }

  /// 行程站点重排"预览"（多端实时同步，不落库；持久化走 REST）
  void itineraryReorderPreview({
    required String itineraryId,
    required List<String> stopIds,
  }) {
    _socket?.emit(_Ev.cmdItineraryReorder, {
      'itineraryId': itineraryId,
      'stopIds': stopIds,
    });
  }

  /// 通用发送（业务方有需要扩展时用）
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  // ─── 释放（一般 App 生命周期内不调用） ────────────────────────────────
  Future<void> dispose() async {
    disconnect();
    await _eventsCtl.close();
    await _connectionStateCtl.close();
    await _userProfileUpdatedCtl.close();
    await _poiSavedCtl.close();
    await _poiUnsavedCtl.close();
    await _tipCreatedCtl.close();
    await _tipUpdatedCtl.close();
    await _tipDeletedCtl.close();
    await _itineraryUpdatedCtl.close();
    await _itineraryReorderedCtl.close();
    await _navigationUpdatedCtl.close();
    await _unitySceneReadyCtl.close();
    await _unityCitySelectedCtl.close();
    await _unityPoiSelectedCtl.close();
    await _unityCameraChangedCtl.close();
  }

  // ════════════════════════════════════════════════════════════════════════
  //                              内部实现
  // ════════════════════════════════════════════════════════════════════════

  IO.Socket _buildSocket() {
    final token = Api.main.accessToken;
    return IO.io(
      _url,
      IO.OptionBuilder()
          .setPath(_path)
          .setTransports(['websocket']) // 必须仅 websocket，与后端一致
          .disableAutoConnect() // 我们手动控制
          .disableReconnection() // 自带重连关掉，我们自己实现（要走 token 续期）
          .setAuth({'token': token})
          .build(),
    );
  }

  void _bindHandlers(IO.Socket socket) {
    // ── 连接生命周期 ────────────────────────────────────────────────
    socket.onConnect((_) {
      debugPrint('[Realtime] 已连接 socket=${socket.id}');
      _reconnectAttempts = 0;
    });

    socket.on(_Ev.connectionReady, (data) {
      debugPrint('[Realtime] connection.ready: $data');
      _setState(RealtimeConnectionState.connected);

      // 恢复之前订阅的频道
      for (final c in _subscribedChannels) {
        socket.emit(_Ev.cmdSubscribe, {'channel': c});
      }
    });

    socket.on(_Ev.connectionError, (data) {
      debugPrint('[Realtime] connection.error: $data');
      onError?.call(data);

      // 服务端在认证失败时会发 connection.error 然后断开。
      // 这里尝试通过 Api 续期 token，再走重连流程。
      _tryRefreshTokenAndReconnect();
    });

    socket.onConnectError((err) {
      debugPrint('[Realtime] connect_error: $err');
      onError?.call(err);
      _scheduleReconnect();
    });

    socket.onError((err) {
      debugPrint('[Realtime] error: $err');
      onError?.call(err);
    });

    socket.onDisconnect((reason) {
      debugPrint('[Realtime] disconnected: $reason');
      if (_userWantsConnected) {
        _scheduleReconnect();
      } else {
        _setState(RealtimeConnectionState.disconnected);
      }
    });

    // ── 业务事件 → 同时分发到 Stream + Callback + 通用流 ─────────────
    socket.on(_Ev.userProfileUpdated, (d) => _emit(_Ev.userProfileUpdated,
        d, _userProfileUpdatedCtl, onUserProfileUpdated));
    socket.on(_Ev.poiSaved, (d) => _emit(_Ev.poiSaved, d, _poiSavedCtl, onPoiSaved));
    socket.on(_Ev.poiUnsaved,
        (d) => _emit(_Ev.poiUnsaved, d, _poiUnsavedCtl, onPoiUnsaved));
    socket.on(_Ev.tipCreated,
        (d) => _emit(_Ev.tipCreated, d, _tipCreatedCtl, onTipCreated));
    socket.on(_Ev.tipUpdated,
        (d) => _emit(_Ev.tipUpdated, d, _tipUpdatedCtl, onTipUpdated));
    socket.on(_Ev.tipDeleted,
        (d) => _emit(_Ev.tipDeleted, d, _tipDeletedCtl, onTipDeleted));
    socket.on(_Ev.itineraryUpdated, (d) => _emit(_Ev.itineraryUpdated, d,
        _itineraryUpdatedCtl, onItineraryUpdated));
    socket.on(_Ev.itineraryReordered, (d) => _emit(_Ev.itineraryReordered, d,
        _itineraryReorderedCtl, onItineraryReordered));
    socket.on(_Ev.navigationUpdated, (d) => _emit(_Ev.navigationUpdated, d,
        _navigationUpdatedCtl, onNavigationUpdated));
    socket.on(_Ev.unitySceneReady, (d) => _emit(_Ev.unitySceneReady, d,
        _unitySceneReadyCtl, onUnitySceneReady));
    socket.on(_Ev.unityCitySelected, (d) => _emit(_Ev.unityCitySelected, d,
        _unityCitySelectedCtl, onUnityCitySelected));
    socket.on(_Ev.unityPoiSelected, (d) => _emit(_Ev.unityPoiSelected, d,
        _unityPoiSelectedCtl, onUnityPoiSelected));
    socket.on(_Ev.unityCameraChanged, (d) => _emit(_Ev.unityCameraChanged, d,
        _unityCameraChangedCtl, onUnityCameraChanged));
  }

  /// 统一分发：通用流 + 专用流 + 回调，三处都发
  void _emit(
    String name,
    dynamic data,
    StreamController<dynamic> ctl,
    RealtimeListener<dynamic>? cb,
  ) {
    if (!ctl.isClosed) ctl.add(data);
    if (!_eventsCtl.isClosed) _eventsCtl.add(RealtimeEvent(name, data));
    try {
      cb?.call(data);
    } catch (e, st) {
      debugPrint('[Realtime] callback error for $name: $e\n$st');
    }
  }

  // ─── 重连（指数退避） ──────────────────────────────────────────────────

  void _scheduleReconnect() {
    if (!_userWantsConnected) return;
    if (_reconnectTimer?.isActive ?? false) return;

    final base = _reconnectInitial.inMilliseconds;
    final delayMs = (base * (1 << _reconnectAttempts.clamp(0, 5)))
        .clamp(base, _reconnectMax.inMilliseconds);
    _reconnectAttempts++;

    debugPrint(
        '[Realtime] reconnect in ${delayMs}ms (attempt $_reconnectAttempts)');
    _setState(RealtimeConnectionState.reconnecting);

    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_userWantsConnected) return;
      // 更新 auth（token 可能已被刷新）
      _socket?.auth = {'token': Api.main.accessToken};
      _socket?.connect();
    });
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  /// 服务器 connection.error（认证失败）时调用：
  /// 用 Api 触发一次 token 续期，再尝试重连
  Future<void> _tryRefreshTokenAndReconnect() async {
    if (!_userWantsConnected) return;

    // 直接调一个轻量级私有接口触发 Api 内部的 401 → refresh 逻辑
    try {
      await Api.main.get('/me/profile');
    } catch (_) {
      // 即使失败也走重连，让退避节流处理
    }

    if (Api.main.isAuthenticated) {
      _socket?.auth = {'token': Api.main.accessToken};
      _scheduleReconnect();
    } else {
      // 续期也失败 → Api 会触发 onUnauthorized；这里安静断开
      disconnect();
    }
  }

  // ─── 状态变更 ──────────────────────────────────────────────────────────
  void _setState(RealtimeConnectionState s) {
    if (_state == s) return;
    _state = s;
    if (!_connectionStateCtl.isClosed) _connectionStateCtl.add(s);
    try {
      onConnectionStateChanged?.call(s);
    } catch (_) {}
  }

  void _assertInit() {
    assert(_initialized,
        'Realtime 未初始化。请在 main() 中调用 Realtime.I.init(url: ...)');
  }
}
