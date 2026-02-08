import 'package:bloc/bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:equatable/equatable.dart';
part 'country_selector_state.dart';

class CountrySelectorCubit extends Cubit<CountrySelectorState> {
  CountrySelectorCubit()
    : super(CountrySelectorState(country: Country.parse('IN')));

  void updateCountry(Country country) {
    emit(CountrySelectorState(country: country));
  }
}
