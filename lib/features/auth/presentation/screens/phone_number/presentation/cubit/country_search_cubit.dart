import 'package:bloc/bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:equatable/equatable.dart';

part 'country_search_state.dart';

class CountrySearchCubit extends Cubit<CountrySearchState> {
  CountrySearchCubit() : super(const CountrySearchState());

  void loadCountries() {
    final List<Country> countries = CountryService().getAll();
    emit(state.copyWith(allCountries: countries, filteredCountries: countries));
  }

  void search(String query) {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchQuery: query,
          filteredCountries: state.allCountries,
        ),
      );
    } else {
      final filtered = state.allCountries.where((country) {
        final matchesName = country.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        final matchesCode = country.countryCode.toLowerCase().contains(
          query.toLowerCase(),
        );
        final matchesPhone = country.phoneCode.contains(query);
        return matchesName || matchesCode || matchesPhone;
      }).toList();
      emit(state.copyWith(searchQuery: query, filteredCountries: filtered));
    }
  }
}
