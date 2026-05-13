// ============================================================================
// itinerary_bloc.dart —— 示例 Bloc：实时同步行程状态
//
// 这个例子演示了"socket + bloc"协作模式：
//
//   ① 进入页面 → bloc 加载行程详情（REST） + 订阅 WebSocket 频道
//   ② Realtime 收到 itinerary.updated / itinerary.reordered
//      → bloc 把 socket 事件转成 Bloc event
//      → reducer 计算新 state
//      → UI 自动刷新
//   ③ 退出页面 → bloc.close() 自动取消订阅、退订频道
//
// 这是 Redux 心智模型（单向数据流：event → reducer → state）的标准实现。
// 关键技巧：把 Realtime 的 Stream 直接接到 bloc 的 event 流。
//
// 依赖：
//   dependencies:
//     flutter_bloc: ^8.1.6
//     equatable: ^2.0.5
// ============================================================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traveling_app/service/network/dio_quest.dart';
import 'package:traveling_app/service/socket/mainSocket.dart';


// ─── State ─────────────────────────────────────────────────────────────────

class ItineraryState extends Equatable {
  const ItineraryState({
    required this.itineraryId,
    this.title = '',
    this.stops = const [],
    this.isLoading = false,
    this.isRealtimeConnected = false,
    this.error,
  });

  /// 初始状态
  factory ItineraryState.initial(String itineraryId) =>
      ItineraryState(itineraryId: itineraryId, isLoading: true);

  final String itineraryId;
  final String title;
  final List<Map<String, dynamic>> stops; // 简化用 Map；生产环境换 typed model
  final bool isLoading;
  final bool isRealtimeConnected;
  final String? error;

