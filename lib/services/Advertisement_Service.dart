import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/models/Advertisement_Model.dart';

class AdvertisementService {

  final _dio = DioClient.dio;
  Future<Advertisementmodel> fetchadvertisementdata () async{
     try{
        final response = await _dio.get("advertisement");
        if (kDebugMode) {
          AppLogger.info("AdvertisementService ${response.data}");
        }
        return Advertisementmodel.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : <String, dynamic>{},
        );
     }on DioException catch(e){
      AppLogger.error(
        "Advertisement fetch failed: ${e.response?.statusCode} ${e.response?.data}",
      );
      return Advertisementmodel(success: false, data: const []);
     } catch (e, st) {
      AppLogger.error("Advertisement parse error: $e\n$st");
      return Advertisementmodel(success: false, data: const []);
     }
  }
}