import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/chat/presentation/bloc/user_chat_cubit.dart';
import 'package:mint_talk/features/user_side/chat/presentation/widgets/user_chat_contents.dart';

class UserChatArgs {
  final String hostName;

  const UserChatArgs({required this.hostName});
}

class UserChatScreen extends StatelessWidget {
  final UserChatArgs args;

  const UserChatScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserChatCubit(hostName: args.hostName),
      child: const Scaffold(body: UserChatContents()),
    );
  }
}
