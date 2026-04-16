import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/postly_app_bar.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/loading_widget.dart';
import '../widgets/post_error_widget.dart';
import '../widgets/post_tile.dart';

class PostsListPage extends StatelessWidget {
  const PostsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PostsListView();
  }
}

class _PostsListView extends StatelessWidget {
  const _PostsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PostlyAppBar(title: 'Postly'),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          if (state is PostsLoading || state is PostsInitial) {
            return const LoadingWidget();
          }

          if (state is PostsFailure) {
            return PostErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<PostsBloc>().add(const GetPostsEvent()),
            );
          }

          if (state is PostsSuccess) {
            // items: 1 heading + N posts + 1 footer
            final itemCount = state.posts.length + 2;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Text(
                          'Feed',
                          style: GoogleFonts.calistoga(
                            fontSize: 72,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderSubtle,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                if (index == state.posts.length + 1) {
                  return _PostsFooter(
                    isLoadingMore: state.isLoadingMore,
                    hasReachedMax: state.hasReachedMax,
                    onLoadMore: () =>
                        context.read<PostsBloc>().add(const PostsLoadMore()),
                  );
                }

                final postIndex = index - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostTile(
                    post: state.posts[postIndex],
                    index: postIndex,
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

}

class _PostsFooter extends StatelessWidget {
  const _PostsFooter({
    required this.isLoadingMore,
    required this.hasReachedMax,
    required this.onLoadMore,
  });

  final bool isLoadingMore;
  final bool hasReachedMax;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (hasReachedMax) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "You're all caught up ✓",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return Center(
      child: TextButton(
        onPressed: onLoadMore,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Load more'),
      ),
    );
  }
}
