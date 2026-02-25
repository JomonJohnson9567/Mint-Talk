part of 'call_screen_cubit.dart';

@immutable
sealed class CallScreenState {}

final class CallOngoing extends CallScreenState {}

final class CallEnded extends CallScreenState {}
