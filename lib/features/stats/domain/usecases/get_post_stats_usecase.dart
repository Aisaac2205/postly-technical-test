import '../../../posts/domain/entities/post_entity.dart';
import '../entities/post_stats_entity.dart';

class GetPostStatsUseCase {
  static const Set<String> _stopWords = {
    'the', 'a', 'an', 'in', 'on', 'at', 'to', 'of', 'and', 'or',
    'is', 'it', 'as', 'by', 'for', 'with', 'that', 'this', 'are',
    'was', 'be', 'has', 'have', 'i',
  };

  PostStatsEntity call(List<PostEntity> posts) {
    assert(posts.isNotEmpty, 'Cannot compute stats from an empty post list');

    final totalPosts = posts.length;

    final totalAuthors = posts.map((p) => p.userId).toSet().length;

    final totalWords = posts.fold<int>(
      0,
      (sum, p) => sum + p.body.split(RegExp(r'\s+')).length,
    );
    final avgWordsPerPost = totalWords ~/ totalPosts;

    final longestPost = posts.reduce(
      (a, b) => a.body.length >= b.body.length ? a : b,
    );

    final postsPerUser = <int, int>{};
    for (final post in posts) {
      postsPerUser[post.userId] = (postsPerUser[post.userId] ?? 0) + 1;
    }

    final wordFreq = <String, int>{};
    for (final post in posts) {
      final words = post.title
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z\s]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty && !_stopWords.contains(w));
      for (final word in words) {
        wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      }
    }

    final topWords = Map.fromEntries(
      (wordFreq.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(5),
    );

    return PostStatsEntity(
      totalPosts: totalPosts,
      totalAuthors: totalAuthors,
      avgWordsPerPost: avgWordsPerPost,
      longestPost: longestPost,
      postsPerUser: postsPerUser,
      topWords: topWords,
    );
  }
}
