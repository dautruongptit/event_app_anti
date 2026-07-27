import 'package:event_app/core/constants/api_constants.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/relative.dart';
import 'package:event_app/models/group_summary.dart';

class RelativeService {
  final DioClient _dio;
  RelativeService(this._dio);

  Future<List<RelativeModel>> getRelatives({
    String? groupType,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (groupType != null) queryParams['groupType'] = groupType;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get(
      ApiConstants.relatives,
      queryParameters: queryParams,
    );
    return (response.data['data'] as List)
        .map((e) => RelativeModel.fromJson(e))
        .toList();
  }

  Future<List<GroupSummary>> getGroupSummary() async {
    final response = await _dio.get(ApiConstants.relativeGroups);
    return (response.data['data'] as List)
        .map((e) => GroupSummary.fromJson(e))
        .toList();
  }

  Future<RelativeDetailModel> getDetail(int id) async {
    final response = await _dio.get(ApiConstants.relativeById(id));
    return RelativeDetailModel.fromJson(response.data['data']);
  }

  Future<RelativeModel> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.relatives, data: data);
    return RelativeModel.fromJson(response.data['data']);
  }

  Future<RelativeModel> update(int id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.relativeById(id), data: data);
    return RelativeModel.fromJson(response.data['data']);
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiConstants.relativeById(id));
  }
}
