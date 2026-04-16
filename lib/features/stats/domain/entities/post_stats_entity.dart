import 'package:equatable/equatable.dart';
import '../../../posts/domain/entities/post_entity.dart';

class PostStatsEntity extends Equatable {
  final int totalPosts;
  final int totalAuthors;
  final int avgWordsPerPost;
  final PostEntity longestPost;
  final Map<int, int> postsPerUser;
  final Map<String, int> topWords;

  const PostStatsEntity({
    required this.totalPosts,
    required this.totalAuthors,
    required this.avgWordsPerPost,
    required this.longestPost,
    required this.postsPerUser,
    required this.topWords,
  });

  @override
  List<Object?> get props => [
        totalPosts,
        totalAuthors,
        avgWordsPerPost,
        longestPost,
        postsPerUser,
        topWords,
      ];
}
