import 'package:flutter/material.dart';

class RouteConfig {
  const RouteConfig({
    required this.builder,
    this.useMorphing = false,
    this.guard,
    this.guardRedirect,
  });

  final Widget Function(RouteSettings settings) builder;

  final bool useMorphing;

 final bool Function()? guard;

 final String? guardRedirect;
}

 
class RouteArgs {
  static T? of<T>(RouteSettings settings) {
    final args = settings.arguments;
    return args is T ? args : null;
  }

  static T require<T>(RouteSettings settings) {
    final args = settings.arguments;
    if (args is T) return args;
    throw ArgumentError(
      'Route "${settings.name}" expected argument of type $T, '
      'but got ${args.runtimeType}.',
    );
  }
}
