import 'package:equatable/equatable.dart';
import '../../../posts/domain/entities/post_entity.dart';

abstract class SavedState extends Equatable {
  const SavedState();

  @override
  List<Object?> get props => [];
}

class SavedInitial extends SavedState {
  const SavedInitial();
}

class SavedLoaded extends SavedState {
  final List<PostEntity> posts;

  const SavedLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class SavedError extends SavedState {
  final String message;

  const SavedError(this.message);

  @override
  List<Object?> get props => [message];
}
