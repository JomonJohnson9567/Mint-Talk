import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CallSummaryState extends Equatable {
  final bool isHost;
  final String title;
  final String motivationMessage;
  final String durationText;
  final int billedMinutes;
  final int pointsValue;
  final String pointsLabel;
  final String talkLevel;
  final Color talkLevelColor;
  final bool isLoading;
  final String? errorMessage;

  const CallSummaryState({
    required this.isHost,
    required this.title,
    required this.motivationMessage,
    required this.durationText,
    required this.billedMinutes,
    required this.pointsValue,
    required this.pointsLabel,
    required this.talkLevel,
    required this.talkLevelColor,
    this.isLoading = false,
    this.errorMessage,
  });

  factory CallSummaryState.loading({required bool isHost}) {
    return CallSummaryState(
      isHost: isHost,
      title: '',
      motivationMessage: '',
      durationText: '',
      billedMinutes: 0,
      pointsValue: 0,
      pointsLabel: '',
      talkLevel: '',
      talkLevelColor: Colors.grey,
      isLoading: true,
    );
  }

  factory CallSummaryState.error({required bool isHost, required String errorMessage}) {
    return CallSummaryState(
      isHost: isHost,
      title: 'Failed to load details',
      motivationMessage: errorMessage,
      durationText: '',
      billedMinutes: 0,
      pointsValue: 0,
      pointsLabel: '',
      talkLevel: '',
      talkLevelColor: Colors.grey,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  CallSummaryState copyWith({
    bool? isHost,
    String? title,
    String? motivationMessage,
    String? durationText,
    int? billedMinutes,
    int? pointsValue,
    String? pointsLabel,
    String? talkLevel,
    Color? talkLevelColor,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CallSummaryState(
      isHost: isHost ?? this.isHost,
      title: title ?? this.title,
      motivationMessage: motivationMessage ?? this.motivationMessage,
      durationText: durationText ?? this.durationText,
      billedMinutes: billedMinutes ?? this.billedMinutes,
      pointsValue: pointsValue ?? this.pointsValue,
      pointsLabel: pointsLabel ?? this.pointsLabel,
      talkLevel: talkLevel ?? this.talkLevel,
      talkLevelColor: talkLevelColor ?? this.talkLevelColor,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isHost,
        title,
        motivationMessage,
        durationText,
        billedMinutes,
        pointsValue,
        pointsLabel,
        talkLevel,
        talkLevelColor,
        isLoading,
        errorMessage,
      ];
}
