const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      maxlength: 320,
    },
    phone: {
      type: String,
      trim: true,
      maxlength: 20,
    },
    address: {
      type: String,
      trim: true,
      maxlength: 1000,
    },
    // Healthcare profile
    healthProfile: {
      age: { type: Number, min: 0, max: 150 },
      gender: { type: String, enum: ['Male', 'Female', 'Other'] },
      bloodGroup: { type: String, enum: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'] },
      weight: { type: Number, min: 0, max: 500 },
      height: { type: Number, min: 0, max: 300 },
    },
    // Financial profile
    financialProfile: {
      monthlyIncome: { type: Number, min: 0 },
      occupation: { type: String, trim: true, maxlength: 200 },
      employmentType: {
        type: String,
        enum: [
          'Salaried',
          'Self-employed',
          'Business Owner',
          'Unemployed',
          'Student',
          'Retired',
          'Farmer',
          'Daily Wage Worker',
        ],
      },
      dependents: { type: Number, min: 0 },
      creditScore: { type: String, maxlength: 50 },
    },
    // Government scheme profile
    governmentProfile: {
      age: { type: Number, min: 0, max: 150 },
      annualFamilyIncome: { type: Number, min: 0 },
      gender: { type: String },
      caste: { type: String, maxlength: 100 },
      state: { type: String, maxlength: 100 },
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('UserProfile', userProfileSchema);
