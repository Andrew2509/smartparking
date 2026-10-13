import 'package:flutter/material.dart';

class TeamPdfView extends StatelessWidget {
  final int activeNodesCount;
  final bool isBackendOnline;

  const TeamPdfView({
    super.key,
    required this.activeNodesCount,
    required this.isBackendOnline,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IoT Development Team
            _buildTeamSection(),
            const SizedBox(height: 28),

            // 2. Project Reference & PDF Card
            _buildProjectReferenceSection(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    final members = [
      _TeamMember(
        name: 'Muhamad Hamzah',
        role: 'Lead Architect',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB3AUt36lkODgLUivQU1mXUuMf_2sgyymGhFzgXXCWOryqKUKQ37npM_MObh6nCjU4NJqlJz1Q_xjnAf_F6wmoxxBTMx6kE2vhF7VzQ3a7IG_kfnn35-uCjINCSV2Hftffclry-MYuDJ1Q3h5i-eSNEz_CDg1rhFkNPGtpHe3IuG7XAjDarpku-RLOxkLi-DwxcYiD3Z45p7sIZtQhm2EsbtSfFRS5_34PK--g7j6U6jk6ON0vPlmVcppE7FFp0pTd_tkuGYl99Qg',
      ),
      _TeamMember(
        name: 'M. Reza Syahputra',
        role: 'Backend Specialist',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBahXKp9sdpJMtutcHiZntJFS8T0YKDOa3Z1dsesqqpA4yt6ffbyhpCYptl_oXNOG-R8kZzc3I5IEC5MD161zWew-k05ZUULL1lxjrsb73GRDFfTIg93IFE8S-a9YUTkJLpJxbeg794kbVmvFAoLMWk0AKBPhB4R-NY3sJHgZ4YFHlveZHUtJ2aQ7Z4MhR2B1RlRhnZAgPZzTuVpFPj1BmHHwVl0dsWGujYgcjw7NKTgQdAAS5X1tecNfEfqGxwEAXsP-wC-C-cKg',
      ),
      _TeamMember(
        name: 'M. Alif Arrosyid',
        role: 'Hardware Dev',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuACVLbW5p2b9hUMVcDbyNvK9WxCHm5ayFJuPmrgXntbci7pK1pF9EGx1LTUgrTNzCh9auyJ46fzh4GoY-KXUx5GT5Dz84MpN_rCTzmcqeQjs_X5yd9fFUCYMzRTGBmAHKYw-sdHssOa6b4L9s_CsYMK3Fo-UKO4elCX6XeT0gVcSkOp3y8K6F9bGL-pHYHlDTiSDpCaCJJVYM_vsahEf0nv6kCJNeFxBZWScTKVvljtW-kkqOCJ8q6MPp0Xf2RLFJbUchcNlUw6yA',
      ),
      _TeamMember(
        name: 'Princenton Andrew',
        role: 'UX Strategist',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAECJUcpjSCqkEMoHzKH_5mFxraZg77JvQH0xOHpiZkmGWFqzogJqAYbqm0ej1kf034x0y4o3OWQYwzzQYEPwxUBMkLcfVId7D5IDcleHKuNbQ9pLkW7tKU0xuWyaE7x297of1H_WQqDu5AU2NC5sOeTd39-kmfK6ysWTFa4JQsK6QAxcoCeeW6bkxO7wwROue5LqZFfJ2M9YszKxJfLmRvhbFjwFBKmKro3-ec2SxvzGAGwx6PoO3KTXbR4EE4xP23vh9TNoBJlg',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IoT Development Team',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'The minds behind the smart urban parking revolution.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final m = members[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF312E81).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      m.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.person, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1B1B23),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.role,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProjectReferenceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Reference',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Official documentation and system architecture.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF312E81).withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFFEF4444),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistem Parkir Cerdas Berbasis IoT',
                          style: TextStyle(
                            color: Color(0xFF1B1B23),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'V1.2 FINAL',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' • 2.4 MB • Updated May 2024',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Membuka file PDF laporan...')),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4648D4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.6)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.download, color: Color(0xFF4648D4)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mengunduh PDF...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String imageUrl;

  _TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}
