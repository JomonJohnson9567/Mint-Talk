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
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final List itemsList = data['items'] is List ? data['items'] as List : [];

    return PaginatedHostsDto(
      page: data['page'] is int ? data['page'] : 1,
      limit: data['limit'] is int ? data['limit'] : 20,
      total: data['total'] is int ? data['total'] : itemsList.length,
      totalPages: data['totalPages'] is int ? data['totalPages'] : 1,
      items: itemsList
          .map((item) => HostDto.fromJson(item as Map<String, dynamic>))
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
