import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class UnityPreloader extends StatefulWidget {
  final Duration timeout;

  const UnityPreloader({super.key, this.timeout = const Duration(seconds: 8)});

  @override
  State<UnityPreloader> createState() => _UnityPreloaderState();
}

class _UnityPreloaderState extends State<UnityPreloader> {
  Timer? _timeoutTimer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    if (_isUnitySupported) {
      _timeoutTimer = Timer(widget.timeout, _finishPreload);
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnitySupported || !_visible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: -2,
      top: -2,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.01,
          child: SizedBox(
            width: 1,
            height: 1,
            child: EmbedUnity(onMessageFromUnity: _handleUnityMessage),
          ),
        ),
      ),
    );
  }

  bool get _isUnitySupported {
    var isWidgetTest = false;
    assert(() {
      isWidgetTest = WidgetsBinding.instance.runtimeType.toString().contains(
        'Test',
      );
      return true;
    }());

    return !kIsWeb &&
        !isWidgetTest &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }

  void _handleUnityMessage(String message) {
    if (_isReadyMessage(message)) {
      _finishPreload();
    }
  }

  bool _isReadyMessage(String message) {
    if (message == 'scene_loaded' || message == 'globe_ready') {
      return true;
    }

    try {
      final decoded = jsonDecode(message);
      return decoded is Map<String, dynamic> &&
          (decoded['evt'] == 'ready' || decoded['type'] == 'ready');
    } on FormatException {
      return false;
    }
  }

  void _finishPreload() {
    if (!mounted || !_visible) {
      return;
    }

    setState(() {
      _visible = false;
    });
  }
}
