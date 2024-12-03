import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myproject/pages.dart/cat_history.dart';

class SitterHomePage extends StatelessWidget {
  final CollectionReference cats =
      FirebaseFirestore.instance.collection('cats');

  Stream<QuerySnapshot> getCats() {
    return cats.where('status', isEqualTo: 'available').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บ้านที่ดูแล'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cats.where('status', isEqualTo: 'available').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('ไม่มีแมวในระบบ'));
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final cat = data[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(cat['image']),
                ),
                title: Text(cat['name']),
                subtitle: Text('เจ้าของ: ${cat['ownerID']}'),
                onTap: () {
                  // เปิดหน้า Cat Details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CatDetailsPage(catID: data[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CatDetailsPage extends StatelessWidget {
  final String catID;

  CatDetailsPage({required this.catID});

  @override
  Widget build(BuildContext context) {
    final DocumentReference catDoc =
        FirebaseFirestore.instance.collection('cats').doc(catID);

    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดแมว'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: catDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('ไม่พบข้อมูล'));
          }

          final cat = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(cat['image']),
                SizedBox(height: 16),
                Text(
                  cat['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('เจ้าของ: ${cat['ownerID']}'),
                Text('สถานะ: ${cat['status']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'บ้านที่ดูแล',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Caretakers
            Text(
              "บ้านที่ดูแล",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildMinimalTile('คุณเป็ด', 'images/duck.jpg', context),
                  _buildMinimalTile(
                      'คุณเพนกวิน', 'images/penguin.jpg', context),
                ],
              ),
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 16),

            // Section: Reviews
            Text(
              "รีวิว",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "4.5",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber, size: 48),
              ],
            ),
            SizedBox(height: 10),
            _buildReviewMinimalRow('คุณเพนกวิน', 5, 'images/penguin.jpg'),
            _buildReviewMinimalRow('คุณเป็ด', 4, 'images/duck.jpg'),
            _buildReviewMinimalRow('คุณแมว', 3, 'images/cat1.png'),
          ],
        ),
      ),
    );
  }

  // Minimal Caretaker Tile
  Widget _buildMinimalTile(
      String name, String imagePath, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CatHistoryPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: const Color.fromARGB(255, 198, 196, 196), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Minimal Review Row
  Widget _buildReviewMinimalRow(String name, int stars, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 15),
                Row(
                  children: List.generate(
                    stars,
                    (index) => Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CaretakerDetailsPage extends StatelessWidget {
  final String name;
  final String imagePath;

  CaretakerDetailsPage({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset(imagePath),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Add more details here
          ],
        ),
      ),
    );
  }
}
