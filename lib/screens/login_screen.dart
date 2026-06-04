import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_navigation.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your campus email"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your password"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await AuthService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome back, ${AuthService.currentUser?.name}!"),
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
          SnackBar(
            content: Text(
              "Account not found for $email.\nHint: Use 'student1@handong.ac.kr' or Sign Up!",
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: "SIGN UP",
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      if (mounted) {
        if (result.isNewUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Google authentication successful! Please complete your profile."),
              backgroundColor: Colors.blueAccent,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpScreen(
                initialName: result.name,
                initialEmail: result.email,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome back, ${AuthService.currentUser?.name}!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      }
    } else {
      if (mounted) {
        if (result.errorMessage != "Google sign-in cancelled by user.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? "Failed to sign in with Google."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              
              // --- 1. Header Section ---
              const Text(
                "HandongEats",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.redAccent,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to see today's menu",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              // --- 2. Input Fields ---
              Text("CAMPUS EMAIL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "student1@handong.ac.kr",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              Text("PASSWORD", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  // Password visibility toggle
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

              // --- 3. Forgot Password Link ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // --- 4. Main Sign In Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),

              // --- 5. Alternative Login Methods ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[200], thickness: 1.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("OR CONTINUE WITH", style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[200], thickness: 1.5)),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.png",
                        height: 22,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 6. Sign Up Link ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text("Sign Up", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}