// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder(

//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_client/utils/constants.dart';
import 'package:flutter_client/widgets/scan_icon.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              SizedBox(height: 30),

              // Welcome Section
              _buildWelcomeSection(),
              SizedBox(height: 40),

              // Scan Section
              _buildScanSection(context),
              SizedBox(height: 30),

              // Stats or other content can go here
              Expanded(child: _buildStatsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trasholini',
          style: AppConstants.headerTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        CircleAvatar(
          backgroundColor: AppConstants.lightGreen,
          child: Icon(Icons.person, color: AppConstants.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: AppConstants.titleTextStyle.copyWith(fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'Let\'s scan and recycle together for a better world 🌱',
          style: AppConstants.bodyTextStyle.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildScanSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.defaultPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryGreen.withOpacity(0.1),
            AppConstants.lightGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius * 1.5),
        border: Border.all(
          color: AppConstants.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Scan?',
            style: AppConstants.titleTextStyle.copyWith(
              color: AppConstants.darkGreen,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tap the scan button to identify items and learn how to dispose them properly',
            textAlign: TextAlign.center,
            style: AppConstants.bodyTextStyle.copyWith(color: Colors.black54),
          ),
          SizedBox(height: 24),

          // Scan Icon Button
          GestureDetector(
            onTap: () => context.push('/scan'),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ScanIcon(
                size: 100,
                backgroundColor: AppConstants.primaryGreen,
                iconColor: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 16),
          Text(
            'Tap to Scan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Impact', style: AppConstants.titleTextStyle),
        SizedBox(height: 16),

        // Stats Cards
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                'Items Scanned',
                '0',
                Icons.qr_code_scanner,
                AppConstants.primaryGreen,
              ),
              _buildStatCard('CO2 Saved', '0 kg', Icons.eco, Colors.green),
              _buildStatCard('Points Earned', '0', Icons.star, Colors.orange),
              _buildStatCard(
                'Streak',
                '0 days',
                Icons.local_fire_department,
                Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppConstants.captionTextStyle,
          ),
        ],
      ),
    );
  }
}
