import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'features/saved/data/local/saved_post_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SavedPostModelAdapter());
  await Hive.openBox<SavedPostModel>('saved_posts');
  await configureDependencies();
  runApp(const App());
}
