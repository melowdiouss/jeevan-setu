const express = require('express');
const router = express.Router();
const { verifyFirebaseToken } = require('../middleware/auth');
const { validateStudentInfo } = require('../middleware/inputValidator');
const Student = require('../models/Student');
const UserProfile = require('../models/UserProfile');

/**
 * POST /api/students
 * Save student info. Requires authentication.
 */
router.post('/', verifyFirebaseToken, validateStudentInfo, async (req, res) => {
  try {
    const userId = req.user.uid;
    const studentData = {
      userId,
      name: req.body.name,
      educationType: req.body.educationType,
      class: req.body.class,
      board: req.body.board,
      stream: req.body.stream,
      educationLevel: req.body.educationLevel,
      degree: req.body.degree,
      specialization: req.body.specialization,
      researchField: req.body.researchField,
    };

    const student = new Student(studentData);
    await student.save();

    res.status(201).json({
      message: 'Student info saved successfully',
      id: student._id,
    });
  } catch (error) {
    console.error('Save student error:', error.message);
    res.status(500).json({
      error: 'Failed to save student info',
      message: 'An error occurred while saving your information.',
    });
  }
});

/**
 * GET /api/students
 * Get all student records for the authenticated user.
 */
router.get('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const students = await Student.find({ userId }).sort({ createdAt: -1 });
    res.json({ students });
  } catch (error) {
    console.error('Get students error:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve student info',
    });
  }
});

/**
 * GET /api/students/:id
 * Get a specific student record (must belong to authenticated user).
 */
router.get('/:id', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const student = await Student.findOne({ _id: req.params.id, userId });

    if (!student) {
      return res.status(404).json({ error: 'Student record not found' });
    }

    res.json({ student });
  } catch (error) {
    console.error('Get student error:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve student info',
    });
  }
});

/**
 * PUT /api/students/profile
 * Create or update the user's profile (upsert by Firebase UID).
 */
router.put('/profile', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const updateData = {
      firebaseUid: userId,
      name: req.body.name || req.user.name,
      email: req.body.email || req.user.email,
      ...req.body,
    };

    const profile = await UserProfile.findOneAndUpdate(
      { firebaseUid: userId },
      updateData,
      { upsert: true, new: true, runValidators: true }
    );

    res.json({
      message: 'Profile updated successfully',
      profile,
    });
  } catch (error) {
    console.error('Update profile error:', error.message);
    res.status(500).json({
      error: 'Failed to update profile',
    });
  }
});

/**
 * GET /api/students/profile/me
 * Get the authenticated user's profile.
 */
router.get('/profile/me', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const profile = await UserProfile.findOne({ firebaseUid: userId });

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    res.json({ profile });
  } catch (error) {
    console.error('Get profile error:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve profile',
    });
  }
});

module.exports = router;
