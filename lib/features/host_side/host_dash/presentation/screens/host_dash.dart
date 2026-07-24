import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../widgets/host_dash_contents.dart';

class HostDashScreen extends StatelessWidget {
  const HostDashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const HostDashContents(),
    );
  }
}
