import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/chat/presentation/cubit/new_message_picker_cubit.dart';
import 'package:mint_talk/features/host_side/chat/presentation/widgets/host_chat_list_contents.dart';
import 'package:mint_talk/features/host_side/chat/presentation/widgets/host_new_message_sheet.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/conversations_cubit.dart';

class HostChatListScreen extends StatelessWidget {
  const HostChatListScreen({super.key});

  void _showNewMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<NewMessagePickerCubit>()..load(),
        child: const HostNewMessageSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationsCubit>()..loadConversations(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: CustomAppBar(
              title: AppTexts.conversations,
              automaticallyImplyLeading: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  color: AppColors.primaryColor,
                  onPressed: () => _showNewMessageSheet(context),
                ),
              ],
            ),
            body: const HostChatListContents(),
          );
        },
      ),
    );
  }
}
