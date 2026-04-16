import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostByIdParams {
  final int id;
  const GetPostByIdParams({required this.id});
}

class GetPostByIdUseCase {
  final PostRepository repository;

  const GetPostByIdUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(GetPostByIdParams params) {
    return repository.getPostById(params.id);
  }
}
