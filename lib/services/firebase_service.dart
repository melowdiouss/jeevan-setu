import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.logLogin(loginMethod: 'email');
      return credential;
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.logSignUp(signUpMethod: 'email');
      return credential;
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _analytics.logEvent(name: 'user_logout');
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  // Firestore methods
  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  Future<void> saveFinancialInfo({
    required String userId,
    required Map<String, dynamic> financialData,
  }) async {
    try {
      await _firestore.collection('financial_info').doc(userId).set({
        ...financialData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  Future<void> saveGovernmentSchemeInfo({
    required String userId,
    required Map<String, dynamic> schemeData,
  }) async {
    try {
      await _firestore.collection('scheme_info').doc(userId).set({
        ...schemeData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  // Storage methods
  Future<String> uploadImage(String path, String fileName, Uint8List data) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = await ref.putData(data);
      return await uploadTask.ref.getDownloadURL();
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  // Analytics methods
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e, stack) {
      _crashlytics.recordError(e, stack);
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Store user profile data
  Future<void> storeUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) { print('Error storing user profile: $e'); }
      rethrow;
    }
  }

  // Store education data
  Future<void> storeEducationData({
    required String userId,
    required String institution,
    required String course,
    required String year,
    String? grade,
    String? certificateUrl,
  }) async {
    try {
      await _firestore.collection('education').add({
        'userId': userId,
        'institution': institution,
        'course': course,
        'year': year,
        'grade': grade,
        'certificateUrl': certificateUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) { print('Error storing education data: $e'); }
      rethrow;
    }
  }

  // Store healthcare data
  Future<void> storeHealthcareData({
    required String userId,
    required String condition,
    required String symptoms,
    String? diagnosis,
    String? prescriptionUrl,
  }) async {
    try {
      await _firestore.collection('healthcare').add({
        'userId': userId,
        'condition': condition,
        'symptoms': symptoms,
        'diagnosis': diagnosis,
        'prescriptionUrl': prescriptionUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) { print('Error storing healthcare data: $e'); }
      rethrow;
    }
  }

  // Store agriculture data
  Future<void> storeAgricultureData({
    required String userId,
    required String cropType,
    required String area,
    required String season,
    String? cropYield,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('agriculture').add({
        'userId': userId,
        'cropType': cropType,
        'area': area,
        'season': season,
        'yield': cropYield,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) { print('Error storing agriculture data: $e'); }
      rethrow;
    }
  }

  // Upload file to Firebase Storage
  Future<String> uploadFile(String path, dynamic file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) { print('Error uploading file: $e'); }
      rethrow;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) { print('Error getting user data: $e'); }
      return null;
    }
  }

  // Get education data for a user
  Future<List<Map<String, dynamic>>> getEducationData(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('education')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      if (kDebugMode) { print('Error getting education data: $e'); }
      return [];
    }
  }

  // Get healthcare data for a user
  Future<List<Map<String, dynamic>>> getHealthcareData(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('healthcare')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      if (kDebugMode) { print('Error getting healthcare data: $e'); }
      return [];
    }
  }

  // Get agriculture data for a user
  Future<List<Map<String, dynamic>>> getAgricultureData(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('agriculture')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      if (kDebugMode) { print('Error getting agriculture data: $e'); }
      return [];
    }
  }

  // Education schemes methods

} 