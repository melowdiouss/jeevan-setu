const { body, validationResult } = require('express-validator');

/**
 * Middleware to check validation results and return errors if any.
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
      })),
    });
  }
  next();
};

/**
 * Sanitize a string: trim whitespace, escape HTML entities.
 */
const sanitizeString = (value) => {
  if (typeof value !== 'string') return value;
  return value
    .trim()
    .replace(/[<>]/g, '') // Strip angle brackets (basic XSS prevention)
    .substring(0, 10000); // Hard cap at 10k chars
};

// Validation rules for AI prompt requests
const validateAIPrompt = [
  body('prompt')
    .exists()
    .withMessage('Prompt is required')
    .isString()
    .withMessage('Prompt must be a string')
    .isLength({ min: 1, max: 5000 })
    .withMessage('Prompt must be between 1 and 5000 characters')
    .customSanitizer(sanitizeString),
  body('type')
    .optional()
    .isString()
    .isIn([
      'general',
      'qualifications',
      'streams',
      'subjects',
      'classes',
      'boards',
      'education_levels',
      'degrees',
      'specializations',
      'healthcare',
      'financial',
      'government',
      'agriculture',
    ])
    .withMessage('Invalid request type'),
  body('context')
    .optional()
    .isObject()
    .withMessage('Context must be an object'),
  handleValidationErrors,
];

// Validation rules for student info
const validateStudentInfo = [
  body('name')
    .exists()
    .withMessage('Name is required')
    .isString()
    .isLength({ min: 1, max: 200 })
    .withMessage('Name must be between 1 and 200 characters')
    .customSanitizer(sanitizeString),
  body('educationType')
    .exists()
    .withMessage('Education type is required')
    .isIn(['School', 'Higher'])
    .withMessage('Education type must be "School" or "Higher"'),
  body('class')
    .optional()
    .isString()
    .isLength({ max: 100 })
    .customSanitizer(sanitizeString),
  body('board')
    .optional()
    .isString()
    .isLength({ max: 100 })
    .customSanitizer(sanitizeString),
  body('stream')
    .optional()
    .isString()
    .isLength({ max: 200 })
    .customSanitizer(sanitizeString),
  body('educationLevel')
    .optional()
    .isString()
    .isLength({ max: 200 })
    .customSanitizer(sanitizeString),
  body('degree')
    .optional()
    .isString()
    .isLength({ max: 200 })
    .customSanitizer(sanitizeString),
  body('specialization')
    .optional()
    .isString()
    .isLength({ max: 200 })
    .customSanitizer(sanitizeString),
  body('researchField')
    .optional()
    .isString()
    .isLength({ max: 500 })
    .customSanitizer(sanitizeString),
  handleValidationErrors,
];

module.exports = {
  validateAIPrompt,
  validateStudentInfo,
  handleValidationErrors,
  sanitizeString,
};
