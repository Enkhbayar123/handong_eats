import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/localization.dart';

class AllergyOption {
  final String label;
  final String enName;
  final String koName;
  final String enDesc;
  final String koDesc;
  final IconData icon;
  final Color color;

  AllergyOption({
    required this.label,
    required this.enName,
    required this.koName,
    required this.enDesc,
    required this.koDesc,
    required this.icon,
    required this.color,
  });
}

class AllergiesScreen extends StatefulWidget {
  final String userId;
  final List<String> initialAllergies;

  const AllergiesScreen({
    super.key,
    required this.userId,
    required this.initialAllergies,
  });

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  late List<String> _selectedAllergies;
  bool _isSaving = false;

  final List<AllergyOption> _options = [
    AllergyOption(
      label: 'Peanuts',
      enName: 'Peanuts',
      koName: '땅콩',
      enDesc: 'Includes peanut oil, peanut butter, and raw peanuts',
      koDesc: '땅콩 오일, 땅콩 버터 및 가공 땅콩 성분 포함',
      icon: Icons.warning_amber_rounded,
      color: Colors.brown,
    ),
    AllergyOption(
      label: 'Tree Nuts',
      enName: 'Tree Nuts',
      koName: '견과류',
      enDesc: 'Almonds, walnuts, cashews, pecans, and hazelnuts',
      koDesc: '아몬드, 호두, 캐슈넛, 피칸, 헤이즐넛 등 나무 견과류',
      icon: Icons.nature_people_rounded,
      color: Colors.deepOrange,
    ),
    AllergyOption(
      label: 'Shellfish',
      enName: 'Shellfish',
      koName: '갑각류/조개류',
      enDesc: 'Shrimp, crab, lobster, oysters, clams, and mussels',
      koDesc: '새우, 게, 가재, 조개, 굴, 홍합 등 수산물 성분',
      icon: Icons.waves_rounded,
      color: Colors.redAccent,
    ),
    AllergyOption(
      label: 'Eggs',
      enName: 'Eggs',
      koName: '계란',
      enDesc: 'Whole eggs, whites, yolks, and egg derivatives',
      koDesc: '달걀, 흰자/노른자 및 알가공 성분 포함',
      icon: Icons.egg_rounded,
      color: Colors.amber[800]!,
    ),
    AllergyOption(
      label: 'Wheat',
      enName: 'Wheat',
      koName: '밀',
      enDesc: 'Wheat flour, bran, gluten, and bakery products',
      koDesc: '밀가루, 밀 배아, 글루텐 및 밀 함유 가공품',
      icon: Icons.grain_rounded,
      color: Colors.orange,
    ),
    AllergyOption(
      label: 'Soy',
      enName: 'Soy',
      koName: '대두/콩',
      enDesc: 'Soybeans, soy milk, tofu, soy sauce, and edamame',
      koDesc: '콩, 대두유, 두부, 두유, 간장 등 콩 함유 식품',
      icon: Icons.spa_rounded,
      color: Colors.green,
    ),
    AllergyOption(
      label: 'Milk',
      enName: 'Milk',
      koName: '우유',
      enDesc: 'Cow\'s milk, butter, cheese, yogurt, and whey protein',
      koDesc: '우유, 버터, 치즈, 요거트, 유청 및 유제품 성분',
      icon: Icons.water_drop_rounded,
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAllergies = List.from(widget.initialAllergies);
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
          .update({'allergies': _selectedAllergies});

      // 2. Update cached session model
      if (AuthService.currentUser?.uid == widget.userId) {
        final current = AuthService.currentUser!;
        AuthService.currentUser = UserModel(
          uid: current.uid,
          email: current.email,
          studentId: current.studentId,
          name: current.name,
          profileImageUrl: current.profileImageUrl,
          dietaryLabels: current.dietaryLabels,
          allergies: _selectedAllergies,
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
      debugPrint("Failed to save allergy preferences: $e");
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
          isKo ? '알레르기 설정' : 'Allergies',
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
                final isSelected = _selectedAllergies.contains(option.label);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAllergies.remove(option.label);
                      } else {
                        _selectedAllergies.add(option.label);
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
                                color: Colors.black87,
                              ),
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
