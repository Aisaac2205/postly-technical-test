import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_post_stats_usecase.dart';
import '../../../posts/domain/usecases/get_posts_usecase.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetPostsUseCase _getPosts;
  final GetPostStatsUseCase _getPostStats;

  StatsBloc({
    required GetPostsUseCase getPostsUseCase,
    required GetPostStatsUseCase getPostStatsUseCase,
  })  : _getPosts = getPostsUseCase,
        _getPostStats = getPostStatsUseCase,
        super(const StatsInitial()) {
    on<LoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());
    final result = await _getPosts();
    result.fold(
      (failure) => emit(StatsError(failure.message)),
      (posts) {
        if (posts.isEmpty) {
          emit(const StatsError('No posts available'));
          return;
        }
        emit(StatsLoaded(_getPostStats(posts)));
      },
    );
  }
}
