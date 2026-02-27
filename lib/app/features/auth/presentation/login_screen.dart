import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_manegement_app/app/auth_gate.dart';
import 'package:service_manegement_app/app/features/auth/data/auth_service.dart';
import 'package:service_manegement_app/app/features/auth/presentation/signup_screen.dart';
import 'package:service_manegement_app/core/ui/snack.dart';
import 'package:service_manegement_app/core/ui/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoadin = false;
  bool isPasswordHidden = true;

  void _logIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (!mounted) return;
    setState(() {
      isLoadin = true;
    });
    final result = await _authService.login(email, password);
    if (result == null) {
      // success case
      if (!mounted) return;
      setState(() {
        isLoadin = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthGate()),
        // MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      if (!mounted) return;
      setState(() {
        isLoadin = false;
      });
      showSnackBar(context, "Signup Failed:$result", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                // inpute field for email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                // password
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: isPasswordHidden,
                ),
                SizedBox(height: 20),
                isLoadin
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.maxFinite,
                        child: PrimaryButton(
                          onTap: _logIn,
                          buttontext: "Login",
                        ),
                      ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        );
                      },
                      child: Text(
                        "Signup here",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
