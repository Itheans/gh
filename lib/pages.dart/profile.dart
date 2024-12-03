import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile, name, email;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // ดึงข้อมูลผู้ใช้
  Future<void> getUserInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String defaultName = user.email?.split('@')[0] ?? 'No name';
        setState(() {
          name = user.displayName ?? defaultName;
          email = user.email ?? 'No email';
          profile = user.photoURL;

          nameController.text = name!;
          emailController.text = email!;
        });
      } else {
        setState(() {
          name = "No user logged in";
          email = "No user logged in";
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
      setState(() {
        name = "Error loading data";
        email = "Error loading data";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // อัปโหลดรูปภาพใหม่
  Future<void> getImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          selectedImage = File(pickedImage.path);
        });

        String addId = randomAlphaNumeric(10);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("profileImages").child(addId);

        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        var downloadUrl = await (await task).ref.getDownloadURL();

        await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'profilePic': downloadUrl,
        });

        setState(() {
          profile = downloadUrl;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      setState(() {
        profile = null;
      });
    }
  }

  // อัปเดตโปรไฟล์
  Future<void> updateProfile() async {
    String updatedName = nameController.text;

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updateDisplayName(updatedName);

        setState(() {
          name = updatedName;
        });

        print("Profile updated successfully.");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // รีเซ็ตโปรไฟล์กลับไปใช้ค่าเริ่มต้น
  Future<void> resetToDefaultProfile() async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(null);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profilePic': null});

      setState(() {
        profile = null;
      });
    } catch (e) {
      print("Error resetting profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.only(top: 45, left: 20, right: 20),
                        height: MediaQuery.of(context).size.height / 4.3,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(
                                MediaQuery.of(context).size.width, 105),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 6.5,
                          ),
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(60),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: profile == null
                                  ? GestureDetector(
                                      onTap: getImage,
                                      child: const Image(
                                        image: AssetImage('images/User.png'),
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.network(
                                      profile!,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Image(
                                          image: AssetImage('images/User.png'),
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: Center(
                          child: Text(
                            name ?? 'No name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Popins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildProfileInfoRow('Name', name!, Icons.person),
                  buildProfileInfoRow(
                      'E-mail', email ?? 'No email', Icons.mail),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: updateProfile,
                      child: const Text('Update Profile'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: resetToDefaultProfile,
                    child: const Text('Reset to Default Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildProfileInfoRow(String title, dynamic value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20),
              Expanded(
                child: value is TextEditingController
                    ? TextField(
                        controller: value,
                        decoration: InputDecoration(
                          labelText: title,
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
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
