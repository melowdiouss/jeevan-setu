import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

/// Service for all AI-related API calls.
///
/// SECURITY: All Gemini API calls are proxied through our backend.
/// The API key is stored server-side in environment variables,
/// never in client code.
class AIService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the Firebase ID token for authenticated backend calls.
  Future<String> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please sign in.');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get authentication token.');
    }
    return token;
  }

  /// Make an authenticated POST request to the backend.
  Future<http.Response> _postToBackend(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getIdToken();
    final url = '${AppConfig.backendBaseUrl}$endpoint';

    return await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(
          Duration(seconds: AppConfig.apiTimeoutSeconds),
          onTimeout: () => throw Exception(
            'Request timed out. Please check your connection and try again.',
          ),
        );
  }

  /// Get a general AI chat response.
  Future<String> getAIResponse(String prompt, {String category = 'general'}) async {
    try {
      // Truncate prompt to prevent abuse
      final safePrompt = prompt.length > AppConfig.maxPromptLength
          ? prompt.substring(0, AppConfig.maxPromptLength)
          : prompt;

      final response = await _postToBackend('/ai/chat', {
        'prompt': safePrompt,
        'type': 'general',
        'context': {'category': category},
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response received.';
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please sign in again.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else {
        throw Exception('Server error (${response.statusCode}). Please try again.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAIResponse: $e');
      }
      rethrow;
    }
  }

  /// Get a list of items from AI (for dropdown menus).
  Future<List<String>> _getAIList(String prompt) async {
    try {
      final response = await _postToBackend('/ai/list', {
        'prompt': prompt,
        'type': 'general',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>?;
        if (items != null) {
          return items.map((item) => item.toString()).toList();
        }
        throw Exception('Invalid response format from server.');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please sign in again.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else {
        throw Exception('Server error (${response.statusCode}). Please try again.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _getAIList: $e');
      }
      rethrow;
    }
  }

  /// Save student info to the backend (MongoDB).
  Future<void> saveStudentInfo(Map<String, dynamic> studentInfo) async {
    try {
      final response = await _postToBackend('/students', studentInfo);

      if (response.statusCode == 201) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please sign in again.');
      } else {
        throw Exception('Failed to save student info (${response.statusCode}).');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving student info: $e');
      }
      throw Exception('Failed to save student information: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Education list endpoints
  // All use _getAIList with appropriate prompts
  // ──────────────────────────────────────────────

  Future<List<String>> getQualifications() async {
    return _getAIList('''
List all possible educational qualifications and grades in India, from primary to higher education.
Format the response as a JSON array of strings, for example:
["Class 1", "Class 2", "Class 3", ...]
''');
  }

  Future<List<String>> getStreams(String qualification) async {
    return _getAIList('''
List all possible streams/courses available for $qualification in India.
Format the response as a JSON array of strings, for example:
["Science", "Commerce", "Arts", ...]
''');
  }

  Future<List<String>> getSubjects(String qualification, String stream) async {
    return _getAIList('''
List all subjects available for $stream in $qualification in India.
Format the response as a JSON array of strings, for example:
["Physics", "Chemistry", "Mathematics", ...]
''');
  }

  Future<List<String>> getClasses() async {
    return _getAIList('''
List all possible classes/standards in Indian education system from Class 1 to Class 12.
Format the response as a JSON array of strings, for example:
["Class 1", "Class 2", "Class 3", ...]
''');
  }

  Future<List<String>> getSubjectsForClass(String className) async {
    return _getAIList('''
List all subjects taught in $className in Indian education system.
Format the response as a JSON array of strings, for example:
["Mathematics", "Science", "English", ...]
''');
  }

  Future<List<String>> getStreamsForClass(String className) async {
    return _getAIList('''
List all possible streams/courses available for $className in Indian education system.
Format the response as a JSON array of strings, for example:
["Science", "Commerce", "Arts", ...]
''');
  }

  Future<List<String>> getSubjectsForStream(String className, String stream) async {
    return _getAIList('''
List all subjects available for $stream stream in $className in Indian education system.
Format the response as a JSON array of strings, for example:
["Physics", "Chemistry", "Mathematics", ...]
''');
  }

  Future<List<String>> getEducationBoards() async {
    return _getAIList('''
List all major education boards in India, including:
- India: CBSE, ICSE, IB, State Boards, IGCSE, NIOS

Format the response as a JSON array of strings, for example:
["CBSE", "ICSE", "IB", ...]
''');
  }

  Future<List<String>> getHigherEducationLevels() async {
    return _getAIList('''
List all possible higher education levels after 12th grade, including:
- Undergraduate (UG)
- Postgraduate (PG)
- PhD
- Diploma
- Certificate Courses
- Professional Courses

Format the response as a JSON array of strings, for example:
["Undergraduate", "Postgraduate", "PhD", ...]
''');
  }

  Future<List<String>> getUndergraduateDegrees() async {
    return _getAIList('''
List all possible undergraduate degrees and courses, including:
- Engineering: BTech, BE
- Arts & Humanities: BA, BFA, BJMC
- Commerce & Business: BCom, BBA, CA, CS
- Medical & Health Sciences: MBBS, BDS, BAMS, BHMS
- Law: LLB, BA-LLB
- IT & Computer Applications: BCA, BSc CS
- Science: BSc in various specializations
- Design: BDes, BArch
- Education: BEd, DElEd
- Others

Format the response as a JSON array of strings, for example:
["BTech", "BE", "BA", "BFA", ...]
''');
  }

  Future<List<String>> getPostgraduateDegrees() async {
    return _getAIList('''
List all possible postgraduate degrees and courses, including:
- Business & Management: MBA, MCom, PGDM
- Engineering & Technology: MTech, MSc
- Law: LLM
- Arts & Humanities: MA, MFA
- Medical & Health Sciences: MD, MS, MDS
- Science: MSc in various specializations
- Computer Applications: MCA
- Others

Format the response as a JSON array of strings, for example:
["MBA", "MCom", "MTech", "MSc", ...]
''');
  }

  Future<List<String>> getDiplomaCourses() async {
    return _getAIList('''
List all possible diploma courses and certifications, including:
- Engineering: Diploma in various branches
- Computer Applications: DCA, PGDCA
- Business: PGDM, DBM
- Hotel Management: DHM
- Fashion Design: DFD
- Nursing: GNM, ANM
- Pharmacy: DPharm
- Others

Format the response as a JSON array of strings, for example:
["DCA", "PGDCA", "DBM", "DHM", ...]
''');
  }

  Future<List<String>> getStreamsForBoardAndClass(String board, String className) async {
    return _getAIList('''
List all possible streams available for $className in $board board.
For example:
- CBSE Class 11-12: Science (PCM/PCB/PCMB), Commerce, Arts/Humanities
- ICSE Class 9-10: Science, Commerce, Arts/Humanities
- State Boards: Science, Commerce, Arts

Format the response as a JSON array of strings, for example:
["Science (PCM)", "Science (PCB)", "Commerce", "Arts", ...]
''');
  }

  Future<List<String>> getSpecializationsForDegree(String degree) async {
    return _getAIList('''
List all possible specializations/majors available for $degree.
For example:
- BTech: Computer Science, Electronics, Mechanical, Civil, etc.
- BA: English, History, Political Science, Economics, etc.
- MBA: Finance, Marketing, HR, Operations, etc.

Format the response as a JSON array of strings, for example:
["Computer Science", "Electronics", "Mechanical", ...]
''');
  }
}