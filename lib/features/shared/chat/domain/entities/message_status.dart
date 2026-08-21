enum MessageStatus {
  sent,
  delivered,
  read;

  static MessageStatus fromString(String? raw) {
    switch (raw) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }
}
