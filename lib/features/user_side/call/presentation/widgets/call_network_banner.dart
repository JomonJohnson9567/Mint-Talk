import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

/// Weak-network banner. Isolated in its own narrowly-scoped BlocBuilder
/// (buildWhen only on networkStatus) so it never triggers a rebuild of the
/// video surfaces around it.
class CallNetworkBanner extends StatelessWidget {
  const CallNetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallScreenCubit, CallScreenState>(
      buildWhen: (previous, current) =>
          previous.networkStatus != current.networkStatus ||
          previous.status != current.status,
      builder: (context, netState) {
        if (netState.isCallEnded || !netState.networkStatus.hasNetworkIssue) {
          return const SizedBox.shrink();
        }
        final message = netState.networkStatus.isLocalDeviceOffline
            ? "You're offline"
            : netState.networkStatus.isRemoteReconnecting
            ? 'Other participant reconnecting…'
            : 'Weak connection';
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
