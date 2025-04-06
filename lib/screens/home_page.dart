import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'education_screen.dart';
import 'healthcare_screen.dart';
import 'agriculture_screen.dart';
import 'financial_assistance_screen.dart';
import 'package:jeevansetu/services/firebase_service.dart';
import 'package:jeevansetu/screens/login_screen.dart';
import 'student_info_screen.dart';
import 'government_schemes_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: AppBar(
        title: const Text('Jeevan Setu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseService().signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Services',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                buildServiceCard(
                  context,
                  'Education',
                  'Get educational guidance and support',
                  Icons.school,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentInfoScreen(),
                      ),
                    );
                  },
                ),
                buildServiceCard(
                  context,
                  'Healthcare',
                  'Access healthcare information and services',
                  Icons.medical_services,
                  const HealthcareScreen(),
                ),
                buildServiceCard(
                  context,
                  'Agriculture Help',
                  'Get assistance with farming and agriculture',
                  Icons.agriculture,
                  const AgricultureScreen(),
                ),
                buildServiceCard(
                  context,
                  'Financial Assistance',
                  'Explore financial support options',
                  Icons.account_balance,
                  const FinancialPage(),
                ),
                buildServiceCard(
                  context,
                  'Government Schemes',
                  'Learn about government programs',
                  Icons.account_balance_wallet,
                  const GovernmentPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServiceCard(BuildContext context, String title, String subtitle, IconData icon, dynamic page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (page is Function) {
              page();
            } else if (page is FinancialPage) {
              Navigator.pushNamed(context, '/financial');
            } else if (page is GovernmentPage) {
              Navigator.pushNamed(context, '/government');
            } else if (page is EducationScreen) {
              Navigator.pushNamed(context, '/education');
            } else if (page is HealthcareScreen) {
              Navigator.pushNamed(context, '/healthcare');
            } else if (page is AgricultureScreen) {
              Navigator.pushNamed(context, '/agriculture');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}