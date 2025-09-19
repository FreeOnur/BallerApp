import 'package:baller_app/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordHidden = true;

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'BallUp',
                style: TextStyle(
                  color: Color.fromRGBO(231, 85, 39, 100),
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double logoSize = constraints.maxWidth * 0.45;
                  return Icon(
                    Icons.sports_basketball_rounded,
                    size: logoSize,
                    color: const Color.fromRGBO(231, 85, 39, 100),
                  );
                },
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      // --- Email Field ---
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Colors.white),
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: const TextStyle(fontSize: 20),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(231, 85, 39, 100),
                            ),
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromRGBO(231, 85, 39, 100),
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // --- Password Field ---
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _passwordController,
                        obscureText: _isPasswordHidden, // <<< wichtig
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Password',
                          labelStyle: const TextStyle(fontSize: 20),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(231, 85, 39, 100),
                            ),
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromRGBO(231, 85, 39, 100),
                            fontSize: 20,
                          ),
                          // <<< Toggle Icon
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordHidden = !_isPasswordHidden;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // --- Login Button ---
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.09,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromRGBO(
                              231,
                              85,
                              39,
                              100,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              print("Alles ok!");
                              login();
                            }
                          },
                          child: Center(
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenHeight * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      GestureDetector(
                        onTap: () {
                          // Handle forgot password action
                        },
                        child: Text(
                          "Forgot your password?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenHeight * 0.02,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // --- Sign Up Link ---
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenHeight * 0.02,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
