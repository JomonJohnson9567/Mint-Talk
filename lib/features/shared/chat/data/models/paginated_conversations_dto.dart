import '../../domain/entities/paginated_conversations_entity.dart';
import 'conversation_dto.dart';

class PaginatedConversationsDto {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<ConversationDto> items;

  const PaginatedConversationsDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  factory PaginatedConversationsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final rawList = (data['conversations'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ConversationDto.fromJson)
        .toList();

    return PaginatedConversationsDto(
      page: data['page'] as int? ?? 1,
      limit: data['limit'] as int? ?? rawList.length,
      total: data['total'] as int? ?? rawList.length,
      totalPages: data['totalPages'] as int? ?? 1,
      items: rawList,
    );
  }

  PaginatedConversationsEntity toEntity() {
    return PaginatedConversationsEntity(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      items: items.map((c) => c.toEntity()).toList(),
    );
  }
}
