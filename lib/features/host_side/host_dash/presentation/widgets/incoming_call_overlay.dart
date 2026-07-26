import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/accept_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/reject_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';

class IncomingCallOverlayListener extends StatefulWidget {
  final Widget child;

  const IncomingCallOverlayListener({super.key, required this.child});

  @override
  State<IncomingCallOverlayListener> createState() =>
      _IncomingCallOverlayListenerState();
}

class _IncomingCallOverlayListenerState
    extends State<IncomingCallOverlayListener> {
  StreamSubscription<Map<String, dynamic>>? _incomingCallSub;
  bool _isOverlayShowing = false;

  @override
  void initState() {
    super.initState();
    _listenForIncomingCalls();
  }

  void _listenForIncomingCalls() {
    final socketService = getIt<IPresenceSocketService>();
    _incomingCallSub = socketService.incomingCalls.listen((data) {
      if (_isOverlayShowing || !mounted) return;
      final payload = IncomingCallPayloadDto.fromJson(data);
      if (payload.callId.isNotEmpty) {
        _showIncomingCallDialog(payload);
      }
    });
  }

  void _showIncomingCallDialog(IncomingCallPayloadDto payload) {
    _isOverlayShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (dialogContext) {
        return _IncomingCallFullScreenModal(
          payload: payload,
          onDismiss: () {
            _isOverlayShowing = false;
          },
        );
      },
    ).then((_) {
      _isOverlayShowing = false;
    });
  }

  @override
  void dispose() {
    _incomingCallSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _IncomingCallFullScreenModal extends StatefulWidget {
  final IncomingCallPayloadDto payload;
  final VoidCallback onDismiss;

  const _IncomingCallFullScreenModal({
    required this.payload,
    required this.onDismiss,
  });

  @override
  State<_IncomingCallFullScreenModal> createState() =>
      __IncomingCallFullScreenModalState();
}

class __IncomingCallFullScreenModalState
    extends State<_IncomingCallFullScreenModal> {
  bool _isProcessing = false;
  StreamSubscription<Map<String, dynamic>>? _statusSub;

  @override
  void initState() {
    super.initState();
    _listenForStatusUpdates();
  }

  void _listenForStatusUpdates() {
    final socketService = getIt<IPresenceSocketService>();
    socketService.subscribeCall(widget.payload.callId);
    _statusSub = socketService.callStatusUpdates.listen((data) {
      final status = data['status']?.toString();
      if (status == 'missed' ||
          status == 'ended' ||
          status == 'rejected' ||
          status == 'cancelled') {
        if (!mounted || _isProcessing) return;
        _isProcessing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onDismiss();
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) {
            navigator.pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    getIt<IPresenceSocketService>().unsubscribeCall(widget.payload.callId);
    super.dispose();
  }

  Future<void> _handleAccept() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final acceptUseCase = getIt<AcceptCallUseCase>();
    final result = await acceptUseCase(widget.payload.callId);

    if (!mounted) return;
    widget.onDismiss();
    Navigator.of(context, rootNavigator: true).pop();

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call unavailable: ${failure.message}')),
        );
      },
      (callSession) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CallScreen(
              callSession: callSession,
              isHost: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleReject() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final rejectUseCase = getIt<RejectCallUseCase>();
    await rejectUseCase(widget.payload.callId);

    if (!mounted) return;
    widget.onDismiss();
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.payload.callType.toLowerCase() == 'video';

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Text(
                'INCOMING ${isVideo ? "VIDEO" : "AUDIO"} CALL',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 30.h),
              CircleAvatar(
                radius: 60.r,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  size: 60.r,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                widget.payload.callerName.isNotEmpty
                    ? widget.payload.callerName
                    : 'Incoming Caller',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Ringing...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16.sp,
                ),
              ),
              const Spacer(),
              if (_isProcessing)
                const CircularProgressIndicator(color: AppColors.primaryColor)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline Button
                    GestureDetector(
                      onTap: _handleReject,
                      child: Column(
                        children: [
                          Container(
                            width: 72.w,
                            height: 72.h,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Decline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Accept Button
                    GestureDetector(
                      onTap: _handleAccept,
                      child: Column(
                        children: [
                          Container(
                            width: 72.w,
                            height: 72.h,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isVideo ? Icons.videocam : Icons.call,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
