part of 'country_search_cubit.dart';

class CountrySearchState extends Equatable {
  final List<Country> allCountries;
  final List<Country> filteredCountries;
  final String searchQuery;

  const CountrySearchState({
    this.allCountries = const [],
    this.filteredCountries = const [],
    this.searchQuery = '',
  });

  CountrySearchState copyWith({
    List<Country>? allCountries,
    List<Country>? filteredCountries,
    String? searchQuery,
  }) {
    return CountrySearchState(
      allCountries: allCountries ?? this.allCountries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [allCountries, filteredCountries, searchQuery];
}
