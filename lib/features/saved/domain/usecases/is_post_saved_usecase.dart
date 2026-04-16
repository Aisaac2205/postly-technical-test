import '../repositories/saved_post_repository.dart';

class IsPostSavedUseCase {
  final SavedPostRepository _repository;

  IsPostSavedUseCase(this._repository);

  bool call(int id) => _repository.isPostSaved(id);
}
