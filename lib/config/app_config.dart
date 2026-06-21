/// Centralized configuration for the JeevanSetu app.
///
/// Backend URL is configured here so the API key never
/// resides in client-side code.
class AppConfig {
  // In development, point to your local backend.
  // In production, replace with your deployed backend URL.
  static const String backendBaseUrl = 'http://localhost:3000/api';

  // Timeout for backend API calls (in seconds)
  static const int apiTimeoutSeconds = 30;

  // Maximum prompt length to send to the backend
  static const int maxPromptLength = 5000;
}
