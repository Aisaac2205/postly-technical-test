import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/post_entity.dart';
import '../../../../features/saved/presentation/bloc/saved_bloc.dart';
import '../../../../features/saved/presentation/bloc/saved_event.dart';
import '../../../../features/saved/presentation/bloc/saved_state.dart';

class PostTile extends StatelessWidget {
  final PostEntity post;
  final int index;

  const PostTile({super.key, required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        index.isEven ? AppColors.surfaceLavender : AppColors.surfaceGreen;

    return Material(
      color: bgColor,
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
                  BlocBuilder<SavedBloc, SavedState>(
                    builder: (context, state) {
                      final isSaved = state is SavedLoaded &&
                          state.posts.any((p) => p.id == post.id);
                      return GestureDetector(
                        onTap: () {
                          if (isSaved) {
                            context
                                .read<SavedBloc>()
                                .add(RemovePost(post.id));
                          } else {
                            context
                                .read<SavedBloc>()
                                .add(SavePost(post));
                          }
                        },
                        child: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 18,
                          color: isSaved
                              ? AppColors.primary
                              : AppColors.textLight,
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
