/// Shared message model used across all chat screens.
///
/// Previously duplicated in healthcare_screen.dart,
/// financial_assistance_screen.dart, and government_schemes_screen.dart.
class Message {
  final String text;
  final bool isUser;
  final bool isTyping;

  const Message({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  /// Create a copy with updated fields.
  Message copyWith({
    String? text,
    bool? isUser,
    bool? isTyping,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
