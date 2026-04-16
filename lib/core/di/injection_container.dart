import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../network/dio_client.dart';
import '../../features/posts/data/datasources/post_remote_datasource.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/domain/usecases/get_post_by_id_usecase.dart';
import '../../features/stats/domain/usecases/get_post_stats_usecase.dart';
import '../../features/posts/domain/usecases/get_posts_usecase.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/stats/presentation/bloc/stats_bloc.dart';
import '../../features/saved/data/datasources/saved_post_local_datasource.dart';
import '../../features/saved/data/local/saved_post_model.dart';
import '../../features/saved/data/repositories/saved_post_repository_impl.dart';
import '../../features/saved/domain/repositories/saved_post_repository.dart';
import '../../features/saved/domain/usecases/get_saved_posts_usecase.dart';
import '../../features/saved/domain/usecases/is_post_saved_usecase.dart';
import '../../features/saved/domain/usecases/remove_post_usecase.dart';
import '../../features/saved/domain/usecases/save_post_usecase.dart';
import '../../features/saved/presentation/bloc/saved_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Network ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ── Hive ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Box<SavedPostModel>>(
    () => Hive.box<SavedPostModel>('saved_posts'),
  );

  // ── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<SavedPostLocalDatasource>(
    () => SavedPostLocalDatasourceImpl(sl<Box<SavedPostModel>>()),
  );

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(sl<PostRemoteDataSource>()),
  );
  sl.registerLazySingleton<SavedPostRepository>(
    () => SavedPostRepositoryImpl(sl<SavedPostLocalDatasource>()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetPostsUseCase(sl<PostRepository>()));
  sl.registerLazySingleton(() => GetPostByIdUseCase(sl<PostRepository>()));
  sl.registerLazySingleton(() => GetPostStatsUseCase());
  sl.registerLazySingleton(() => GetSavedPostsUseCase(sl<SavedPostRepository>()));
  sl.registerLazySingleton(() => SavePostUseCase(sl<SavedPostRepository>()));
  sl.registerLazySingleton(() => RemovePostUseCase(sl<SavedPostRepository>()));
  sl.registerLazySingleton(() => IsPostSavedUseCase(sl<SavedPostRepository>()));

  // ── BLoC (factory: new instance per BlocProvider) ────────────────────────
  sl.registerFactory(
    () => PostsBloc(getPostsUseCase: sl<GetPostsUseCase>()),
  );
  sl.registerFactory(
    () => StatsBloc(
      getPostsUseCase: sl<GetPostsUseCase>(),
      getPostStatsUseCase: sl<GetPostStatsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => SavedBloc(
      getSavedPostsUseCase: sl<GetSavedPostsUseCase>(),
      savePostUseCase: sl<SavePostUseCase>(),
      removePostUseCase: sl<RemovePostUseCase>(),
    ),
  );
}
