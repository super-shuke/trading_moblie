# Api —— 单文件 Flutter 网络层

为 GeoTravel NestJS 后端配套的极简网络层。

**对外只有一个类：`Api`**。所有 Dio、拦截器、Token 存储都封装在内部。

## 依赖

```yaml
dependencies:
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
```

## 使用方式

### 1. 启动时初始化（一次）

```dart
import 'api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Api.main.init(baseUrl: 'http://localhost:3000/api/v1');

  // 可选：续期失败时跳登录页
  Api.main.onUnauthorized = () => router.go('/login');

  runApp(const MyApp());
}
```

### 2. 调用接口

```dart
// 公开接口 —— 不需要登录
final cities = await Api.main.get('/cities', query: {'page': 1});

// 私有接口 —— 自动加 token；过期自动续期重试
final profile = await Api.main.get('/me/profile');

// POST / PATCH / DELETE
await Api.main.post('/me/saved-pois/$poiId');
await Api.main.patch('/tips/$id', body: {'body': '...'});
await Api.main.delete('/tips/$id');
```

返回值已经**自动解包**——直接拿到后端 `data` 字段的内容，不用再 `.data['data']`。

### 3. 登录 / 登出

```dart
// 用 Google ID Token 登录（前端先用 google_sign_in 拿到 idToken）
await Api.main.loginWithGoogle(idToken);

// 登出
await Api.main.logout();

// 检查登录状态
if (Api.main.isAuthenticated) { ... }
```

### 4. 错误处理

所有失败统一抛 `ApiException`：

```dart
try {
  await Api.main.get('/me/itineraries');
} on ApiException catch (e) {
  if (e.isUnauthorized) { /* 401 */ }
  else if (e.isForbidden) { /* 403 */ }
  else if (e.isNotFound) { /* 404 */ }
  else if (e.isNetworkError) { /* 网络问题 */ }
  else { showToast(e.message); }
}
```

`ApiException` 字段：

- `statusCode` —— HTTP 状态码（网络错误为 -1）
- `message` —— 后端的 message 字段，否则 Dio 错误信息
- `error` —— 后端 error 字段（如 `"NotFoundException"`）
- `path` —— 请求路径
- `cause` —— 原始 DioException

## 自动处理的事情

| 行为 | 触发条件 |
|------|---------|
| 附加 `Authorization: Bearer <token>` | 所有非公开请求（自动识别 `/auth/*` 跳过） |
| 用 refreshToken 续期 + 重试原请求 | 收到 401 时 |
| 并发安全 refresh | 多个请求同时 401 只调一次 `/auth/refresh` |
| 清空本地 token + 触发 `onUnauthorized` | 续期也失败时 |
| 剥掉 `{ success, data, timestamp }` 外壳 | 所有 200 响应 |
| 把 DioException 转成 ApiException | 所有错误响应 |
| Token 加密存储（Keychain / KeyStore） | login/refresh 成功时 |
| 日志中 token 自动脱敏 | enableLogging=true 时 |
| 日志默认仅 debug 模式 | release 自动关 |

## 不需要的"高级"用法

某次请求**显式不带 token**（一般不需要，因为登录/刷新已自动跳过）：

```dart
await Api.main.get('/some-third-party-public-api', skipAuth: true);
```

## 跟 NestJS 后端的对应关系

| 后端 | Api 类的处理 |
|------|------------|
| `JwtAuthGuard` 检查 `Authorization` 头 | `_request` → 拦截器自动附加 |
| `TransformInterceptor` 包响应 `{success,data,...}` | `_unwrap` 自动剥 |
| `HttpExceptionFilter` 抛错误响应 | `_toApiException` 转成 `ApiException` |
| `POST /auth/google` Google 登录 | `Api.main.loginWithGoogle()` |
| `POST /auth/refresh` 续期 | 收到 401 时拦截器自动调 |
| `POST /auth/logout` 登出 | `Api.main.logout()` |

## 文件清单

```
lib/
├── api.dart        ← 整个网络层（单文件）
└── main.dart       ← 使用示例
```

整个 Api + 内部的 TokenStore 共约 400 行，含完整中文注释。
