import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/posts/domain/entities/post_entity.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';

/// Centralizes navigation so that features never import each other's pages.
/// Only core/navigation knows about concrete page destinations.
class AppNavigator {
  AppNavigator._();

  static void toPostDetail(BuildContext context, PostEntity post) {
    Navigator.of(context).push(fadeSlideRoute(PostDetailPage(post: post)));
  }
}
