const mongoose = require('mongoose');

const studentSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },
    educationType: {
      type: String,
      required: true,
      enum: ['School', 'Higher'],
    },
    // School education fields
    class: {
      type: String,
      trim: true,
      maxlength: 100,
    },
    board: {
      type: String,
      trim: true,
      maxlength: 100,
    },
    stream: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    // Higher education fields
    educationLevel: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    degree: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    specialization: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    researchField: {
      type: String,
      trim: true,
      maxlength: 500,
    },
  },
  {
    timestamps: true, // Adds createdAt and updatedAt automatically
  }
);

// Compound index for efficient user-specific queries
studentSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Student', studentSchema);
