import 'package:hive/hive.dart';
import '../../../posts/domain/entities/post_entity.dart';

part 'saved_post_model.g.dart';

@HiveType(typeId: 1)
class SavedPostModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String body;

  SavedPostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory SavedPostModel.fromEntity(PostEntity entity) => SavedPostModel(
        id: entity.id,
        userId: entity.userId,
        title: entity.title,
        body: entity.body,
      );

  PostEntity toEntity() => PostEntity(
        id: id,
        userId: userId,
        title: title,
        body: body,
      );
}
