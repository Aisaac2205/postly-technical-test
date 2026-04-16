import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object?> get props => [];
}

class PostsInitial extends PostsState {
  const PostsInitial();
}

class PostsLoading extends PostsState {
  const PostsLoading();
}

class PostsSuccess extends PostsState {
  final List<PostEntity> posts;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const PostsSuccess({
    required this.posts,
    required this.hasReachedMax,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  PostsSuccess copyWith({
    List<PostEntity>? posts,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return PostsSuccess(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedMax, currentPage, isLoadingMore];
}

class PostsFailure extends PostsState {
  final String message;

  const PostsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
