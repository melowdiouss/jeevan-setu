import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../widgets/typing_animation.dart';
import '../models/message.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key});

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  final _aiService = AIService();
  final _formKey = GlobalKey<FormState>();
  
  final _incomeController = TextEditingController();
  final _occupationController = TextEditingController();
  final _dependentsController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _purposeController = TextEditingController();
  
  String _selectedEmploymentType = 'Salaried';
  String _selectedCreditScore = 'Excellent (750+)';
  bool _hasSubmittedInfo = false;
  
  final _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  final List<String> _employmentTypes = [
    'Salaried', 
    'Self-employed', 
    'Business Owner', 
    'Unemployed', 
    'Student', 
    'Retired',
    'Farmer',
    'Daily Wage Worker'
  ];
  
  final List<String> _creditScores = [
    'Excellent (750+)', 
    'Good (700-749)', 
    'Fair (650-699)', 
    'Poor (600-649)', 
    'Very Poor (below 600)', 
    'No Credit History'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with a welcome message
    _messages.add(Message(
      text: 'Welcome to the Financial Assistance section! Please fill out the form below to get started.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _occupationController.dispose();
    _dependentsController.dispose();
    _loanAmountController.dispose();
    _purposeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitInfo() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _hasSubmittedInfo = true;
        _messages.add(Message(
          text: 'Thank you for providing your financial information. How can I assist you with financial matters today?',
          isUser: false,
          isTyping: true,
        ));
      });
    }
  }

  Future<void> _getFinancialAdvice() async {
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
- Monthly Income: ${_incomeController.text}
- Occupation: ${_occupationController.text}
- Employment Type: $_selectedEmploymentType
- Number of Dependents: ${_dependentsController.text}
- Credit Score: $_selectedCreditScore
- Loan Amount Needed: ${_loanAmountController.text}
- Purpose: ${_purposeController.text}

User Question: $userMessage

Please provide financial advice and guidance.
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
        title: const Text('Financial Assistance'),
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
                              hintText: 'Ask about financial assistance',
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
                          onPressed: _getFinancialAdvice,
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
                      'Financial Information',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _incomeController,
                      decoration: InputDecoration(
                        labelText: 'Monthly Income',
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your monthly income';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _occupationController,
                      decoration: InputDecoration(
                        labelText: 'Occupation',
                        prefixIcon: const Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your occupation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedEmploymentType,
                      decoration: const InputDecoration(
                        labelText: 'Employment Type',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: _employmentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmploymentType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your employment type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dependentsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Dependents',
                        prefixIcon: const Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of dependents';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loanAmountController,
                      decoration: InputDecoration(
                        labelText: 'Loan Amount Needed',
                        prefixIcon: const Icon(Icons.account_balance),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter loan amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        labelText: 'Purpose of Loan',
                        prefixIcon: const Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter purpose of loan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCreditScore,
                      decoration: const InputDecoration(
                        labelText: 'Credit Score',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: _creditScores.map((score) {
                        return DropdownMenuItem(
                          value: score,
                          child: Text(
                            score,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCreditScore = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your credit score';
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