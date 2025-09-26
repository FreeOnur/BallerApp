import 'package:baller_app/pages/AuthenthicationPage/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _resetTokenController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  bool _isLoading = false;
  void ResetPassword() async{
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final resetToken = _resetTokenController.text;
    // Implement your reset password logic here
    try{
      final recovery = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: resetToken,
        type: OtpType.recovery
      );
      print(recovery);
      if(password == confirmPassword) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: password)
        );
      } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match!")));
          return;
      }
      _isLoading = false;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      await ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset successful! Please log in with your new password.")));
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
        foregroundColor: Color.fromRGBO(231, 85, 39, 100),
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _resetTokenController,
                  decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Reset Token',
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
                ),validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reset token';
                  }
                  return null;
                },
              ),
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
              TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _passwordController,
                obscureText: _isPasswordHidden, // <<< wichtig
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'New Password',
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
                      _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
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
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Confirm New Password',
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
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
              width: double.infinity,
              height: screenHeight * 0.09,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formkey.currentState!.validate()) {
                    _isLoading = true;
                    showGeneralDialog(
                      context:context,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                      Center(child: CircularProgressIndicator())
                      );
                    ResetPassword();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields correctly.")));
                  }
                },
                child: Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.03,
                    ),
                  ),
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
