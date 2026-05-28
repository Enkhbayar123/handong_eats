import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_navigation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  bool _obscurePassword = true;

  // Step 2 Selection
  String _selectedCountry = 'South Korea';
  String _selectedSpiceTolerance = 'Medium';
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _countries = [
    {'name': 'South Korea', 'flag': '🇰🇷'},
    {'name': 'Mongolia', 'flag': '🇲🇳'},
    {'name': 'United States', 'flag': '🇺🇸'},
    {'name': 'Vietnam', 'flag': '🇻🇳'},
    {'name': 'China', 'flag': '🇨🇳'},
    {'name': 'Uzbekistan', 'flag': '🇺🇿'},
    {'name': 'Philippines', 'flag': '🇵🇭'},
    {'name': 'Indonesia', 'flag': '🇮🇩'},
    {'name': 'Cambodia', 'flag': '🇰🇭'},
    {'name': 'Thailand', 'flag': '🇹🇭'},
    {'name': 'Russia', 'flag': '🇷🇺'},
    {'name': 'Kazakhstan', 'flag': '🇰🇿'},
    {'name': 'Japan', 'flag': '🇯🇵'},
    {'name': 'India', 'flag': '🇮🇳'},
  ];

  final List<Map<String, dynamic>> _spiceLevels = [
    {'name': 'None', 'peppers': 0, 'desc': 'No spice at all'},
    {'name': 'Mild', 'peppers': 1, 'desc': 'A tiny warm kick'},
    {'name': 'Medium', 'peppers': 2, 'desc': 'Comfortably spicy'},
    {'name': 'Hot', 'peppers': 3, 'desc': 'Intense fiery heat'},
    {'name': 'Extremely Spicy', 'peppers': 4, 'desc': 'For spicy champions'},
  ];

  // Step 3 Selection
  final List<String> _dietaryLabels = ['Halal', 'Vegetarian', 'Vegan', 'Lactose-Free', 'Gluten-Free', 'Dairy-Free'];
  final List<String> _allergies = ['Peanuts', 'Tree Nuts', 'Shellfish', 'Eggs', 'Wheat', 'Soy', 'Milk'];
  final List<Map<String, String>> _flavors = [
    {'name': 'Sweet', 'emoji': '🍭'},
    {'name': 'Salty', 'emoji': '🧂'},
    {'name': 'Spicy', 'emoji': '🌶️'},
    {'name': 'Sour', 'emoji': '🍋'},
    {'name': 'Savory', 'emoji': '🥩'},
    {'name': 'Bitter', 'emoji': '☕'},
  ];

  final List<String> _selectedDietary = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedFlavors = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitSignUp() async {
    setState(() {
      _isLoading = true;
    });

    final success = await AuthService.signUp(
      email: _emailController.text,
      name: _nameController.text,
      studentId: _studentIdController.text,
      country: _selectedCountry,
      spiceTolerance: _selectedSpiceTolerance,
      dietaryLabels: _selectedDietary,
      allergies: _selectedAllergies,
      preferredTastes: _selectedFlavors,
      preferredLanguage: _selectedLanguage,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Handong Eats, ${_nameController.text}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign up. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- STEPPER PROGRESS DISPLAY ---
            _buildStepperProgress(),
            const SizedBox(height: 16),

            // --- MULTI-STEP SLIDING PAGES ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Control via buttons
                onPageChanged: (int page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                children: [
                  _buildStep1Credentials(),
                  _buildStep2OriginAndSpice(),
                  _buildStep3DietaryAndTaste(),
                ],
              ),
            ),

            // --- BOTTOM NAVIGATION BUTTONS ---
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: STEPPER PROGRESS ---
  Widget _buildStepperProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          _buildStepCircle(0, "Credentials"),
          _buildStepConnector(1),
          _buildStepCircle(1, "Origin"),
          _buildStepConnector(2),
          _buildStepCircle(2, "Preferences"),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.redAccent
                : (isActive ? Colors.redAccent.withOpacity(0.8) : Colors.grey[200]),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: Colors.redAccent.shade100, width: 4)
                : null,
          ),
          child: Center(
            child: Icon(
              step == 0
                  ? Icons.person
                  : step == 1
                      ? Icons.flag
                      : Icons.restaurant,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 3,
        margin: const EdgeInsets.only(bottom: 14),
        color: isActive ? Colors.redAccent : Colors.grey[200],
      ),
    );
  }

  // --- WIDGET: CREDENTIALS PAGE (STEP 1) ---
  Widget _buildStep1Credentials() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's get started with your basic information",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Full Name Input
            Text("FULL NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
              decoration: InputDecoration(
                hintText: "E.g., Jack Smith",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Student ID Input
            Text("STUDENT ID (8 DIGITS)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _studentIdController,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return "Student ID is required";
                if (val.length != 8) return "Student ID must be exactly 8 digits";
                return null;
              },
              decoration: InputDecoration(
                hintText: "E.g., 22400123",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
                prefixIcon: const Icon(Icons.numbers, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Email Input
            Text("CAMPUS EMAIL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.isEmpty) return "Email is required";
                if (!val.contains('@')) return "Please enter a valid email";
                return null;
              },
              decoration: InputDecoration(
                hintText: "student@handong.ac.kr",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Password Input
            Text("PASSWORD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (val) {
                if (val == null || val.isEmpty) return "Password is required";
                if (val.length < 6) return "Password must be at least 6 characters";
                return null;
              },
              decoration: InputDecoration(
                hintText: "••••••••",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: ORIGIN & SPICE (STEP 2) ---
  Widget _buildStep2OriginAndSpice() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Food & Origin Profile",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            "This maps your background to recommend equivalent comfort foods!",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Country Selector Dropdown
          Text("HOME COUNTRY / CULTURE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent),
                borderRadius: BorderRadius.circular(16),
                dropdownColor: Colors.white,
                items: _countries.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['name'],
                    child: Row(
                      children: [
                        Text(c['flag'] ?? '', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(
                          c['name'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCountry = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Preferred Language Selector Cards
          Text("PREFERRED DESCRIPTION LANGUAGE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'English';
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedLanguage == 'English' ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedLanguage == 'English' ? Colors.redAccent : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "🇬🇧 English",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _selectedLanguage == 'English' ? Colors.red[900] : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'Korean';
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedLanguage == 'Korean' ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedLanguage == 'Korean' ? Colors.redAccent : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "🇰🇷 한국어",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _selectedLanguage == 'Korean' ? Colors.red[900] : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Spice Meter Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SPICE TOLERANCE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
              Text(
                _selectedSpiceTolerance.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: _spiceLevels.map((lvl) {
              final isSelected = _selectedSpiceTolerance == lvl['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpiceTolerance = lvl['name'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.redAccent : Colors.grey[200]!,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Pepper Count Icons
                      SizedBox(
                        width: 115,
                        child: Row(
                          children: [
                            if (lvl['peppers'] == 0)
                              Text("🍃", style: TextStyle(fontSize: 18, color: Colors.green[600]))
                            else
                              ...List.generate(
                                lvl['peppers'],
                                (index) => const Padding(
                                  padding: EdgeInsets.only(right: 1.0),
                                  child: Text("🌶️", style: TextStyle(fontSize: 16)),
                                ),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Text Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lvl['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected ? Colors.red[900] : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lvl['desc'],
                              style: TextStyle(
                                color: isSelected ? Colors.red[700] : Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Check icon
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.redAccent)
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- WIDGET: DIETARY & FLAVORS (STEP 3) ---
  Widget _buildStep3DietaryAndTaste() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preferences & Taste",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            "Customize warnings and highlight dishes matching your taste profile!",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 28),

          // Dietary Labels Choice Chips
          Text("DIETARY PREFERENCES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _dietaryLabels.map((lbl) {
              final isSelected = _selectedDietary.contains(lbl);
              return FilterChip(
                label: Text(lbl),
                selected: isSelected,
                selectedColor: Colors.green[100],
                checkmarkColor: Colors.green[800],
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green[900] : Colors.black87,
                  fontSize: 13,
                ),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Colors.green.shade400 : Colors.transparent),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDietary.add(lbl);
                    } else {
                      _selectedDietary.remove(lbl);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Allergies Chips
          Text("FOOD ALLERGIES (WARNING FILTERS)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _allergies.map((alg) {
              final isSelected = _selectedAllergies.contains(alg);
              return FilterChip(
                label: Text(alg),
                selected: isSelected,
                selectedColor: Colors.orange[100],
                checkmarkColor: Colors.orange[800],
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.orange[900] : Colors.black87,
                  fontSize: 13,
                ),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Colors.orange.shade400 : Colors.transparent),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAllergies.add(alg);
                    } else {
                      _selectedAllergies.remove(alg);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Flavor Profile Custom Selection Cards
          Text("FAVORITE FLAVOR PROFILE (SELECT MULTIPLE)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _flavors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final item = _flavors[index];
              final isSelected = _selectedFlavors.contains(item['name']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFlavors.remove(item['name']);
                    } else {
                      _selectedFlavors.add(item['name']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.redAccent : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['emoji'] ?? '',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.red[900] : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- WIDGET: BOTTOM NAV BUTTONS ---
  Widget _buildBottomButtons() {
    final isLastStep = _currentStep == 2;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _prevStep,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (isLastStep ? _submitSignUp : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isLastStep ? "Complete Sign Up" : "Continue",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
