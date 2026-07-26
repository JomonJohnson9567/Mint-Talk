import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import '../cubit/host_application_status_cubit.dart';
import '../cubit/host_application_status_state.dart';
import '../widgets/host_application_details_card.dart';
import '../widgets/host_application_status_skeleton.dart';
import '../widgets/host_status_card.dart';

class HostApplicationStatus extends StatelessWidget {
  const HostApplicationStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlue,
      appBar: CustomAppBar(
        title: 'Application Status',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Terms & Conditions',
            icon: Icon(
              Icons.description_rounded,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.termsAndConditionsForHost,
                arguments: true,
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child:
            BlocBuilder<HostApplicationStatusCubit, HostApplicationStatusState>(
              builder: (context, state) {
                switch (state.view) {
                  case HostApplicationStatusView.initial:
                  case HostApplicationStatusView.loading:
                    return const HostApplicationStatusSkeleton();
                  case HostApplicationStatusView.failure:
                    return _StatusError(message: state.errorMessage);
                  case HostApplicationStatusView.loaded:
                    final application = state.application;
                    if (application == null) {
                      return const _StatusError(
                        message: 'Application details are unavailable.',
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primaryColor,
                      onRefresh: context
                          .read<HostApplicationStatusCubit>()
                          .loadStatus,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                        children: [
                          HostStatusCard(status: application.status),
                          SizedBox(height: 20.h),
                          HostApplicationDetailsCard(application: application),
                          if (application.rejectionReason?.trim().isNotEmpty ==
                              true) ...[
                            SizedBox(height: 20.h),
                            _RejectionReason(
                              reason: application.rejectionReason!,
                            ),
                          ],
                          SizedBox(height: 20.h),
                          const _ReviewNote(),
                        ],
                      ),
                    );
                }
              },
            ),
      ),
    );
  }
}

class _StatusError extends StatelessWidget {
  final String? message;

  const _StatusError({this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(28.r),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 64.sp,
            color: AppColors.subtitleText,
          ),
          SizedBox(height: 18.h),
          Text(
            'Couldn’t load status',
            style: GoogleFonts.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message ?? 'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: 180.w,
            child: PrimaryButton(
              text: 'Try Again',
              onPressed: context.read<HostApplicationStatusCubit>().loadStatus,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RejectionReason extends StatelessWidget {
  final String reason;
  const _RejectionReason({required this.reason});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(18.r),
    decoration: BoxDecoration(
      color: AppColors.callBackground,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: AppColors.red.withAlpha(45)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: AppColors.red, size: 22.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reason',
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                reason,
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReviewNote extends StatelessWidget {
  const _ReviewNote();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primaryColor,
        size: 20.sp,
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Text(
          'Pull down to refresh. You’ll see the latest review and KYC status here.',
          style: GoogleFonts.manrope(
            fontSize: 12.sp,
            height: 1.5,
            color: AppColors.subtitleText,
          ),
        ),
      ),
    ],
  );
}
