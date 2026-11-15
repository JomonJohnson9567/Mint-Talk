import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/call_type_selection_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/widgets/recharge_wallet_prompt.dart';

/// Minimum points needed to start a call: one second at the default
/// per-second rate (video 60 pts/sec, audio 30 pts/sec). The backend stays
/// the source of truth — it rejects POST /calls/initiate with HTTP 400 below
/// its own threshold, which [CallScreenCubit] also routes to the recharge
/// prompt — this only avoids opening the call screen when the answer is
/// already known locally.
int minimumPointsToStartCall(CallType callType) => callType.isVideo ? 60 : 30;

/// Returns true when the caller may proceed with a [callType] call. Shows
/// the Recharge Wallet prompt and returns false when the loaded balance is
/// below [minimumPointsToStartCall]. A balance that isn't freshly loaded is
/// never trusted to block the call — the server-side check covers it.
bool ensureBalanceForCall(BuildContext context, CallType callType) {
  final wallet = context.read<WalletCubit>().state;
  if (wallet.status != WalletStatus.loaded) return true;

  final required = minimumPointsToStartCall(callType);
  if (wallet.balance >= required) return true;

  showRechargeWalletPrompt(
    context,
    message:
        'You need at least $required points to start a ${callType.name} call. '
        'Your balance is ${wallet.balance} points.',
  );
  return false;
}

/// Opens [CallScreen] for an outgoing call to [host], after the pre-call
/// balance guard passes.
void launchOutgoingCall(
  BuildContext context, {
  required HostEntity host,
  required CallType callType,
}) {
  if (!ensureBalanceForCall(context, callType)) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CallScreen(
        hostId: host.id,
        hostName: host.fullName,
        hostAvatar: host.avatarUrl,
        callType: callType,
        isHostFavorite: host.isFavorite,
        host: host,
      ),
    ),
  );
}

/// Whether [host] offers both call types, so a call needs the type picker.
bool hostOffersBothCallTypes(HostEntity host) =>
    (host.presence?.audioAvailable ?? true) &&
    (host.presence?.videoAvailable ?? true);

/// Resolves which call type to place with [host] and hands it to [onCall]:
/// both types available opens [CallTypeSelectionBottomSheet], a single one
/// is used straight away, and none shows a "not accepting calls" snackbar.
/// Shared by the host cards, the host profile and the post-call "Call
/// again" button so they all decide the same way.
void pickCallTypeThen(
  BuildContext context,
  HostEntity host,
  void Function(CallType callType) onCall,
) {
  final isAudioAvailable = host.presence?.audioAvailable ?? true;
  final isVideoAvailable = host.presence?.videoAvailable ?? true;

  if (isAudioAvailable && isVideoAvailable) {
    CallTypeSelectionBottomSheet.show(context, host, onSelected: onCall);
  } else if (isVideoAvailable) {
    onCall(CallType.video);
  } else if (isAudioAvailable) {
    onCall(CallType.audio);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${host.fullName} is currently not accepting calls.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
