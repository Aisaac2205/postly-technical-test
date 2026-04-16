import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../local/saved_post_model.dart';

abstract class SavedPostLocalDatasource {
  Either<Failure, List<PostEntity>> getSavedPosts();
  Future<Either<Failure, Unit>> savePost(PostEntity post);
  Future<Either<Failure, Unit>> removePost(int id);
  bool isPostSaved(int id);
}

class SavedPostLocalDatasourceImpl implements SavedPostLocalDatasource {
  final Box<SavedPostModel> _box;

  SavedPostLocalDatasourceImpl(this._box);

  @override
  Either<Failure, List<PostEntity>> getSavedPosts() {
    try {
      return Right(_box.values.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePost(PostEntity post) async {
    try {
      await _box.put(post.id, SavedPostModel.fromEntity(post));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removePost(int id) async {
    try {
      await _box.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  bool isPostSaved(int id) => _box.containsKey(id);
}
