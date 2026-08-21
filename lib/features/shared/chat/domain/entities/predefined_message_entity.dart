import 'package:equatable/equatable.dart';

class PredefinedMessageEntity extends Equatable {
  final String id;
  final String text;
  final String targetRole;
  final String category;
  final int order;
  final bool isActive;

  const PredefinedMessageEntity({
    required this.id,
    required this.text,
    required this.targetRole,
    required this.category,
    required this.order,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, text, targetRole, category, order, isActive];
}
