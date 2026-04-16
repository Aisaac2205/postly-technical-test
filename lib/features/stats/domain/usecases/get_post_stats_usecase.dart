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

    // Normalize list to domain entities to avoid runtime generic mismatches
    // when an upstream layer accidentally passes List<PostModel>.
    final normalizedPosts = posts
        .map(
          (p) => PostEntity(
            id: p.id,
            userId: p.userId,
            title: p.title,
            body: p.body,
          ),
        )
        .toList(growable: false);

    final totalPosts = normalizedPosts.length;

    final totalAuthors = normalizedPosts.map((p) => p.userId).toSet().length;

    final totalWords = normalizedPosts.fold<int>(
      0,
      (sum, p) => sum + p.body.split(RegExp(r'\s+')).length,
    );
    final avgWordsPerPost = totalWords ~/ totalPosts;

    final longestPost = normalizedPosts.reduce(
      (a, b) => a.body.length >= b.body.length ? a : b,
    );

    final postsPerUser = <int, int>{};
    for (final post in normalizedPosts) {
      postsPerUser[post.userId] = (postsPerUser[post.userId] ?? 0) + 1;
    }

    final wordFreq = <String, int>{};
    for (final post in normalizedPosts) {
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
