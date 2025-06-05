import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants.dart';

class CategoryDetailsPage extends ConsumerWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;

  const CategoryDetailsPage({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppConstants.lightGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, size, ref),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  children: [
                    _buildImageContainer(context, size),
                    SizedBox(height: size.height * 0.030),
                    _buildDetailsCard(context, size),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(size),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * 0.04),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: size.width * 0.15,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Image not found',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.1,
                height: size.width * 0.1,
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.recycling,
                  color: Colors.white,
                  size: size.width * 0.05,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Text(
                'Categories Details',
                style: TextStyle(
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.025),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Saved CO2',
                      style: TextStyle(
                        fontSize: size.width * 0.032,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    _buildDetailItem(
                      analysisResult['co2_saved'] ?? '2.3kg',
                      size,
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Points',
                      style: TextStyle(
                        fontSize: size.width * 0.032,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    _buildDetailItem('${analysisResult['points'] ?? 80}', size),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Material',
                      style: TextStyle(
                        fontSize: size.width * 0.032,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    _buildDetailItem(
                      analysisResult['material'] ?? 'Plastic',
                      size,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.025),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/disposal-instructions',
                  extra: {
                    'imagePath': imagePath,
                    'analysisResult': analysisResult,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                ),
                elevation: 0,
              ),
              child: Text(
                'See more instructions',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String value, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.03,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(size.width * 0.02),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size.width * 0.04,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(Size size) {
    return Container(
      height: size.height * 0.09,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true, size),
          _buildNavItem(Icons.category, 'Categories', false, size),
          _buildNavItem(Icons.settings, 'Setting', false, size),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? AppConstants.primaryGreen : Colors.grey,
          size: size.width * 0.06,
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.03,
            color: isActive ? AppConstants.primaryGreen : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

Widget _buildHeader(BuildContext context, Size size, WidgetRef ref) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: size.width * 0.04,
      vertical: size.height * 0.01,
    ),
    child: Row(
      children: [
        // Back button
        Container(
          width: size.width * 0.11,
          height: size.width * 0.11,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size.width * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => ref.read(routerProvider).go('/scan'),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: size.width * 0.05,
            ),
          ),
        ),

        // Centered title with icon
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Waste Item Details',
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: size.width * 0.13), // Balance the row
      ],
    ),
  );
}
