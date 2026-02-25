// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../../core/theme/color.dart';

class CallControls extends StatelessWidget {
  final VoidCallback onEndCall;

  const CallControls({super.key, required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(icon: Icons.cameraswitch_outlined, onTap: () {}),
          _buildActionButton(icon: Icons.videocam_outlined, onTap: () {}),
          _buildCallButton(onTap: onEndCall),
          _buildActionButton(icon: Icons.mic_off_outlined, onTap: () {}),
          _buildActionButton(icon: Icons.more_horiz, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(128),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.black.withAlpha(179), size: 24),
      ),
    );
  }

  Widget _buildCallButton({required VoidCallback onTap}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withAlpha(102),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.call_end, color: AppColors.white, size: 32),
      ),
    );
  }
}
