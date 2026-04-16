import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../repositories/saved_post_repository.dart';

class SavePostUseCase {
  final SavedPostRepository _repository;

  SavePostUseCase(this._repository);

  Future<Either<Failure, Unit>> call(PostEntity post) =>
      _repository.savePost(post);
}
