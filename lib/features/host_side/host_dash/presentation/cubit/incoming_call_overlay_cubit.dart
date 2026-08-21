import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';

/// Listens for incoming-call socket events for the whole time the host
/// nav shell is mounted and surfaces each one as a state emission (the
/// widget reacts via `BlocListener` to show the full-screen dialog).
/// Guards against showing a second overlay while one is already up.
class IncomingCallOverlayCubit extends Cubit<IncomingCallPayloadDto?> {
  StreamSubscription<Map<String, dynamic>>? _incomingCallSub;
  bool _isOverlayShowing = false;

  IncomingCallOverlayCubit({required IPresenceSocketService presenceSocketService}) : super(null) {
    _incomingCallSub = presenceSocketService.incomingCalls.listen((data) {
      if (_isOverlayShowing || isClosed) return;
      final payload = IncomingCallPayloadDto.fromJson(data);
      if (payload.callId.isNotEmpty) {
        _isOverlayShowing = true;
        emit(payload);
      }
    });
  }

  /// Called by the widget once the incoming-call dialog is dismissed
  /// (accepted, rejected, or auto-dismissed), so the next incoming call
  /// can show its own overlay.
  void dialogDismissed() {
    _isOverlayShowing = false;
  }

  @override
  Future<void> close() {
    _incomingCallSub?.cancel();
    return super.close();
  }
}
