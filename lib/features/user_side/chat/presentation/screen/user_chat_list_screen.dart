import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/conversations_cubit.dart';
import 'package:mint_talk/features/user_side/chat/presentation/widgets/user_chat_list_contents.dart';

class UserChatListScreen extends StatelessWidget {
  const UserChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationsCubit>()..loadConversations(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(
          title: AppTexts.conversations,
          automaticallyImplyLeading: true,
        ),
        body: const UserChatListContents(),
      ),
    );
  }
}
