part of 'user_chat_cubit.dart';

final class ChatMessage extends Equatable {
  final String text;
  final bool isMe;

  const ChatMessage({required this.text, required this.isMe});

  @override
  List<Object> get props => [text, isMe];
}

final class UserChatState extends Equatable {
  final String hostName;
  final List<ChatMessage> sentMessages;
  final List<String> quickPrompts;
  final int? selectedPromptIndex;

  const UserChatState({
    required this.hostName,
    this.sentMessages = const [],
    this.quickPrompts = const [
      'Can we talk for a minute?',
      'I need emotional support.',
      'Are you available right now?',
      'I want to share something personal.',
      'Let us start with a quick chat.',
    ],
    this.selectedPromptIndex,
  });

  UserChatState copyWith({
    String? hostName,
    List<ChatMessage>? sentMessages,
    List<String>? quickPrompts,
    int? selectedPromptIndex,
    bool clearSelectedPrompt = false,
  }) {
    return UserChatState(
      hostName: hostName ?? this.hostName,
      sentMessages: sentMessages ?? this.sentMessages,
      quickPrompts: quickPrompts ?? this.quickPrompts,
      selectedPromptIndex: clearSelectedPrompt
          ? null
          : selectedPromptIndex ?? this.selectedPromptIndex,
    );
  }

  @override
  List<Object?> get props => [
    hostName,
    sentMessages,
    quickPrompts,
    selectedPromptIndex,
  ];
}
