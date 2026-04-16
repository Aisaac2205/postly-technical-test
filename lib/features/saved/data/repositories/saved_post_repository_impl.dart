import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../domain/repositories/saved_post_repository.dart';
import '../datasources/saved_post_local_datasource.dart';

class SavedPostRepositoryImpl implements SavedPostRepository {
  final SavedPostLocalDatasource _datasource;

  SavedPostRepositoryImpl(this._datasource);

  @override
  Either<Failure, List<PostEntity>> getSavedPosts() =>
      _datasource.getSavedPosts();

  @override
  Future<Either<Failure, Unit>> savePost(PostEntity post) =>
      _datasource.savePost(post);

  @override
  Future<Either<Failure, Unit>> removePost(int id) =>
      _datasource.removePost(id);

  @override
  bool isPostSaved(int id) => _datasource.isPostSaved(id);
}
