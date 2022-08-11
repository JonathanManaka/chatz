import 'dart:developer';
import 'dart:io';

import 'package:chatz/constants/colors.dart';
import 'package:chatz/constants/validations.dart';
import 'package:chatz/routes/router.dart';
import 'package:chatz/screens/auth_screens/widgets/add_image_icon.dart';
import 'package:chatz/screens/auth_screens/widgets/auth_button.dart';

import 'package:chatz/screens/auth_screens/widgets/bottom_bar.dart';
import 'package:chatz/services/firebase.dart';
import 'package:chatz/widgets/reusable_bottom_sheet.dart';
import 'package:chatz/widgets/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final Validations validations = Validations();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  File? pickedImage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ListView(children: [
                    const SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/arrow.png',
                          height: 40,
                        ),
                        const SizedBox(width: 20),
                        Stack(children: [
                          CircleAvatar(
                            radius: 47,
                            backgroundColor: ConstColors.black87,
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: ConstColors.lightBlueCyan,
                              backgroundImage: pickedImage == null
                                  ? null
                                  : FileImage(pickedImage!),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    isDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return ReusableBottomSheet(
                                        fromCamera: () {
                                          pickImageFromCamera();
                                          Navigator.pop(context);
                                        },
                                        fromGallery: () {
                                          pickImageFromGallery();
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              },
                              child: const AddImageIcon(
                                iconSize: 14,
                                backgroundColor: ConstColors.white,
                                iconColor: ConstColors.black87,
                              ),
                            ),
                          )
                        ]),
                        const SizedBox(width: 20),
                        RotatedBox(
                          quarterTurns: 2,
                          child: Image.asset(
                            'assets/arrow.png',
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    AuthTextField(
                      labelText: 'Username',
                      controller: nameController,
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{3,}$');
                        if (value!.isEmpty) {
                          return validations.nameValidation;
                        }
                        if (!regex.hasMatch(value)) {
                          return (validations.unvalidName);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                        labelText: 'Email address',
                        controller: emailController,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return validations.emailValidation;
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(val)) {
                            return (validations.emailValidation);
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    AuthTextField(
                        labelText: 'Password',
                        controller: passwordController,
                        obscureText: true,
                        validator: (val) {
                          RegExp regex = RegExp(r'^.{6,}$');
                          if (val!.isEmpty) {
                            return validations.passwordValidation;
                          }
                          if (!regex.hasMatch(val)) {
                            return (validations.unvalidPassword);
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    AuthTextField(
                      labelText: 'Re-type Password',
                      controller: confirmController,
                      obscureText: true,
                      validator: (value) {
                        if (confirmController.text != passwordController.text) {
                          return validations.passwordNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthButton(
                      mainText: 'Already registered? ',
                      subText: 'Login here!',
                      function: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.signIncreen,
                        );
                      },
                    )
                  ]),
                ),
              ),
            ),
            if (!isKeyboardVisible)
              AuthBottomBar(
                  mainText: 'Save and Continue',
                  subText: 'Your data must be real',
                  onTapped: () {
                    if (_formKey.currentState!.validate()) {
                      FirebaseService()
                          .registerUser(
                              userName: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              confirmPassword: confirmController.text,
                              profileImg: pickedImage!,
                              context: context)
                          .then((value) => Navigator.pushNamedAndRemoveUntil(
                              context, AppRouter.homeScreen, (route) => false));
                    }
                  })
          ]),
        ),
      ),
    );
  }

  void pickImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = File(image!.path);
    });
  }

  void pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(image!.path);
    });
  }
}
