import 'package:baller_app/auth/auth_service.dart';
import 'package:baller_app/pages/AuthenthicationPage/Register/profile_creation_page.dart';
import 'package:baller_app/pages/AuthenthicationPage/Register/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordHidden = true;

  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if(password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match!")));
      return;
    }

    try {
      await authService.signUp(email, password);
      if(mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const ProfileCreationPage(),),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
        return;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(15, 15, 15, 100),
        foregroundColor: Color.fromRGBO(231, 85, 39, 100),
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
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

                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _confirmPasswordController,
                        obscureText: _isPasswordHidden, // <<< wichtig
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Confirm Password',
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
                            return 'Please enter your password again';
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
                              signUp();
                            }
                          },
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenHeight * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // --- Sign Up Link ---
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:(context) => 
                              LoginPage()
                            ));
                        },
                        child: Text(
                          "Already have an Account? Login",
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