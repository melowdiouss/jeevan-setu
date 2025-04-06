import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../widgets/typing_animation.dart';

class Message {
  final String text;
  final bool isUser;
  final bool isTyping;

  Message({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });
}

class HealthcareScreen extends StatefulWidget {
  const HealthcareScreen({super.key});

  @override
  State<HealthcareScreen> createState() => _HealthcareScreenState();
}

class _HealthcareScreenState extends State<HealthcareScreen> {
  final _aiService = AIService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'A+';
  bool _hasSubmittedInfo = false;
  final _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitInfo() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _hasSubmittedInfo = true;
      });
    }
  }

  Future<void> _getHealthcareInfo() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(Message(
        text: userMessage,
        isUser: true,
      ));
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final prompt = '''
      IMPORTANT: Please provide healthcare guidance following these guidelines:
      1. Use bold text (enclose with **) for important information like:
         - Symptoms
         - Treatment options
         - Preventive measures
         - Emergency signs
         - Critical warnings
      2. Structure your response clearly with:
         - Main points in bold
         - Supporting details in regular text
         - Examples where appropriate
         - Actionable advice
      3. Keep the tone professional yet compassionate
      4. Include practical tips and precautions
      5. If recommending treatments, make them specific and evidence-based
      
      User Profile:
      - Name: ${_nameController.text}
      - Age: ${_ageController.text}
      - Gender: $_selectedGender
      - Blood Group: $_selectedBloodGroup
      - Weight: ${_weightController.text} kg
      - Height: ${_heightController.text} cm
      
      User Query: $userMessage
      
      Please provide appropriate healthcare guidance based on the user's profile and query. Use bold text for important information.
      ''';

      final response = await _aiService.getAIResponse(prompt);

      setState(() {
        _messages.add(Message(
          text: response,
          isUser: false,
          isTyping: true,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          isTyping: true,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare'),
      ),
      body: _hasSubmittedInfo
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: message.isTyping
                            ? TypingAnimation(
                                text: message.text,
                                isUser: message.isUser,
                                onComplete: () {
                                  setState(() {
                                    _messages[index] = Message(
                                      text: message.text,
                                      isUser: message.isUser,
                                      isTyping: false,
                                    );
                                  });
                                },
                              )
                            : Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: message.isUser
                                      ? AppTheme.primaryColor
                                      : AppTheme.secondaryBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: message.isUser
                                          ? AppTheme.secondaryBackgroundColor
                                          : AppTheme.primaryTextColor,
                                      fontSize: 16,
                                    ),
                                    children: _parseMessageText(message.text),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Share your Symptoms and Concerns',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _getHealthcareInfo,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Personal Information',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: const Icon(Icons.people),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        prefixIcon: const Icon(Icons.bloodtype),
                      ),
                      items: _bloodGroups
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodGroup = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: const Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid height';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitInfo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.secondaryBackgroundColor,
                      ),
                      child: Text(
                        'Continue',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
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