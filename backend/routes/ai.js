const express = require('express');
const router = express.Router();
const { verifyFirebaseToken } = require('../middleware/auth');
const { aiLimiter } = require('../middleware/rateLimiter');
const { validateAIPrompt } = require('../middleware/inputValidator');
const ChatHistory = require('../models/ChatHistory');

const GEMINI_BASE_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

/**
 * Helper: Call Gemini API from the server side.
 * The API key never leaves the server.
 */
async function callGemini(prompt, { temperature = 0.7, maxOutputTokens = 1000 } = {}) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not configured on the server');
  }

  const response = await fetch(`${GEMINI_BASE_URL}?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature, maxOutputTokens },
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Gemini API error (${response.status}): ${errorBody}`);
  }

  const data = await response.json();

  if (
    data.candidates &&
    data.candidates.length > 0 &&
    data.candidates[0].content &&
    data.candidates[0].content.parts &&
    data.candidates[0].content.parts.length > 0
  ) {
    return data.candidates[0].content.parts[0].text;
  }

  throw new Error('Invalid response format from Gemini API');
}

/**
 * Helper: Clean markdown code blocks from JSON responses.
 */
function cleanJsonResponse(text) {
  return text
    .replace(/```json\s*/gi, '')
    .replace(/```\s*/g, '')
    .trim();
}

/**
 * Helper: Parse a JSON array from a Gemini text response.
 */
function parseJsonArray(text) {
  const cleaned = cleanJsonResponse(text);
  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed)) {
      return parsed.map((item) => String(item));
    }
    // Look for an array in object values
    for (const value of Object.values(parsed)) {
      if (Array.isArray(value)) {
        return value.map((item) => String(item));
      }
    }
    throw new Error('No array found in response');
  } catch {
    // Fallback: extract array via regex
    const match = text.match(/\[([^\]]+)\]/);
    if (match) {
      return match[1]
        .split(',')
        .map((item) => item.trim().replace(/"/g, ''))
        .filter((item) => item.length > 0);
    }
    throw new Error('Failed to parse JSON array from response');
  }
}

// ──────────────────────────────────────────────
// Routes
// ──────────────────────────────────────────────

/**
 * POST /api/ai/chat
 * General AI chat endpoint. Proxies to Gemini.
 */
router.post('/chat', verifyFirebaseToken, aiLimiter, validateAIPrompt, async (req, res) => {
  try {
    const { prompt, type = 'general', context = {} } = req.body;
    const userId = req.user.uid;

    const response = await callGemini(prompt, { maxOutputTokens: 500 });

    // Save to chat history in MongoDB
    try {
      const category = context.category || 'general';
      let chatHistory = await ChatHistory.findOne({ userId, category });

      if (!chatHistory) {
        chatHistory = new ChatHistory({ userId, category, messages: [] });
      }

      chatHistory.messages.push(
        { role: 'user', text: prompt },
        { role: 'ai', text: response }
      );
      chatHistory.metadata = { ...chatHistory.metadata, lastType: type };
      await chatHistory.save();
    } catch (dbError) {
      // Don't fail the request if DB save fails — log and continue
      console.error('Failed to save chat history:', dbError.message);
    }

    res.json({ response });
  } catch (error) {
    console.error('AI chat error:', error.message);
    res.status(500).json({
      error: 'AI request failed',
      message: 'Failed to get AI response. Please try again.',
    });
  }
});

/**
 * POST /api/ai/list
 * Get a list (array) of items from AI — used for dropdowns (classes, boards, etc.)
 */
router.post('/list', verifyFirebaseToken, aiLimiter, validateAIPrompt, async (req, res) => {
  try {
    const { prompt } = req.body;

    const response = await callGemini(prompt, { maxOutputTokens: 1000 });
    const items = parseJsonArray(response);

    res.json({ items });
  } catch (error) {
    console.error('AI list error:', error.message);
    res.status(500).json({
      error: 'AI request failed',
      message: 'Failed to get list from AI. Please try again.',
    });
  }
});

/**
 * GET /api/ai/history/:category
 * Retrieve chat history for the authenticated user.
 */
router.get('/history/:category', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const { category } = req.params;

    const validCategories = [
      'healthcare',
      'financial',
      'government',
      'agriculture',
      'education',
      'general',
    ];
    if (!validCategories.includes(category)) {
      return res.status(400).json({ error: 'Invalid category' });
    }

    const chatHistory = await ChatHistory.findOne({ userId, category });

    res.json({
      messages: chatHistory ? chatHistory.messages : [],
    });
  } catch (error) {
    console.error('Chat history error:', error.message);
    res.status(500).json({
      error: 'Failed to retrieve chat history',
    });
  }
});

module.exports = router;
