part of 'country_selector_cubit.dart';

class CountrySelectorState extends Equatable {
  final Country country;

  const CountrySelectorState({required this.country});

  @override
  List<Object> get props => [country];
}
