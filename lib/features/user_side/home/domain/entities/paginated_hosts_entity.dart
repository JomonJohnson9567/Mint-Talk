import 'package:equatable/equatable.dart';
import 'host_entity.dart';

class PaginatedHostsEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<HostEntity> items;

  const PaginatedHostsEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages, items];
}
