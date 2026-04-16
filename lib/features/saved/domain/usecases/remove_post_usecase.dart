import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/saved_post_repository.dart';

class RemovePostUseCase {
  final SavedPostRepository _repository;

  RemovePostUseCase(this._repository);

  Future<Either<Failure, Unit>> call(int id) => _repository.removePost(id);
}
