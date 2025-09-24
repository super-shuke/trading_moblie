import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:3030/trpc',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  Future<dynamic> dioGet(String url, dynamic params) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          "input": jsonEncode({"json": params}),
        },
      );
      final List<dynamic> data = response.data["result"]["data"]["json"];
      return data;
    } on DioException catch (e) {
      // 打印错误信息，然后重新抛出，让调用方也能处理
      print('Dio GET Error: $e');
      rethrow;
    }
  }

  Future<dynamic> dioPost(String url, Map<String, dynamic> params) async {
    try {
      final response = await _dio.post(url, data: jsonEncode({"json": params}));
      final List<dynamic> data = response.data["result"]["data"]["json"];
      return data;
    } on DioException catch (e) {
      print('Dio POST Error: $e');
      rethrow;
    }
  }
}
