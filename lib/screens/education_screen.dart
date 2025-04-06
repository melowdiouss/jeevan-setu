import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

class EducationScreen extends StatefulWidget {
  final String studentName;
  final int age;
  final String grade;
  final String stream;
  final List<String> subjects;

  const EducationScreen({
    super.key,
    required this.studentName,
    required this.age,
    required this.grade,
    required this.stream,
    required this.subjects,
  });

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _aiService = AIService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _educationalContent;

  @override
  void initState() {
    super.initState();
    _loadEducationalContent();
  }

  Future<void> _loadEducationalContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate API call to get personalized content
      await Future.delayed(const Duration(seconds: 2));

      // Mock data for now - replace with actual API call later
      _educationalContent = {
        'recommendedCourses': [
          'Advanced Mathematics',
          'Physics Fundamentals',
          'Chemistry Basics',
        ],
        'studyMaterials': [
          'Mathematics Textbook',
          'Physics Lab Manual',
          'Chemistry Reference Guide',
        ],
        'learningPath': [
          'Start with Mathematics Fundamentals',
          'Move to Physics Concepts',
          'End with Chemistry Applications',
        ],
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load educational content: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEducationalContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.studentName}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Grade: ${widget.grade}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Stream: ${widget.stream}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recommended Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _educationalContent?['recommendedCourses'].length ?? 0,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.book),
                              title: Text(_educationalContent!['recommendedCourses'][index]),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Learning Path',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _educationalContent?['learningPath'].length ?? 0,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.arrow_forward,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text(_educationalContent!['learningPath'][index]),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Study Materials',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _educationalContent?['studyMaterials'].length ?? 0,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.menu_book),
                              title: Text(_educationalContent!['studyMaterials'][index]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}