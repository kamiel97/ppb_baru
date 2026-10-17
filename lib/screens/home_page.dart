import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF5F9FF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);

  Future<int> _fetchSurveyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return 0;
    }

    final response = await http.get(
      Uri.parse('https://sijala.biz.id/api/v1/surveys'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      if (data is List) {
        return data.length;
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              const SizedBox(height: 24),
              _buildSectionTitle('Activity'),
              const SizedBox(height: 14),
              _buildStatsGrid(), 
              const SizedBox(height: 24),
              // _buildSectionTitle('New Activity'),
              const SizedBox(height: 14),
              // _buildRecentSurveysList(),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            Text(
              'Hello, kamiel ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Welcome to CDG Survei',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // activity

  Widget _buildStatsGrid() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          _buildStatItem(
            title: 'Total Survei',
            value: '2',
            icon: Icons.check_circle_outline_rounded,
            color: primaryColor,
            bgColor: const Color.fromARGB(255, 234, 234, 235),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 105, 158, 219),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NEW ACTIVITY 

  // Widget _buildRecentSurveysList() {
  //   final recentItems = [
  //     {'title': 'Survei Fasilitas', 'date': 'Hari ini, 10:30', 'status': 'Done'},
  //     {'title': 'Survei asd', 'date': 'Kemarin, 14:15', 'status': 'Done'},
  //     {'title': 'Survei hgfd', 'date': '02 Sep 2026', 'status': 'Pending'},
  //   ];

  //   return Container(
  //     child: Column(
  //       children: recentItems.map((item) {
  //         final isSuccess = item['status'] == 'Done';

  //         return Container(
  //           width: double.infinity,
  //           margin: const EdgeInsets.only(bottom: 10),
  //           padding: const EdgeInsets.all(14),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF8F9FB),
  //             borderRadius: BorderRadius.circular(14),
  //             border: Border.all(color: borderColor),
  //           ),
  //           child: Row(
  //             children: [
  //               Container(
  //                 width: 40,
  //                 height: 40,
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFE8F1FB),
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: const Icon(
  //                   Icons.assignment_outlined,
  //                   color: primaryColor,
  //                   size: 20,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       item['title']!,
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: GoogleFonts.plusJakartaSans(
  //                         fontSize: 13,
  //                         fontWeight: FontWeight.w700,
  //                         color: textPrimary,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 3),
  //                     Text(
  //                       item['date']!,
  //                       style: GoogleFonts.plusJakartaSans(
  //                         fontSize: 11,
  //                         color: textMuted,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
  //                 decoration: BoxDecoration(
  //                   color: isSuccess
  //                       ? const Color(0xFFE8F1FB)
  //                       : const Color(0xFFFFEEEE),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Text(
  //                   item['status']!,
  //                   style: GoogleFonts.plusJakartaSans(
  //                     fontSize: 10,
  //                     fontWeight: FontWeight.w700,
  //                     color: isSuccess ? primaryColor : const Color(0xFFE53935),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    );
  }
}