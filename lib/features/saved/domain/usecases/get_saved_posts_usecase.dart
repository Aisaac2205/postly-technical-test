import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../repositories/saved_post_repository.dart';

class GetSavedPostsUseCase {
  final SavedPostRepository _repository;

  GetSavedPostsUseCase(this._repository);

  Either<Failure, List<PostEntity>> call() => _repository.getSavedPosts();
}
