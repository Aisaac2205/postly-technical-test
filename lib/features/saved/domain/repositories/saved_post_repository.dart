import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../posts/domain/entities/post_entity.dart';

abstract class SavedPostRepository {
  Either<Failure, List<PostEntity>> getSavedPosts();
  Future<Either<Failure, Unit>> savePost(PostEntity post);
  Future<Either<Failure, Unit>> removePost(int id);
  bool isPostSaved(int id);
}
