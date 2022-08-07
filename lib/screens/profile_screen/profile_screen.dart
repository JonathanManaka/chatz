import 'dart:developer';

import 'package:chatz/constants/text_styles.dart';
import 'package:chatz/constants/ui_styles.dart';
import 'package:chatz/routes/router.dart';
import 'package:chatz/screens/profile_screen/widgets/profile_info_row.dart';
import 'package:chatz/screens/profile_screen/widgets/profile_image_row.dart';
import 'package:chatz/widgets/app_bar.dart';
import 'package:chatz/widgets/reusable_dialog.dart';
import 'package:chatz/widgets/reusable_elevated_button.dart';
import 'package:chatz/widgets/reusable_outline_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, this.userData}) : super(key: key);

  final AsyncSnapshot<dynamic>? userData;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();

  String? value;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Your Profile'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Are you sure you want to sign out?',
                      style: TextStyles.style14,
                    ),
                    actions: [
                      const ReusableOutlineButton(text: 'Cancel'),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: ReusableElevatedButton(
                          text: 'Continue',
                          function: () {
                            signOut().then(
                              (value) => Navigator.pushReplacementNamed(
                                  context, AppRouter.landingScreen),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: firestore.collection('users').doc(_user!.uid).snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            var userData = snapshot.data;
            if (snapshot.hasError) {
              log('Error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: 120,
                    left: 20,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: UIStyles.profileDecoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          Text(
                            userData['name'] ?? '',
                            style: TextStyles.style18Bold,
                          ),
                          const SizedBox(height: 5),
                          ProfileInfoRow(
                            userData: userData,
                            userKey: 'Name:',
                            userValue: userData['name'] ?? '',
                            isChangeable: true,
                            function: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ReusableDialog(
                                      nameController: _nameController,
                                      hintText: 'Enter new name..',
                                      header: 'Update name',
                                      onUpdate: () {
                                        updateName().then(
                                            (value) => Navigator.pop(context));
                                      },
                                    );
                                  });
                            },
                          ),
                          const Divider(thickness: 1),
                          ProfileInfoRow(
                            userData: userData,
                            userKey: 'Email:',
                            userValue: userData['email'] ?? '',
                          ),
                          const SizedBox(height: 5),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 60,
                    child: ProfileImageRow(userData: userData),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future updateName() {
    var newName = firestore
        .collection('users')
        .doc(_user!.uid)
        .update({'name': _nameController.text});
    return newName;
  }
}
