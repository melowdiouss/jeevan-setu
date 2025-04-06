import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.black;
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF64B5F6);
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color primaryBackgroundColor = Color(0xFFFFF5E6); // Light peach color
  static const Color secondaryBackgroundColor = Color(0xFFFFFFFF);
  static const Color borderColor = Colors.grey;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;

  // Dark theme colors
  static const Color darkPrimaryColor = Colors.black;
  static const Color darkSecondaryColor = Color(0xFF81C784);
  static const Color darkAccentColor = Color(0xFF2196F3);
  static const Color darkPrimaryTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Color(0xffb3ffffff);
  static const Color darkPrimaryBackgroundColor = Color(0xFF2C2C2C);
  static const Color darkSecondaryBackgroundColor = Color(0xFF3C3C3C);
  static const Color darkBorderColor = Colors.grey;
  static const Color darkErrorColor = Colors.redAccent;
  static const Color darkSuccessColor = Colors.greenAccent;

  // Text Colors
  static const Color lightTextColor = Color(0xFFFFFFFF);

  // Background Colors
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);

  // Status Colors
  static const Color warningColor = Color(0xFFFFA726);
  static const Color infoColor = Color(0xFF29B6F6);

  // Input Decoration
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: secondaryTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      filled: true,
      fillColor: secondaryBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
    );
  }

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Button styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: primaryColor),
    ),
  );

  // Dropdown Style
  static DropdownButtonFormField<String> dropdownStyle({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: inputDecoration(label),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 14,
              color: primaryTextColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      isExpanded: true,
      dropdownColor: secondaryBackgroundColor,
      style: const TextStyle(
        fontSize: 14,
        color: primaryTextColor,
      ),
      icon: const Icon(Icons.arrow_drop_down, size: 20, color: primaryTextColor),
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String item) {
          return Text(
            item,
            style: const TextStyle(
              fontSize: 14,
              color: primaryTextColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          );
        }).toList();
      },
    );
  }

  // Message Bubble Style
  static BoxDecoration userMessageBubble = const BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
    ),
  );

  static BoxDecoration aiMessageBubble = const BoxDecoration(
    color: secondaryBackgroundColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      background: primaryBackgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryTextColor,
      onBackground: primaryTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: primaryBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      surface: const Color(0xFF3C3C3C),
      background: darkPrimaryBackgroundColor,
      error: darkErrorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkPrimaryTextColor,
      onBackground: darkPrimaryTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkPrimaryBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3C3C3C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkErrorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
} 