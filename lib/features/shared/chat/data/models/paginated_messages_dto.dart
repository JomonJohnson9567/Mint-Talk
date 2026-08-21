import '../../domain/entities/paginated_messages_entity.dart';
import 'message_dto.dart';

class PaginatedMessagesDto {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<MessageDto> items;

  const PaginatedMessagesDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  factory PaginatedMessagesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final rawList = (data['messages'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MessageDto.fromJson)
        .toList();

    return PaginatedMessagesDto(
      page: data['page'] as int? ?? 1,
      limit: data['limit'] as int? ?? rawList.length,
      total: data['total'] as int? ?? rawList.length,
      totalPages: data['totalPages'] as int? ?? 1,
      items: rawList,
    );
  }

  PaginatedMessagesEntity toEntity() {
    return PaginatedMessagesEntity(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      items: items.map((m) => m.toEntity()).toList(),
    );
  }
}
