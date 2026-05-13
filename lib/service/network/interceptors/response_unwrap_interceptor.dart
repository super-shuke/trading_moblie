// ResponseUnwrapInterceptor —— 响应解包拦截器
//
// 背景：
//   GeoTravel 后端的所有成功响应都是统一格式：
//     { "success": true, "data": <真正的业务数据>, "timestamp": "..." }
//   错误响应是：
//     { "success": false, "statusCode": 404, "error": "...", "message": "...", "path": "...", "timestamp": "..." }
//
//   如果不处理，业务代码每次都得写 `res.data['data']`，又啰嗦又容易出错。
//
// 本拦截器在响应成功时自动把外层信封拆掉：
//   原始：  response.data = { success: true, data: { items: [...] }, timestamp: "..." }
//   拆完：  response.data = { items: [...] }
//
// 同时把 timestamp 和 success 标志保存到 response.extra，
// 如果某个业务真的需要原始信封也能拿到。
//
// 错误响应不在这里处理 —— Dio 会自动把 4xx/5xx 转成 DioException，
// 业务方可以从 e.response?.data 拿到原始的错误体（含 message/statusCode）。

import 'package:dio/dio.dart';

class ResponseUnwrapInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final body = response.data;

    // 只处理形如 { success: true, data: ... } 的 Map
    if (body is Map &&
        body['success'] == true &&
        body.containsKey('data')) {
      // 保留 envelope 信息，必要时业务可以读取
      response.extra['envelope'] = {
        'success': body['success'],
        'timestamp': body['timestamp'],
      };
      response.data = body['data'];
    }

    handler.next(response);
  }
}
