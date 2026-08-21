import 'package:equatable/equatable.dart';
import 'conversation_entity.dart';

class PaginatedConversationsEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<ConversationEntity> items;

  const PaginatedConversationsEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages, items];
}
