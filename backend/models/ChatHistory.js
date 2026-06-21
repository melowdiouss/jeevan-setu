const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  role: {
    type: String,
    required: true,
    enum: ['user', 'ai'],
  },
  text: {
    type: String,
    required: true,
    maxlength: 50000,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

const chatHistorySchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    category: {
      type: String,
      required: true,
      enum: ['healthcare', 'financial', 'government', 'agriculture', 'education', 'general'],
      index: true,
    },
    messages: [messageSchema],
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for efficient queries
chatHistorySchema.index({ userId: 1, category: 1, createdAt: -1 });

// Limit chat history size (keep last 100 messages per conversation)
chatHistorySchema.pre('save', function (next) {
  if (this.messages.length > 100) {
    this.messages = this.messages.slice(-100);
  }
  next();
});

module.exports = mongoose.model('ChatHistory', chatHistorySchema);
