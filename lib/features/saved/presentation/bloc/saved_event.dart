import 'package:equatable/equatable.dart';
import '../../../posts/domain/entities/post_entity.dart';

abstract class SavedEvent extends Equatable {
  const SavedEvent();

  @override
  List<Object?> get props => [];
}

class LoadSaved extends SavedEvent {
  const LoadSaved();
}

class SavePost extends SavedEvent {
  final PostEntity post;

  const SavePost(this.post);

  @override
  List<Object?> get props => [post];
}

class RemovePost extends SavedEvent {
  final int id;

  const RemovePost(this.id);

  @override
  List<Object?> get props => [id];
}
