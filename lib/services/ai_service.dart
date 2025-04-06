import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _apiKey = 'AIzaSyCzDr0aI3zUvrb6Be_xDxZKIlZ-q0e859Y';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getAIResponse(String prompt) async {
    try {
      if (kDebugMode) {
        print('Sending request to Gemini API...');
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          }
        }),
      );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        final errorMessage = 'Failed to get AI response: ${response.statusCode}\n${response.body}';
        if (kDebugMode) {
          print(errorMessage);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAIResponse: $e');
      }
      throw Exception('Error getting AI response: $e');
    }
  }

  Future<List<String>> getQualifications() async {
    try {
      final prompt = '''
List all possible educational qualifications and grades in India, from primary to higher education.
Format the response as a JSON array of strings, for example:
["Class 1", "Class 2", "Class 3", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Qualifications Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final List<dynamic> jsonArray = jsonDecode(text);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse qualifications from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch qualifications: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getQualifications: $e');
      }
      throw Exception('Error fetching qualifications: $e');
    }
  }

  Future<List<String>> getStreams(String qualification) async {
    try {
      final prompt = '''
List all possible streams/courses available for $qualification in India.
Format the response as a JSON array of strings, for example:
["Science", "Commerce", "Arts", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Streams Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final List<dynamic> jsonArray = jsonDecode(text);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse streams from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch streams: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getStreams: $e');
      }
      throw Exception('Error fetching streams: $e');
    }
  }

  Future<List<String>> getSubjects(String qualification, String stream) async {
    try {
      final prompt = '''
List all subjects available for $stream in $qualification in India.
Format the response as a JSON array of strings, for example:
["Physics", "Chemistry", "Mathematics", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Subjects Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final List<dynamic> jsonArray = jsonDecode(text);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse subjects from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch subjects: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSubjects: $e');
      }
      throw Exception('Error fetching subjects: $e');
    }
  }

  Future<List<String>> getClasses() async {
    try {
      final prompt = '''
List all possible classes/standards in Indian education system from Class 1 to Class 12.
Format the response as a JSON array of strings, for example:
["Class 1", "Class 2", "Class 3", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Classes Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            // Remove markdown code block markers if present
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse classes from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch classes: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getClasses: $e');
      }
      throw Exception('Error fetching classes: $e');
    }
  }

  Future<List<String>> getSubjectsForClass(String className) async {
    try {
      final prompt = '''
List all subjects taught in $className in Indian education system.
Format the response as a JSON array of strings, for example:
["Mathematics", "Science", "English", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Subjects Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            // Remove markdown code block markers if present
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse subjects from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch subjects: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSubjectsForClass: $e');
      }
      throw Exception('Error fetching subjects: $e');
    }
  }

  Future<List<String>> getStreamsForClass(String className) async {
    try {
      final prompt = '''
List all possible streams/courses available for $className in Indian education system.
Format the response as a JSON array of strings, for example:
["Science", "Commerce", "Arts", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Streams Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            // Remove markdown code block markers if present
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse streams from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch streams: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getStreamsForClass: $e');
      }
      throw Exception('Error fetching streams: $e');
    }
  }

  Future<List<String>> getSubjectsForStream(String className, String stream) async {
    try {
      final prompt = '''
List all subjects available for $stream stream in $className in Indian education system.
Format the response as a JSON array of strings, for example:
["Physics", "Chemistry", "Mathematics", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Subjects Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            // Remove markdown code block markers if present
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            // If JSON parsing fails, try to extract array from text
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse subjects from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch subjects: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSubjectsForStream: $e');
      }
      throw Exception('Error fetching subjects: $e');
    }
  }

  Future<void> saveStudentInfo(Map<String, dynamic> studentInfo) async {
    try {
      await _firestore.collection('students').add({
        ...studentInfo,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving student info: $e');
      }
      throw Exception('Failed to save student information: $e');
    }
  }

  Future<List<String>> getEducationBoards() async {
    try {
      final prompt = '''
List all major education boards in India, including:
- India: CBSE, ICSE, IB, State Boards, IGCSE, NIOS


Format the response as a JSON array of strings, for example:
["CBSE", "ICSE", "IB", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Boards Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse boards from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch boards: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getEducationBoards: $e');
      }
      throw Exception('Error fetching education boards: $e');
    }
  }

  Future<List<String>> getHigherEducationLevels() async {
    try {
      final prompt = '''
List all possible higher education levels after 12th grade, including:
- Undergraduate (UG)
- Postgraduate (PG)
- PhD
- Diploma
- Certificate Courses
- Professional Courses

Format the response as a JSON array of strings, for example:
["Undergraduate", "Postgraduate", "PhD", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Higher Education Levels Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse higher education levels from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch higher education levels: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getHigherEducationLevels: $e');
      }
      throw Exception('Error fetching higher education levels: $e');
    }
  }

  Future<List<String>> getUndergraduateDegrees() async {
    try {
      final prompt = '''
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
- Agriculture: BSc Agriculture
- Veterinary: BVSc
- Nursing: BSc Nursing
- Pharmacy: BPharm
- Hotel Management: BHM
- Mass Communication: BJMC
- Fine Arts: BFA
- Performing Arts: BPA
- Physical Education: BPEd
- Social Work: BSW
- Library Science: BLibSc
- Others: Allow manual input

Format the response as a JSON array of strings, for example:
["BTech", "BE", "BA", "BFA", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Undergraduate Degrees Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse undergraduate degrees from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch undergraduate degrees: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getUndergraduateDegrees: $e');
      }
      throw Exception('Error fetching undergraduate degrees: $e');
    }
  }

  Future<List<String>> getPostgraduateDegrees() async {
    try {
      final prompt = '''
List all possible postgraduate degrees and courses, including:
- Business & Management: MBA, MCom, PGDM
- Engineering & Technology: MTech, MSc
- Law: LLM
- Arts & Humanities: MA, MFA
- Medical & Health Sciences: MD, MS, MDS
- Science: MSc in various specializations
- Computer Applications: MCA
- Education: MEd, MA Education
- Design: MDes
- Architecture: MArch
- Social Work: MSW
- Library Science: MLibSc
- Mass Communication: MJMC
- Fine Arts: MFA
- Performing Arts: MPA
- Physical Education: MPEd
- Agriculture: MSc Agriculture
- Veterinary: MVSc
- Nursing: MSc Nursing
- Pharmacy: MPharm
- Hotel Management: MHM
- Others: Allow manual input

Format the response as a JSON array of strings, for example:
["MBA", "MCom", "MTech", "MSc", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Postgraduate Degrees Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse postgraduate degrees from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch postgraduate degrees: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getPostgraduateDegrees: $e');
      }
      throw Exception('Error fetching postgraduate degrees: $e');
    }
  }

  Future<List<String>> getDiplomaCourses() async {
    try {
      final prompt = '''
List all possible diploma courses and certifications, including:
- Engineering: Diploma in various branches
- Computer Applications: DCA, PGDCA
- Business: PGDM, DBM
- Hotel Management: DHM
- Fashion Design: DFD
- Interior Design: DID
- Animation: DFA
- Journalism: DJMC
- Education: DEd, DElEd
- Nursing: GNM, ANM
- Pharmacy: DPharm
- Medical Lab Technology: DMLT
- Radiology: DRD
- Dental Hygiene: DDH
- Physiotherapy: DPT
- Occupational Therapy: DOT
- Nutrition & Dietetics: DND
- Yoga: DY
- Others: Allow manual input

Format the response as a JSON array of strings, for example:
["DCA", "PGDCA", "DBM", "DHM", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Diploma Courses Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse diploma courses from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch diploma courses: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getDiplomaCourses: $e');
      }
      throw Exception('Error fetching diploma courses: $e');
    }
  }

  Future<List<String>> getStreamsForBoardAndClass(String board, String className) async {
    try {
      final prompt = '''
List all possible streams available for $className in $board board.
For example:
- CBSE Class 11-12: Science (PCM/PCB/PCMB), Commerce, Arts/Humanities
- ICSE Class 9-10: Science , Commerce, Arts/Humanities
- ISC Class 11-12: Science (PCM/PCB/PCMB), Commerce, Arts/Humanities
- State Boards: Science, Commerce, Arts
- IB: Sciences, Individuals and Societies, Language and Literature, Mathematics, Arts
- IGCSE: Sciences, Humanities, Languages, Creative and Professional

Format the response as a JSON array of strings, for example:
["Science (PCM)", "Science (PCB)", "Commerce", "Arts", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Streams Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse streams from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch streams: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getStreamsForBoardAndClass: $e');
      }
      throw Exception('Error fetching streams: $e');
    }
  }

  Future<List<String>> getSpecializationsForDegree(String degree) async {
    try {
      final prompt = '''
List all possible specializations/majors available for $degree.
For example:
- BTech: Computer Science, Electronics, Mechanical, Civil, etc.
- BA: English, History, Political Science, Economics, etc.
- BCom: Accounting, Finance, Marketing, etc.
- MBBS: General Medicine, Surgery, Pediatrics, etc.
- BCA: Software Development, Database Management, Web Development, etc.
- MBA: Finance, Marketing, HR, Operations, etc.
- MTech: Computer Science, Electronics, Mechanical, etc.
- MSc: Physics, Chemistry, Mathematics, etc.

Format the response as a JSON array of strings, for example:
["Computer Science", "Electronics", "Mechanical", ...]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (kDebugMode) {
        print('Specializations Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> jsonArray = jsonDecode(cleanText);
            return jsonArray.map((item) => item.toString()).toList();
          } catch (e) {
            final matches = RegExp(r'\[(.*?)\]').firstMatch(text);
            if (matches != null) {
              final arrayStr = matches.group(1)!;
              return arrayStr
                  .split(',')
                  .map((item) => item.trim().replaceAll('"', ''))
                  .toList();
            }
            throw Exception('Failed to parse specializations from response');
          }
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        throw Exception('Failed to fetch specializations: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSpecializationsForDegree: $e');
      }
      throw Exception('Error fetching specializations: $e');
    }
  }
}