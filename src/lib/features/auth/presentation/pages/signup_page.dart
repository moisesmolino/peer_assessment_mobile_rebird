import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loggy/loggy.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/auth/presentation/widgets/text_box.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  //final _registerKey = GlobalKey<FormState>();
  //final _validationKey = GlobalKey<FormState>();

  final userController = Get.find<UserController>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool registerPhase = true;

  Future<void> _signup(
    String theName,
    String theEmail,
    String thePassword,
    bool direct,
  ) async {
    try {
      await userController.signUp(theName, theEmail, thePassword, direct);

      if (direct) {
        Get.snackbar(
          "Sign Up",
          'User created successfully',
          icon: const Icon(Icons.person, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      setState(() => registerPhase = false);

      Get.snackbar(
        "Sign Up",
        'User created successfully, check your email for verification',
        icon: const Icon(Icons.person, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (err) {
      logError('SignUp error $err');
      Get.snackbar(
        "Sign Up",
        err.toString(),
        icon: const Icon(Icons.person, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 50),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.5,
              ), // opcional para oscurecer
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Signup",
                      style: GoogleFonts.madimiOne(
                        fontSize: 50,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Create your account",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),

                    TextBox(hintText: 'Name', controller: nameController),
                    SizedBox(height: 20),
                    TextBox(hintText: 'Email', controller: emailController),
                    SizedBox(height: 20),
                    TextBox(
                      hintText: 'Password',
                      controller: passwordController,
                      obscureText: true,
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.7),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _signup(
                            nameController.text,
                            emailController.text.trim(),
                            passwordController.text,
                            true,
                          );
                        },
                        child: Text(
                          'Test Login',
                          style: GoogleFonts.madimiOne(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
