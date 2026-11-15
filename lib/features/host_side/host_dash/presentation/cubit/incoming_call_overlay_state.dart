import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';

/// Sent to the ringing screen that is already up — from the incoming-call
/// notification's Answer / Decline.
enum IncomingCallCommand { accept, decline }

class IncomingCallOverlayState extends Equatable {
  /// The call whose ringing screen should be (or is) on screen; null before
  /// the first call.
  final IncomingCallPayloadDto? payload;

  /// Bumped each time a new ringing screen should be shown — a counter, so
  /// the listener reacts exactly once per call.
  final int showRequest;

  /// The new ringing screen should accept at once: the host already tapped
  /// Answer on the notification.
  final bool autoAccept;

  /// The latest command for the ringing screen already up; read together
  /// with [commandRequest].
  final IncomingCallCommand? command;

  /// Bumped for every [command], so a repeat is still a new state.
  final int commandRequest;

  const IncomingCallOverlayState({
    this.payload,
    this.showRequest = 0,
    this.autoAccept = false,
    this.command,
    this.commandRequest = 0,
  });

  @override
  List<Object?> get props => [
    payload,
    showRequest,
    autoAccept,
    command,
    commandRequest,
  ];
}
