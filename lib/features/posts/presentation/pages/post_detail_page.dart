import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/post_entity.dart';
import '../../../saved/presentation/bloc/saved_bloc.dart';
import '../../../saved/presentation/bloc/saved_event.dart';
import '../../../saved/presentation/bloc/saved_state.dart';

class PostDetailPage extends StatelessWidget {
  final PostEntity post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          BlocBuilder<SavedBloc, SavedState>(
            builder: (context, state) {
              final isSaved = state is SavedLoaded &&
                  state.posts.any((p) => p.id == post.id);
              return IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.primary : AppColors.textLight,
                ),
                onPressed: () {
                  if (isSaved) {
                    context.read<SavedBloc>().add(RemovePost(post.id));
                  } else {
                    context.read<SavedBloc>().add(SavePost(post));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLavender,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#${post.id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              post.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderLight, thickness: 1),
            const SizedBox(height: 16),
            Text(
              post.body,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMid,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'User #${post.userId}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
