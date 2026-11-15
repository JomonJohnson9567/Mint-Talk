import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color tealBackground = Color(0xFF4FB6AD);
  static const Color primaryColor = Color(0xFF6E2756);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color softBlue = Color(0xFFF4F6FF);
  static const Color softMint = Color(0xFFEAF8F4);
  static const Color borderSoft = Color(0xFFE7EBF3);
  static const Color ratingGold = Color(0xFFFFC857);
  static const Color onlineIndicator = Color(0xFF18A957);
  static const Color subtitleText = Color(0xFF6E7787);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color green = Colors.green;
  static const Color textGrey = Colors.grey;
  static const Color favIcon = Color(0xFFE53935);
  static const Color chatIcon = Color(0xFF1E88E5);
  static const Color blockedIcon = Color(0xFF546E7A);
  static const Color termsIcon = Color(0xFFFFB300);
  static const Color contactIcon = Color(0xFF43A047);
  static const Color profileIcon = Color(0xFFFFB74D);
  static const Color red = Colors.red;
  static const Color actionBlue = Color(0xFF1E88E5);
  static const Color aboutIcon = Color(0xFF2196F3);
  static const Color onCall = Color(0xFFFFB74D);
  static const Color callBackground = Color(0xFFFFEBEB);
  static const Color callStatusText = Color(0xFF16884F);
  static const Color callEndedStatus = Color(0xFFE53935);
  static const Color callBreathingGlow = Color(0xFF20B15A);
  static const Color callBreathingGlowSoft = Color(0xFFC7F6D9);
  static const Color callControlSurface = Color(0xCCFFFFFF);
  static const Color callMutedIcon = Color(0xB3000000);
  static const Color callGlassDark = Color(0xFF2A0C20);
  static const Color callVideoBase = Color(0xFF2A1824);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color transparent = Colors.transparent;
  static const Color orange = Colors.orange;
  static const Color amber = Colors.amber;
  static const Color warningBackground = Color(0xFFFFF8E1);

  // Login screen palette
  static const Color plumDeep = Color(0xFF4A1538);
  static const Color plumMuted = Color(0xFF8C4A72);
  static const Color plumHint = Color(0xFFA08497);
  static const Color creamBackground = Color(0xFFFDF1E8);
  static const Color lavenderBorder = Color(0xFFD8C6EE);
  static const Color cardWhite = Color(0xFFFFFCFA);
  static const Color linkMagenta = Color(0xFFB0306E);

  // User home palette — homeBackground / greetingBanner are sampled from the
  // wordmark and mascot images so their (opaque) edges blend into the page.
  static const Color homeBackground = Color(0xFFFDFEF9);
  static const Color greetingBanner = Color(0xFFFDEBDE);
  static const Color videoCardBg = Color(0xFFEFE6F4);
  static const Color audioCardBg = Color(0xFFFDEBDF);
  static const Color audioAccent = Color(0xFFF26B5B);
  static const Color videoBtnBg = Color(0xFFF1E8F3);
  static const Color audioBtnBg = Color(0xFFFDEBE2);
  static const Color pillUnselected = Color(0xFFF3ECF3);
  // Sampled from the video-call mascot image so its opaque edges blend in.
  static const Color videoCallBanner = Color(0xFFFEF1E6);

  // Recharge plans palette
  static const Color rechargeBackground = Color(0xFFFEF7EF);
  static const Color pricePill = Color(0xFFFEE6DA);
  static const Color popularCardBg = Color(0xFFF8EDF6);
  static const Color balanceCardStart = Color(0xFF5B1840);

  // Recharge tier palette — the selected-card theme of each plan tier
  // (Silver / Gold / Platinum). Platinum is dark on purpose so it reads as a
  // clearly higher tier than the light silver.
  static const Color silverStart = Color(0xFFFAFBFC);
  static const Color silverMid = Color(0xFFE3E7EC);
  static const Color silverEnd = Color(0xFFBCC4CE);
  static const Color silverInk = Color(0xFF2F3742);
  static const Color silverMutedInk = Color(0xFF4E5866);
  static const Color silverAccent = Color(0xFF8E99A8);
  static const Color goldStart = Color(0xFFFFF7DC);
  static const Color goldMid = Color(0xFFF7D774);
  static const Color goldEnd = Color(0xFFD6A23A);
  static const Color goldInk = Color(0xFF4E3505);
  static const Color goldMutedInk = Color(0xFF6B4C0E);
  static const Color goldAccent = Color(0xFFC08A1E);
  static const Color goldCheckInk = Color(0xFFFFE9A8);
  static const Color platinumStart = Color(0xFF3A3F55);
  static const Color platinumMid = Color(0xFF545B78);
  static const Color platinumEnd = Color(0xFF2A2E40);
  static const Color platinumInk = Color(0xFFF4F6FF);
  static const Color platinumMutedInk = Color(0xFFC9D1EC);
  static const Color platinumAccent = Color(0xFFAFC0E8);
  static const Color platinumSheen = Color(0xFFD6E0FF);
  static const Color platinumCheckBg = Color(0xFFE6ECFF);

  // Welcome screen palette
  static const Color welcomeHill = Color(0xFFEDE4F7);

  // Profile screen palette
  static const Color profileDivider = Color(0xFFF1E6EE);

  // Host dash palette — hostGreetingBanner / hostPromoBanner are sampled from
  // the host mascot images so their (opaque) edges blend into the cards.
  static const Color hostGreetingBanner = Color(0xFFFEEEE5);
  static const Color hostPromoBanner = Color(0xFFF3EDFD);
  static const Color hostWaitingCard = Color(0xFFF5EFFD);
  static const Color hostVideoAccent = Color(0xFF9C8BEF);
  static const Color hostVideoTileBg = Color(0xFFF5F2FD);
  static const Color hostVideoIconBg = Color(0xFFEEEBFC);
  static const Color hostAudioTileBg = Color(0xFFFFF6F2);
  static const Color hostAvatarBg = Color(0xFFF9DDE7);
  static const Color hostSubtitle = Color(0xFF7D7894);
  static const Color hostGoOnlineStart = Color(0xFFA6487B);
  // Track behind the host segmented toggle (All/Unread, Request/History).
  static const Color hostToggleTrack = Color(0xFFF1ECFB);

  // Host wallet palette — hostWalletBanner / noWithdrawalsCard are sampled
  // from the wallet mascot images so their (opaque) edges blend into the cards.
  static const Color hostWalletBanner = Color(0xFFFDE8DE);
  static const Color noWithdrawalsCard = Color(0xFFFEFCF6);
  static const Color approvedIconBg = Color(0xFFE6F6EC);
  static const Color pendingIconBg = Color(0xFFFFEFE4);
  static const Color pendingAccent = Color(0xFFF2783C);
}
