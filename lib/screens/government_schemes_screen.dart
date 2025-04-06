import 'package:flutter/material.dart';
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

class GovernmentPage extends StatefulWidget {
  const GovernmentPage({super.key});

  @override
  State<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends State<GovernmentPage> {
  final _aiService = AIService();
  final _formKey = GlobalKey<FormState>();
  
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  
  String _selectedCategory = 'Education';
  String _selectedState = 'All India';
  String _selectedGender = 'Any';
  String _selectedCaste = 'General';
  bool _hasSubmittedInfo = false;
  
  final _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Education', 
    'Agriculture', 
    'Healthcare', 
    'Housing', 
    'Employment',
    'Pension',
    'Insurance',
    'Business/Entrepreneurship',
    'Women Empowerment',
    'Disability Benefits',
    'Minority Benefits',
    'Rural Development'
  ];
  
  final List<String> _states = [
    'All India',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
  ];
  
  final List<String> _genders = ['Any', 'Male', 'Female', 'Transgender'];
  
  final List<String> _castes = [
    'General',
    'OBC (Other Backward Classes)',
    'SC (Scheduled Caste)',
    'ST (Scheduled Tribe)',
    'EWS (Economically Weaker Section)'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with a welcome message
    _messages.add(Message(
      text: 'Welcome to the Government Schemes section! Please fill out the form below to find relevant schemes for you.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitInfo() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _hasSubmittedInfo = true;
        _messages.add(Message(
          text: 'Based on your details, I can help you find government schemes. What specific information are you looking for?',
          isUser: false,
          isTyping: true,
        ));
      });
    }
  }

  Future<void> _getSchemeRecommendations() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(Message(
        text: userMessage,
        isUser: true,
      ));
      _isLoading = true;
    });

    try {
      final prompt = '''
Based on the following information:
- Age: ${_ageController.text}
- Gender: $_selectedGender
- Annual Family Income: ${_incomeController.text}
- Caste/Category: $_selectedCaste
- State: $_selectedState
- Scheme Category: $_selectedCategory

User Question: $userMessage

Please provide information about relevant government schemes and eligibility criteria.
''';

      final response = await _aiService.getAIResponse(prompt);
      
      setState(() {
        _messages.removeLast(); // Remove typing indicator
        _messages.add(Message(
          text: response,
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast(); // Remove typing indicator
        _messages.add(Message(
          text: 'I apologize, but I encountered an error. Please try again later.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes'),
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
                              hintText: 'Ask about government schemes',
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
                          onPressed: _getSchemeRecommendations,
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
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    TextFormField(
                      controller: _incomeController,
                      decoration: InputDecoration(
                        labelText: 'Annual Family Income',
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your annual family income';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: _states.map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(
                            state,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a state';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCaste,
                      decoration: const InputDecoration(
                        labelText: 'Caste',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: _castes.map((caste) {
                        return DropdownMenuItem(
                          value: caste,
                          child: Text(
                            caste,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCaste = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a caste';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 