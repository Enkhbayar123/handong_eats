import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/localization.dart';

class DietaryOption {
  final String label;
  final String enName;
  final String koName;
  final String enDesc;
  final String koDesc;
  final IconData icon;
  final Color color;

  DietaryOption({
    required this.label,
    required this.enName,
    required this.koName,
    required this.enDesc,
    required this.koDesc,
    required this.icon,
    required this.color,
  });
}

class DietaryLabelsScreen extends StatefulWidget {
  final String userId;
  final List<String> initialLabels;

  const DietaryLabelsScreen({
    super.key,
    required this.userId,
    required this.initialLabels,
  });

  @override
  State<DietaryLabelsScreen> createState() => _DietaryLabelsScreenState();
}

class _DietaryLabelsScreenState extends State<DietaryLabelsScreen> {
  late List<String> _selectedLabels;
  bool _isSaving = false;

  final List<DietaryOption> _options = [
    DietaryOption(
      label: 'Halal',
      enName: 'Halal',
      koName: '할랄',
      enDesc: 'Food prepared according to Islamic dietary laws',
      koDesc: '이슬람 율법에 따라 조리된 식품',
      icon: Icons.verified_rounded,
      color: Colors.teal,
    ),
    DietaryOption(
      label: 'Vegetarian',
      enName: 'Vegetarian',
      koName: '채식주의자 (락토-오보)',
      enDesc: 'Excludes meat and seafood, but may include dairy/eggs',
      koDesc: '육류와 해산물은 제외하고 유제품이나 계란은 포함하는 식단',
      icon: Icons.eco_rounded,
      color: Colors.green,
    ),
    DietaryOption(
      label: 'Vegan',
      enName: 'Vegan',
      koName: '비건',
      enDesc: '100% plant-based, no animal products or by-products',
      koDesc: '동물성 성분을 완전히 배제한 100% 식물성 식단',
      icon: Icons.grass_rounded,
      color: Colors.lightGreen,
    ),
    DietaryOption(
      label: 'Lactose-Free',
      enName: 'Lactose-Free',
      koName: '락토프리',
      enDesc: 'Excludes milk sugars for lactose intolerance sufferers',
      koDesc: '유당불내증 증상 완화를 위해 유당을 제거한 식품',
      icon: Icons.opacity_rounded,
      color: Colors.blue,
    ),
    DietaryOption(
      label: 'Gluten-Free',
      enName: 'Gluten-Free',
      koName: '글루텐프리',
      enDesc: 'No wheat, barley, rye, or gluten-containing proteins',
      koDesc: '밀, 보리, 귀리 등 글루텐 단백질 성분을 배제한 식품',
      icon: Icons.grain_rounded,
      color: Colors.amber,
    ),
    DietaryOption(
      label: 'Dairy-Free',
      enName: 'Dairy-Free',
      koName: '데어리프리',
      enDesc: 'Completely free of milk and dairy ingredients',
      koDesc: '우유 및 유제품 성분을 전혀 포함하지 않은 대안 식품',
      icon: Icons.cookie_rounded,
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLabels = List.from(widget.initialLabels);
  }

  Future<void> _handleSave() async {
    final isKo = LocalizationService.currentLanguage.value == 'ko';
    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'dietaryLabels': _selectedLabels});

      // 2. Update cached session model
      if (AuthService.currentUser?.uid == widget.userId) {
        final current = AuthService.currentUser!;
        AuthService.currentUser = UserModel(
          uid: current.uid,
          email: current.email,
          studentId: current.studentId,
          name: current.name,
          profileImageUrl: current.profileImageUrl,
          dietaryLabels: _selectedLabels,
          allergies: current.allergies,
          pushNotificationsEnabled: current.pushNotificationsEnabled,
          favoriteMenuIds: current.favoriteMenuIds,
          country: current.country,
          spiceTolerance: current.spiceTolerance,
          preferredTastes: current.preferredTastes,
          preferredLanguage: current.preferredLanguage,
          reviewCount: current.reviewCount,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isKo ? '선호 설정이 성공적으로 업데이트되었습니다!' : 'Preferences updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Failed to save dietary preferences: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isKo ? '설정 저장에 실패했습니다. 다시 시도해 주세요.' : 'Failed to save changes. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKo = LocalizationService.currentLanguage.value == 'ko';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          isKo ? '식단 선호도 설정' : 'Dietary Labels',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Options Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = _selectedLabels.contains(option.label);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLabels.remove(option.label);
                      } else {
                        _selectedLabels.add(option.label);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? option.color.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? option.color
                            : Colors.grey[200]!,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isSelected ? 0.04 : 0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? option.color.withOpacity(0.2)
                                    : option.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option.icon,
                                color: option.color,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              isKo ? option.koName : option.enName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isKo ? option.koDesc : option.enDesc,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Sticky Bottom Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94E5D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE94E5D).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isKo ? '설정 저장' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
