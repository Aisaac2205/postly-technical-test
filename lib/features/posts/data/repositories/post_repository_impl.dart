import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  const PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts() async {
    try {
      final models = await remoteDataSource.getPosts();
      final entities = models
          .map<PostEntity>(
            (post) => PostEntity(
              id: post.id,
              userId: post.userId,
              title: post.title,
              body: post.body,
            ),
          )
          .toList(growable: false);
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(int id) async {
    try {
      final model = await remoteDataSource.getPostById(id);
      final entity = PostEntity(
        id: model.id,
        userId: model.userId,
        title: model.title,
        body: model.body,
      );
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
