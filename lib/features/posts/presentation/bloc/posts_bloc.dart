import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPostsUseCase getPostsUseCase;

  static const int postsPerPage = 10;

  List<PostEntity> _allPosts = [];

  List<PostEntity> get allPosts => List.unmodifiable(_allPosts);

  PostsBloc({required this.getPostsUseCase}) : super(const PostsInitial()) {
    on<GetPostsEvent>(_onGetPosts);
    on<PostsLoadMore>(_onLoadMore);
  }

  Future<void> _onGetPosts(
    GetPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());
    try {
      final result = await getPostsUseCase();
      result.fold(
        (failure) => emit(PostsFailure(failure.message)),
        (posts) {
          _allPosts = posts;
          final firstPage = posts.take(postsPerPage).toList();
          emit(PostsSuccess(
            posts: firstPage,
            hasReachedMax: posts.length <= postsPerPage,
            currentPage: 1,
          ));
        },
      );
    } catch (e) {
      emit(PostsFailure(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    PostsLoadMore event,
    Emitter<PostsState> emit,
  ) async {
    final current = state;
    if (current is! PostsSuccess) return;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final newSlice = _allPosts
        .skip((nextPage - 1) * postsPerPage)
        .take(postsPerPage)
        .toList();

    final accumulated = current.posts + newSlice;
    final hasReachedMax = accumulated.length >= _allPosts.length;

    emit(PostsSuccess(
      posts: accumulated,
      hasReachedMax: hasReachedMax,
      currentPage: nextPage,
    ));
  }
}
