import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'education_screen.dart';
import '../services/ai_service.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customBoardController = TextEditingController();
  final _customStreamController = TextEditingController();
  final _customDegreeController = TextEditingController();
  final _researchFieldController = TextEditingController();
  
  final AIService _aiService = AIService();
  
  bool _isLoading = false;
  String? _error;
  
  // Education type selection
  bool _isSchoolEducation = true;
  
  // School education fields
  List<String> _classes = [];
  String? _selectedClass;
  List<String> _boards = [];
  String? _selectedBoard;
  List<String> _streams = [];
  String? _selectedStream;
  
  // Higher education fields
  List<String> _educationLevels = [];
  String? _selectedEducationLevel;
  List<String> _degrees = [];
  String? _selectedDegree;
  List<String> _specializations = [];
  String? _selectedSpecialization;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customBoardController.dispose();
    _customStreamController.dispose();
    _customDegreeController.dispose();
    _researchFieldController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      if (_isSchoolEducation) {
        await _loadClasses();
        await _loadBoards();
      } else {
        await _loadEducationLevels();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await _aiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBoards() async {
    try {
      final boards = await _aiService.getEducationBoards();
      setState(() {
        _boards = boards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStreams() async {
    if (_selectedClass == null || _selectedBoard == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final streams = await _aiService.getStreamsForBoardAndClass(_selectedBoard!, _selectedClass!);
      setState(() {
        _streams = streams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEducationLevels() async {
    try {
      final levels = await _aiService.getHigherEducationLevels();
      setState(() {
        _educationLevels = levels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDegrees() async {
  if (_selectedEducationLevel == null) return;
  print("Loading degrees for: $_selectedEducationLevel");
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    List<String> degrees;
    switch (_selectedEducationLevel!.toLowerCase()) {
      case 'undergraduate':
        degrees = await _aiService.getUndergraduateDegrees();
        break;
      case 'postgraduate':
        degrees = await _aiService.getPostgraduateDegrees();
        break;
      case 'diploma':
        degrees = await _aiService.getDiplomaCourses();
        break;
      default:
        degrees = [];
    }
    print("Degrees fetched: $degrees");
    setState(() {
      _degrees = degrees;
      _isLoading = false;
    });
  } catch (e) {
    print("Error loading degrees: $e");
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}
  Future<void> _loadSpecializations() async {
    if (_selectedDegree == null) return;
    print("Loading specializations for: $_selectedDegree");
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      List<String> specializations;
      switch (_selectedDegree!.toLowerCase()) {
        default:
          specializations = await _aiService.getSpecializationsForDegree(_selectedDegree!);
      }
      print("Specializations fetched: $specializations");
      setState(() {
        _specializations = specializations;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading specializations: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isHighSchool() {
    if (_selectedClass == null) return false;
    final classNumber = int.tryParse(_selectedClass!.split(' ').last);
    return classNumber != null && classNumber >= 11;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final Map<String, dynamic> studentInfo = {
        'name': _nameController.text,
        'educationType': _isSchoolEducation ? 'School' : 'Higher',
        'createdAt': DateTime.now(),
      };
      
      if (_isSchoolEducation) {
        studentInfo.addAll({
          'class': _selectedClass,
          'board': _selectedBoard,
          if (_isHighSchool()) 'stream': _selectedStream,
        });
      } else {
        studentInfo.addAll({
          'educationLevel': _selectedEducationLevel,
          'degree': _selectedDegree,
          if (_selectedSpecialization != null) 'specialization': _selectedSpecialization,
          if (_selectedEducationLevel == 'PhD') 'researchField': _researchFieldController.text,
        });
      }
      
      await _aiService.saveStudentInfo(studentInfo);
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EducationScreen(
            studentName: _nameController.text,
            age: 0, // We'll need to add age field
            grade: _isSchoolEducation ? _selectedClass! : _selectedDegree!,
            stream: _isSchoolEducation ? (_selectedStream ?? '') : (_selectedSpecialization ?? ''),
            subjects: [], // No longer using subjects
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Education type selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Education Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('School Education'),
                              value: true,
                              groupValue: _isSchoolEducation,
                              onChanged: (value) {
                                setState(() {
                                  _isSchoolEducation = value!;
                                  _loadInitialData();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Higher Education'),
                              value: false,
                              groupValue: _isSchoolEducation,
                              onChanged: (value) {
                                setState(() {
                                  _isSchoolEducation = value!;
                                  _loadInitialData();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_isSchoolEducation) ...[
                // Class selection
                DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Current Class',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: _classes.map((className) {
                    return DropdownMenuItem(
                      value: className,
                      child: Text(
                        className,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                      _selectedStream = null;
                      _loadStreams();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your class';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Board selection
                DropdownButtonFormField<String>(
                  value: _selectedBoard,
                  decoration: const InputDecoration(
                    labelText: 'Education Board',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: _boards.map((board) {
                    return DropdownMenuItem(
                      value: board,
                      child: Text(
                        board,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBoard = value;
                      _selectedStream = null;
                      _loadStreams();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your education board';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Stream selection for high school
                if (_isHighSchool() && _streams.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedStream,
                    decoration: const InputDecoration(
                      labelText: 'Stream',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: _streams.map((stream) {
                      return DropdownMenuItem(
                        value: stream,
                        child: Text(
                          stream,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStream = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your stream';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ] else ...[
                // Higher education level selection
                DropdownButtonFormField<String>(
                  value: _selectedEducationLevel,
                  decoration: const InputDecoration(
                    labelText: 'Education Level',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: _educationLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(
                        level,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEducationLevel = value;
                      _selectedDegree = null;
                      _selectedSpecialization = null;
                      _loadDegrees();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your education level';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Degree selection
                if (_degrees.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedDegree,
                    decoration: const InputDecoration(
                      labelText: 'Degree/Course',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: _degrees.map((degree) {
                      return DropdownMenuItem(
                        value: degree,
                        child: Text(
                          degree,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDegree = value;
                        _selectedSpecialization = null;
                        _loadSpecializations();
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your degree/course';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Specialization selection
                if (_specializations.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'Specialization/Major',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: _specializations.map((specialization) {
                      return DropdownMenuItem(
                        value: specialization,
                        child: Text(
                          specialization,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialization = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your specialization';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Research field for PhD
                if (_selectedEducationLevel == 'PhD') ...[
                  TextFormField(
                    controller: _researchFieldController,
                    decoration: const InputDecoration(
                      labelText: 'Research Field',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your research field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
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