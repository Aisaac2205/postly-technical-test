import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  int get wordCount => body.trim().split(RegExp(r'\s+')).length;

  @override
  List<Object?> get props => [id, userId, title, body];
}
