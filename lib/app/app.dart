import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/di/injection_container.dart';
import '../core/theme/app_colors.dart';
import '../features/posts/presentation/bloc/posts_bloc.dart';
import '../features/posts/presentation/bloc/posts_event.dart';
import '../features/posts/presentation/pages/main_page.dart';
import '../features/saved/presentation/bloc/saved_bloc.dart';
import '../features/saved/presentation/bloc/saved_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostsBloc>(
          create: (_) => sl<PostsBloc>()..add(const GetPostsEvent()),
        ),
        BlocProvider<SavedBloc>(
          create: (_) => sl<SavedBloc>()..add(const LoadSaved()),
        ),
      ],
      child: MaterialApp(
        title: 'Postly',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const MainPage(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        surface: AppColors.white,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        onSurface: AppColors.textDark,
        onSurfaceVariant: AppColors.textMid,
        outline: AppColors.textLight,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textBlack,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textBlack),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textMid),
          bodySmall: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
    );
  }
}
