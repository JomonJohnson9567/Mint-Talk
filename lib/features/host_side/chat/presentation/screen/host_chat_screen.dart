import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/get_conversation_messages_usecase.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/get_predefined_messages_usecase.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/mark_conversation_read_usecase.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/mark_messages_delivered_usecase.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/send_message_usecase.dart';
import 'package:mint_talk/features/shared/chat/domain/usecases/watch_new_messages_usecase.dart';
import 'package:mint_talk/features/shared/chat/presentation/cubit/chat_thread_cubit.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/host_side/chat/presentation/widgets/host_chat_contents.dart';

class HostChatArgs {
  final String recipientId;
  final String recipientName;
  final String? recipientAvatarUrl;
  final String? conversationId;

  const HostChatArgs({
    required this.recipientId,
    required this.recipientName,
    this.recipientAvatarUrl,
    this.conversationId,
  });
}

class HostChatScreen extends StatelessWidget {
  final HostChatArgs args;

  const HostChatScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatThreadCubit(
        sendMessageUseCase: getIt<SendMessageUseCase>(),
        getConversationMessagesUseCase: getIt<GetConversationMessagesUseCase>(),
        getPredefinedMessagesUseCase: getIt<GetPredefinedMessagesUseCase>(),
        markConversationReadUseCase: getIt<MarkConversationReadUseCase>(),
        markMessagesDeliveredUseCase: getIt<MarkMessagesDeliveredUseCase>(),
        getConversationsUseCase: getIt<GetConversationsUseCase>(),
        watchNewMessagesUseCase: getIt<WatchNewMessagesUseCase>(),
        authLocalDataSource: getIt<IAuthLocalDataSource>(),
        recipientId: args.recipientId,
        recipientName: args.recipientName,
        recipientAvatarUrl: args.recipientAvatarUrl,
        conversationId: args.conversationId,
      )..init(),
      child: const Scaffold(body: HostChatContents()),
    );
  }
}
