import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/auth/presentation/widgets/text_box.dart';

class LoginPage extends StatefulWidget {
  final bool showBackground;
  const LoginPage({super.key, this.showBackground = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController(
    text: "augustosalazar@uninorte.edu.co",
  );
  final passwordController = TextEditingController(text: "ThePassword!1.");

  Future<bool> _onLogin() async {
    try {
      await userController.login(
        emailController.text.trim(),
        passwordController.text,
      );
      Get.until((route) => route.isFirst);
      return true;
    } catch (err) {
      if (!Get.testMode) {
        Get.snackbar(
          'Login failed',
          'Invalid email or password',
          backgroundColor: const Color(0xFF3A2016),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: widget.showBackground
                ? const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's get you signed in",
                        style: GoogleFonts.madimiOne(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Sign in to your account",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextBox(
                        key: const Key('TextFormFieldLoginEmail'),
                        hintText: 'Email',
                        controller: emailController,
                        validatorFunc: () => (value) {
                          if (value!.isEmpty) {
                            return "Enter email";
                          } else if (!value.contains('@')) {
                            return "Enter valid email address";
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextBox(
                        key: const Key('TextFormFieldLoginPassword'),
                        hintText: 'Password',
                        validatorFunc: () => (value) {
                          if (value!.isEmpty) {
                            return "Enter password";
                          } else if (value.length < 6) {
                            return "Password should have at least 6 characters";
                          }
                          return null;
                        },
                        controller: passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        key: const Key('ButtonLoginSubmit'),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.7,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _onLogin();
                            }
                          },
                          child: Text(
                            'Log in',
                            style: GoogleFonts.madimiOne(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
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
