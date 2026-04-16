import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/postly_app_bar.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../domain/entities/post_stats_entity.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StatsBloc>()..add(const LoadStats()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PostlyAppBar(title: 'Statistics'),
      body: BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) {
            if (state is StatsInitial || state is StatsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is StatsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.textLight),
                ),
              );
            }
            if (state is StatsLoaded) {
              return _StatsContent(stats: state.stats);
            }
            return const SizedBox.shrink();
          },
        ),
      );
  }
}

class _StatsContent extends StatelessWidget {
  final PostStatsEntity stats;

  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'Overview',
              style: GoogleFonts.calistoga(
                fontSize: 68,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: stats.totalPosts.toString(),
                  label: 'Posts',
                  subtitle:
                      '~${(stats.totalPosts / stats.totalAuthors).toStringAsFixed(1)} per author',
                  background: AppColors.surfaceBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: stats.totalAuthors.toString(),
                  label: 'Authors',
                  subtitle:
                      'top: ${stats.postsPerUser.values.fold(0, (a, b) => a > b ? a : b)} posts',
                  background: AppColors.surfaceLavender,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: stats.avgWordsPerPost.toString(),
                  label: 'Avg Words',
                  subtitle:
                      '~${(stats.avgWordsPerPost / 200).ceil()} min read',
                  background: AppColors.surfaceGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Posts per Author', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: _PostsPerAuthorChart(postsPerUser: stats.postsPerUser),
          ),
          const SizedBox(height: 20),
          const Text('Trending Words', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.topWords.entries
                .map(
                  (entry) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.chipBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${entry.key}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text('Longest Post', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          _LongestPostCard(post: stats.longestPost),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String subtitle;
  final Color background;

  const _StatCard({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostsPerAuthorChart extends StatelessWidget {
  final Map<int, int> postsPerUser;

  const _PostsPerAuthorChart({required this.postsPerUser});

  @override
  Widget build(BuildContext context) {
    const barColors = [AppColors.chartBar1, AppColors.chartBar2];

    final entries = postsPerUser.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final barGroups = entries.asMap().entries.map((e) {
      final colorIndex = e.key;
      final entry = e.value;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: barColors[colorIndex % 2],
            width: 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.borderLight,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 28,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _LongestPostCard extends StatelessWidget {
  final PostEntity post;

  const _LongestPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppNavigator.toPostDetail(context, post),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${post.id}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMid,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${post.wordCount} words',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
