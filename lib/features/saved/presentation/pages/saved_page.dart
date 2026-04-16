import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/postly_app_bar.dart';
import '../../../../features/posts/domain/entities/post_entity.dart';
import '../bloc/saved_bloc.dart';
import '../bloc/saved_event.dart';
import '../bloc/saved_state.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PostlyAppBar(title: 'Postly'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Saved',
              style: GoogleFonts.calistoga(
                fontSize: 72,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SavedBloc, SavedState>(
              builder: (context, state) {
                if (state is SavedError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  );
                }
                if (state is SavedLoaded && state.posts.isEmpty) {
                  return const _EmptyState();
                }
                if (state is SavedLoaded) {
                  return _SavedList(posts: state.posts);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 48,
            color: AppColors.iconMuted,
          ),
          SizedBox(height: 12),
          Text(
            'Nothing saved yet',
            style: TextStyle(fontSize: 15, color: AppColors.textLight),
          ),
          Text(
            'Tap the bookmark on any post',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _SavedList extends StatelessWidget {
  final List<PostEntity> posts;

  const _SavedList({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SavedPostTile(post: post),
        );
      },
    );
  }
}

class _SavedPostTile extends StatelessWidget {
  final PostEntity post;

  const _SavedPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceBlue,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => AppNavigator.toPostDetail(context, post),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${post.id.toString().padLeft(3, '0')}'.toUpperCase(),
                    style: AppTextStyles.postMeta,
                  ),
                  const Spacer(),
                  Text(
                    'userId: ${post.userId}',
                    style: AppTextStyles.postMeta,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.postCardTitle,
              ),
              const SizedBox(height: 6),
              Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.postBodyPreview,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.bookmark_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      context.read<SavedBloc>().add(RemovePost(post.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
