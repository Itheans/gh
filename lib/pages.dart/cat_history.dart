import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CatHistoryPage(),
    );
  }
}

class CatHistoryPage extends StatefulWidget {
  const CatHistoryPage({Key? key}) : super(key: key);

  @override
  _CatHistoryPageState createState() => _CatHistoryPageState();
}

class _CatHistoryPageState extends State<CatHistoryPage> {
  List<Cat> cats = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cats')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          cats = snapshot.docs.map((doc) => Cat.fromFirestore(doc)).toList();
        });
      });
    }
  }

  void addCatToFirestore(Cat cat) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cats')
            .add(cat.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cat added successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error adding cat: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add cat')),
        );
      }
    } else {
      print('User not logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add cats')),
      );
    }
  }

  void updateCatInFirestore(Cat cat) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cats')
            .doc(cat.id)
            .update(cat.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cat updated successfully')),
        );
      } catch (e) {
        print('Error updating cat: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update cat')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat History'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddCatDialog(onAdd: addCatToFirestore),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: cats.length,
          itemBuilder: (context, index) {
            final cat = cats[index];
            return CatCard(
              cat: cat,
              onEdit: (updatedCat) {
                showDialog(
                  context: context,
                  builder: (context) => AddCatDialog(
                    cat: updatedCat,
                    onAdd: updateCatInFirestore,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class Cat {
  String id;
  final String name;
  final DateTime birthDate;
  final String description;
  final String imagePath;

  Cat({
    this.id = '',
    required this.name,
    required this.birthDate,
    required this.description,
    required this.imagePath,
  });

  factory Cat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cat(
      id: doc.id,
      name: data['name'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      description: data['description'],
      imagePath: data['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'description': description,
      'imagePath': imagePath,
    };
  }
}

class CatCard extends StatelessWidget {
  final Cat cat;
  final Function(Cat) onEdit;

  const CatCard({Key? key, required this.cat, required this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(cat.birthDate).inDays ~/ 365;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: cat.imagePath.startsWith('http')
                  ? Image.network(
                      cat.imagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(cat.imagePath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Age: $age years',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(cat),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCatDialog extends StatefulWidget {
  final Function(Cat) onAdd;
  final Cat? cat;

  const AddCatDialog({Key? key, required this.onAdd, this.cat})
      : super(key: key);

  @override
  _AddCatDialogState createState() => _AddCatDialogState();
}

class _AddCatDialogState extends State<AddCatDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? birthDate;
  String? imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cat != null) {
      nameController.text = widget.cat!.name;
      descriptionController.text = widget.cat!.description;
      birthDate = widget.cat!.birthDate;
      imagePath = widget.cat!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cat == null ? 'Add New Cat' : 'Edit Cat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: birthDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    birthDate = selectedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Birth Date'),
                child: Text(
                  birthDate != null
                      ? DateFormat('yyyy-MM-dd').format(birthDate!)
                      : 'Select Date',
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: imagePath == null
                  ? const Text('Tap to select an image')
                  : Image.file(
                      File(imagePath!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (birthDate == null || imagePath == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please complete all fields'),
                ),
              );
              return;
            }
            final newCat = Cat(
              id: widget.cat?.id ?? '',
              name: nameController.text.trim(),
              birthDate: birthDate!,
              description: descriptionController.text.trim(),
              imagePath: imagePath!,
            );
            widget.onAdd(newCat);
          },
          child: Text(widget.cat == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