  ItineraryState copyWith({
    String? title,
    List<Map<String, dynamic>>? stops,
    bool? isLoading,
    bool? isRealtimeConnected,
    String? error,
    bool clearError = false,
  }) {
    return ItineraryState(
      itineraryId: itineraryId,
      title: title ?? this.title,
      stops: stops ?? this.stops,
      isLoading: isLoading ?? this.isLoading,
      isRealtimeConnected: isRealtimeConnected ?? this.isRealtimeConnected,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [itineraryId, title, stops, isLoading, isRealtimeConnected, error];
}

// ─── Events ────────────────────────────────────────────────────────────────

sealed class ItineraryEvent extends Equatable {
  const ItineraryEvent();
  @override
  List<Object?> get props => [];
}

/// 启动：加载详情 + 订阅 WebSocket
class ItineraryStarted extends ItineraryEvent {
  const ItineraryStarted();
}

/// 用户手动重排（先乐观更新 → 调 REST → 失败回滚）
class ItineraryStopsReordered extends ItineraryEvent {
  const ItineraryStopsReordered(this.newOrder);
  final List<String> newOrder;
  @override
  List<Object?> get props => [newOrder];
}

/// 来自 WebSocket 的实时更新（reducer 不区分是别人改的还是自己改的回声）
class _ItineraryRealtimeUpdated extends ItineraryEvent {
  const _ItineraryRealtimeUpdated(this.payload);
  final dynamic payload;
  @override
  List<Object?> get props => [payload];
}

class _ItineraryRealtimeReordered extends ItineraryEvent {
  const _ItineraryRealtimeReordered(this.payload);
  final dynamic payload;
  @override
  List<Object?> get props => [payload];
}

class _ConnectionStateChanged extends ItineraryEvent {
  const _ConnectionStateChanged(this.state);
  final RealtimeConnectionState state;
  @override
  List<Object?> get props => [state];
}

// ─── Bloc ──────────────────────────────────────────────────────────────────

class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  ItineraryBloc({required String itineraryId})
      : super(ItineraryState.initial(itineraryId)) {
    on<ItineraryStarted>(_onStarted);
    on<ItineraryStopsReordered>(_onUserReordered);
    on<_ItineraryRealtimeUpdated>(_onRealtimeUpdated);
    on<_ItineraryRealtimeReordered>(_onRealtimeReordered);
    on<_ConnectionStateChanged>(_onConnectionStateChanged);

    // ★ 关键：把 Realtime 的 Stream 直接接到 Bloc 的 event 流
    // 这就是"socket 消息广播给 store"的标准做法。
    _itineraryUpdatedSub = SocketApi.main.itineraryUpdated.listen((data) {
      if (_belongsToThisItinerary(data)) {
        add(_ItineraryRealtimeUpdated(data));
      }
    });
    _itineraryReorderedSub = SocketApi.main.itineraryReordered.listen((data) {
      if (_belongsToThisItinerary(data)) {
        add(_ItineraryRealtimeReordered(data));
      }
    });
    _connectionStateSub = SocketApi.main.connectionState.listen((state) {
      add(_ConnectionStateChanged(state));
    });
  }

  StreamSubscription? _itineraryUpdatedSub;
  StreamSubscription? _itineraryReorderedSub;
  StreamSubscription? _connectionStateSub;

  String get _channel => 'itinerary:${state.itineraryId}';

  bool _belongsToThisItinerary(dynamic data) {
    if (data is Map) {
      final id = data['itineraryId'] ?? data['itinerary']?['id'];
      return id == state.itineraryId;
    }
    return false;
  }

  // ─── handlers ────────────────────────────────────────────────────────

  Future<void> _onStarted(
    ItineraryStarted event,
    Emitter<ItineraryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // 1) REST 加载详情
      final data = await Api.main.get('/me/itineraries/${state.itineraryId}')
          as Map<String, dynamic>;

      // 2) 订阅 WebSocket 频道，开始接实时更新
      SocketApi.main.subscribe(_channel);

      emit(state.copyWith(
        title: data['title'] as String? ?? '',
        stops: List<Map<String, dynamic>>.from(
          (data['stops'] as List?) ?? const [],
        ),
        isLoading: false,
        isRealtimeConnected: SocketApi.main.isConnected,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    }
  }

  /// 用户拖拽重排（乐观更新模式）
  Future<void> _onUserReordered(
    ItineraryStopsReordered event,
    Emitter<ItineraryState> emit,
  ) async {
    // 1) 乐观更新 UI（立即响应）
    final oldStops = state.stops;
    final reordered = _reorderStops(oldStops, event.newOrder);
    emit(state.copyWith(stops: reordered));

    // 2) 顺便通过 WebSocket 广播"预览"，让协同端立刻看到
    SocketApi.main.itineraryReorderPreview(
      itineraryId: state.itineraryId,
      stopIds: event.newOrder,
    );

    // 3) 调 REST 落库
    try {
      await Api.main.patch(
        '/me/itineraries/${state.itineraryId}/stops/reorder',
        body: {'stopIds': event.newOrder},
      );
      // 成功 —— 服务器会推 itinerary.reordered，但内容跟当前一致，
      // _onRealtimeReordered 会做幂等处理
    } on ApiException catch (e) {
      // 失败 —— 回滚
      emit(state.copyWith(stops: oldStops, error: e.message));
    }
  }

  /// 收到 socket 推来的更新（可能是自己的回声，也可能是别人改的）
  void _onRealtimeUpdated(
    _ItineraryRealtimeUpdated event,
    Emitter<ItineraryState> emit,
  ) {
    final payload = event.payload;
    if (payload is! Map) return;

    final it = payload['itinerary'] as Map?;
    if (it == null) return;

    emit(state.copyWith(
      title: it['title'] as String? ?? state.title,
      // 这里简化：完整刷新 stops。生产环境根据 action 字段（stop.added/updated/removed）
      // 做精细 diff。
      stops: it['stops'] != null
          ? List<Map<String, dynamic>>.from(it['stops'] as List)
          : state.stops,
    ));
  }

  void _onRealtimeReordered(
    _ItineraryRealtimeReordered event,
    Emitter<ItineraryState> emit,
  ) {
    final payload = event.payload;
    if (payload is! Map) return;
    final order = (payload['stopIds'] as List?)?.cast<String>();
    if (order == null) return;

    final reordered = _reorderStops(state.stops, order);
    emit(state.copyWith(stops: reordered));
  }

  void _onConnectionStateChanged(
    _ConnectionStateChanged event,
    Emitter<ItineraryState> emit,
  ) {
    emit(state.copyWith(
      isRealtimeConnected: event.state == RealtimeConnectionState.connected,
    ));
  }

  // ─── helpers ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _reorderStops(
    List<Map<String, dynamic>> stops,
    List<String> order,
  ) {
    final byId = {for (final s in stops) s['id'] as String: s};
    return [
      for (final id in order)
        if (byId[id] != null) byId[id]!,
    ];
  }

  // ─── 清理 ────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    // 退出页面时取消订阅频道 + 解绑 stream listener
    SocketApi.main.unsubscribe(_channel);
    await _itineraryUpdatedSub?.cancel();
    await _itineraryReorderedSub?.cancel();
    await _connectionStateSub?.cancel();
    return super.close();
  }
}
