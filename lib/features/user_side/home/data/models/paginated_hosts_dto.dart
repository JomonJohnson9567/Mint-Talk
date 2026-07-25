import '../../domain/entities/paginated_hosts_entity.dart';
import 'host_dto.dart';

class PaginatedHostsDto {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<HostDto> items;

  const PaginatedHostsDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  factory PaginatedHostsDto.fromJson(Map<String, dynamic> json) {
    List itemsList = [];
    final rawData = json['data'];

    if (rawData is List) {
      itemsList = rawData;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['items'] is List) {
        itemsList = rawData['items'] as List;
      } else if (rawData['hosts'] is List) {
        itemsList = rawData['hosts'] as List;
      }
    } else if (json['items'] is List) {
      itemsList = json['items'] as List;
    } else if (json['hosts'] is List) {
      itemsList = json['hosts'] as List;
    }

    final int page = (rawData is Map && rawData['page'] is int)
        ? rawData['page']
        : (json['page'] is int ? json['page'] : 1);
    final int limit = (rawData is Map && rawData['limit'] is int)
        ? rawData['limit']
        : (json['limit'] is int ? json['limit'] : 20);
    final int total = (rawData is Map && rawData['total'] is int)
        ? rawData['total']
        : (json['total'] is int ? json['total'] : itemsList.length);
    final int totalPages = (rawData is Map && rawData['totalPages'] is int)
        ? rawData['totalPages']
        : (json['totalPages'] is int ? json['totalPages'] : 1);

    return PaginatedHostsDto(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      items: itemsList
          .whereType<Map<String, dynamic>>()
          .map((item) => HostDto.fromJson(item))
          .toList(),
    );
  }

  PaginatedHostsEntity toEntity() {
    return PaginatedHostsEntity(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}
