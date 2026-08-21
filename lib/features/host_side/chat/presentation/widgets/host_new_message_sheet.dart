import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/chat/presentation/cubit/new_message_picker_cubit.dart';
import 'package:mint_talk/features/host_side/chat/presentation/cubit/new_message_picker_state.dart';
import 'package:mint_talk/features/host_side/chat/presentation/screen/host_chat_screen.dart';

class HostNewMessageSheet extends StatelessWidget {
  const HostNewMessageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      'New Message',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child:
                    BlocBuilder<NewMessagePickerCubit, NewMessagePickerState>(
                      builder: (context, state) {
                        if (state is NewMessagePickerLoading ||
                            state is NewMessagePickerInitial) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          );
                        }
                        if (state is NewMessagePickerError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        }
                        if (state is NewMessagePickerLoaded) {
                          if (state.contacts.isEmpty) {
                            return Center(
                              child: Text(
                                'No recent contacts yet',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.subtitleText,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            itemCount: state.contacts.length,
                            itemBuilder: (context, index) {
                              final contact = state.contacts[index];
                              return _ContactTile(
                                name: contact.name,
                                avatarUrl: contact.avatarUrl,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HostChatScreen(
                                        args: HostChatArgs(
                                          recipientId: contact.id,
                                          recipientName: contact.name,
                                          recipientAvatarUrl:
                                              contact.avatarUrl,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final VoidCallback onTap;

  const _ContactTile({
    required this.name,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.startsWith('http');
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 22.r,
        backgroundColor: AppColors.primaryColor,
        backgroundImage: hasImage
            ? CachedNetworkImageProvider(avatarUrl)
            : null,
        child: hasImage
            ? null
            : Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.subtitleText,
        size: 20.sp,
      ),
    );
  }
}
