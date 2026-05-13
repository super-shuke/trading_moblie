// AuthStore —— Token 安全存储（参考实现）
//
// 用 flutter_secure_storage 把 access/refresh token 存在系统安全区：
//   - iOS:    Keychain
//   - Android: EncryptedSharedPreferences（KeyStore 加密）
//   - 比 SharedPreferences / 文件明文存储安全得多
//
// pubspec.yaml 需要加：
//   dependencies:
//     flutter_secure_storage: ^9.2.2
//
// 用法：
//   final authStore = AuthStore();
//   await authStore.loadFromDisk();   // 启动时调一次
//
//   DioClient.instance.initialize(
//     baseUrl: '...',
//     accessTokenProvider:  () => authStore.accessToken,
//     refreshTokenProvider: () => authStore.refreshToken,
//     onTokensRefreshed:    authStore.save,
//     onUnauthorized:       () { authStore.clear(); /* 跳登录 */ },
//   );
//
// 注意：这是参考实现。如果你项目已经有自己的 AuthRepository / AuthStore，
//      不必照搬，能提供"读 token / 写 token / 清空"三个能力即可。

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStore {
  AuthStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  static const _kAccess = 'auth.accessToken';
  static const _kRefresh = 'auth.refreshToken';

  // 内存缓存，避免每次拦截器都走磁盘 IO
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null;

  /// App 启动时调用一次，把磁盘里的 token 加载到内存
  Future<void> loadFromDisk() async {
    _accessToken = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);
  }

  /// 保存新 token（登录成功 / token 续期后调用）
  Future<void> save({required String access, required String refresh}) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  /// 清空（登出 / 续期失败后调用）
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
