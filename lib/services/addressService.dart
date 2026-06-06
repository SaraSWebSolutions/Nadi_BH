import 'package:dio/dio.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';

class AddressService {
  final _dio = DioClient.dio;
  Future<List<Map<String, dynamic>>> getBlocks() async {
    final response = await _dio.get('/blocks');

    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }
}
