import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'user_chat_state.dart';

@injectable
class UserChatCubit extends Cubit<UserChatState> {
  UserChatCubit({required String hostName})
    : super(UserChatState(hostName: hostName));

  void selectPrompt(int index) {
    if (index < 0 || index >= state.quickPrompts.length) {
      return;
    }

    final prompt = state.quickPrompts[index];
    final updatedMessages = [
      ...state.sentMessages,
      ChatMessage(text: prompt, isMe: true),
    ];

    emit(
      state.copyWith(
        sentMessages: updatedMessages,
        selectedPromptIndex: index,
      ),
    );
  }
}
