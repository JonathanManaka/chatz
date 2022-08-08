import 'package:chatz/constants/colors.dart';
import 'package:chatz/constants/text_styles.dart';
import 'package:chatz/data/models/user_model.dart';
import 'package:chatz/routes/router.dart';
import 'package:chatz/screens/chat_screen/chat_screen.dart';
import 'package:chatz/screens/home_screen/widgets/chat_tile_body.dart';
import 'package:chatz/screens/search_screen/search_screen.dart';
import 'package:chatz/widgets/app_bar.dart';
import 'package:chatz/widgets/circle_icon_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.idUser}) : super(key: key);
  final String? idUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        title: const Text('Your Chatz'),
        actions: [
          InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRouter.profileScreen);
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 20,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: ConstColors.darkerCyan,
                  ),
                ),
              ))
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: const Text(
                  'Your friends',
                  style: TextStyles.style16Bold,
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: firestore.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No users found'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var users = snapshot.data!.docs[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return ChatScreen(
                                    user: UserModel(
                                        email: users['name'],
                                        imgUrl: users['imgUrl'],
                                        lastMessage:
                                            users['lastMessage'].toDate(),
                                        name: users['name'],
                                        uid: users['uid']),
                                    //idUser: users.id,
                                  );
                                }),
                              );
                            },
                            child: ChatTileBody(
                              name: users['name'],
                              image: users['imgUrl'],
                              message: '',
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
          BoxShadow(
            color: Colors.grey.shade600,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ]),
        child: CircleIconBtn(
            btnColor: ConstColors.redOrange,
            iconColor: Colors.black,
            height: 56,
            icon: Icons.add,
            onTapped: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            }),
      ),
    );
  }
}
