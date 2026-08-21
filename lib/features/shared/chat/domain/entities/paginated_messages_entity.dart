import 'package:equatable/equatable.dart';
import 'message_entity.dart';

class PaginatedMessagesEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<MessageEntity> items;

  const PaginatedMessagesEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages, items];
}
