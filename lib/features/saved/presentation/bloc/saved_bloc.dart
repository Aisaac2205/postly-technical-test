import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_saved_posts_usecase.dart';
import '../../domain/usecases/save_post_usecase.dart';
import '../../domain/usecases/remove_post_usecase.dart';
import 'saved_event.dart';
import 'saved_state.dart';

class SavedBloc extends Bloc<SavedEvent, SavedState> {
  final GetSavedPostsUseCase _getSavedPosts;
  final SavePostUseCase _savePost;
  final RemovePostUseCase _removePost;

  SavedBloc({
    required GetSavedPostsUseCase getSavedPostsUseCase,
    required SavePostUseCase savePostUseCase,
    required RemovePostUseCase removePostUseCase,
  })  : _getSavedPosts = getSavedPostsUseCase,
        _savePost = savePostUseCase,
        _removePost = removePostUseCase,
        super(const SavedInitial()) {
    on<LoadSaved>(_onLoadSaved);
    on<SavePost>(_onSavePost);
    on<RemovePost>(_onRemovePost);
  }

  void _emitCurrentSaved(Emitter<SavedState> emit) {
    _getSavedPosts().fold(
      (failure) => emit(SavedError(failure.message)),
      (posts) => emit(SavedLoaded(posts)),
    );
  }

  void _onLoadSaved(LoadSaved event, Emitter<SavedState> emit) {
    _emitCurrentSaved(emit);
  }

  Future<void> _onSavePost(SavePost event, Emitter<SavedState> emit) async {
    final result = await _savePost(event.post);
    result.fold(
      (failure) => emit(SavedError(failure.message)),
      (_) => _emitCurrentSaved(emit),
    );
  }

  Future<void> _onRemovePost(RemovePost event, Emitter<SavedState> emit) async {
    final result = await _removePost(event.id);
    result.fold(
      (failure) => emit(SavedError(failure.message)),
      (_) => _emitCurrentSaved(emit),
    );
  }
}
