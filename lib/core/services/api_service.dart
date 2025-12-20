import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final StorageService _storage = StorageService();

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Log request
        print('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
        print('📤 Headers: ${options.headers}');
        print('📤 Data: ${options.data}');
        
        // Add auth token
        final token = await _storage.getSecureString(AppConstants.keyToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR: ${error.type}');
        print('❌ Message: ${error.message}');
        print('❌ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
        if (error.response != null) {
          print('❌ Status: ${error.response?.statusCode}');
          print('❌ Data: ${error.response?.data}');
        }
        
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - redirect to login
          // This will be handled by auth service
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    String errorMessage = 'Đã xảy ra lỗi';
    
    // Log detailed error for debugging
    print('🔴 Error Type: ${error.type}');
    print('🔴 Error Message: ${error.message}');
    print('🔴 Request URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
    
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      print('🔴 Response Status: $statusCode');
      print('🔴 Response Data: $data');
      
      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'];
      } else {
        switch (statusCode) {
          case 400:
            errorMessage = 'Yêu cầu không hợp lệ';
            break;
          case 401:
            errorMessage = 'Chưa đăng nhập';
            break;
          case 403:
            errorMessage = 'Không có quyền truy cập';
            break;
          case 404:
            errorMessage = 'Không tìm thấy';
            break;
          case 500:
            errorMessage = 'Lỗi server';
            break;
          default:
            errorMessage = 'Đã xảy ra lỗi ($statusCode)';
        }
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Hết thời gian kết nối';
      print('🔴 Connection timeout to: ${error.requestOptions.baseUrl}');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Hết thời gian nhận dữ liệu';
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'Không thể kết nối đến server';
      print('🔴 Connection error to: ${error.requestOptions.baseUrl}');
      print('🔴 Error details: ${error.error}');
    } else {
      print('🔴 Unknown error type: ${error.type}');
      print('🔴 Error: ${error.error}');
    }
    
    return errorMessage;
  }
}

