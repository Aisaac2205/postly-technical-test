import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

class GetPostsEvent extends PostsEvent {
  const GetPostsEvent();
}

class PostsLoadMore extends PostsEvent {
  const PostsLoadMore();
}
