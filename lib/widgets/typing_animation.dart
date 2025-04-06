import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TypingAnimation extends StatefulWidget {
  final String text;
  final bool isUser;
  final Function()? onComplete;

  const TypingAnimation({
    super.key,
    required this.text,
    required this.isUser,
    this.onComplete,
  });

  @override
  State<TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation> {
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _typeNextCharacter();
      }
    });
  }

  void _typeNextCharacter() {
    if (_currentIndex < widget.text.length) {
      setState(() {
        _displayedText += widget.text[_currentIndex];
        _currentIndex++;
      });
      Future.delayed(const Duration(milliseconds: 20), () {
        if (mounted) {
          _typeNextCharacter();
        }
      });
    } else {
      setState(() {
        _isComplete = true;
      });
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: widget.isUser ? AppTheme.primaryColor : AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: widget.isUser ? AppTheme.secondaryBackgroundColor : AppTheme.primaryTextColor,
            fontSize: 16,
          ),
          children: _parseMessageText(_displayedText),
        ),
      ),
    );
  }

  List<TextSpan> _parseMessageText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(fontSize: 16),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(fontSize: 16),
      ));
    }

    return spans;
  }
} 