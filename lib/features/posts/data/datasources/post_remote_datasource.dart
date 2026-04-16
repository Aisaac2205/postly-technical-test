import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPostById(int id);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  const PostRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await dio.get(ApiConstants.postsEndpoint);
      return (response.data as List)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unexpected server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.postsEndpoint}/$id');
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unexpected server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
