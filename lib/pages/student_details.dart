import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StudentDetails extends StatefulWidget {
  final Map<String, dynamic> studentData;

  StudentDetails({required this.studentData});

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {

  String _email = '';
  String _accountType = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

   Future<void> _fetchUserData() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;


        setState(() {
          _accountType = (data['accountType'] as String).toUpperCase();
          _email = data['email_Address'];
        });
      } else {
        print('No document found for UID: $uid');
        setState(() {
          _accountType = 'Not Found';
        });
      }
    } else {
      print('No current user found.');
    }
  } catch (e) {
    print('Error fetching user data: $e');
    setState(() {
      _accountType = 'Error';
    });
  }
}

  @override
  Widget build(BuildContext context) {

    String combinedAddress = [
      widget.studentData['house_number'] ?? '',
      widget.studentData['street_name'] ?? '',
      widget.studentData['subdivision_barangay'] ?? '',
      widget.studentData['city_municipality'] ?? '',
      widget.studentData['province'] ?? '',
      widget.studentData['country'] ?? '',
    ].where((s) => s.isNotEmpty).join(', ');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), 
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor: Colors.white, // Set the background color to match the image
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 30),
            child: Row(
              children: [
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      size: 30,
                      Iconsax.profile_circle_copy,
                    ),
                    SizedBox(width: 15), // Add spacing between the icon and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_accountType',
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 16, // Smaller font size for the label
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                        Text(
                          _email,
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 14, // Smaller font size for the email
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Details',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        _buildDetailRow(Icons.tag, 'Student Number', widget.studentData['student_id'] ?? ''),
                        _buildDetailRow(Icons.email, 'Email Address', widget.studentData['email_Address'] ?? ''),
                        _buildDetailRow(Icons.location_on, 'Address', combinedAddress), 
                        _buildDetailRow(Icons.phone, 'Contact Number', widget.studentData['phone_number'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Birthday', widget.studentData['birthdate'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Age', widget.studentData['age'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Gender', widget.studentData['gender'] ?? ''),
                        _buildDetailRow(Icons.grade, 'Grade', widget.studentData['grade_level'] ?? ''),
                        _buildDetailRow(Icons.track_changes, 'Track', widget.studentData['seniorHigh_Track'] ?? ''),
                        _buildDetailRow(Icons.track_changes, 'Strand', widget.studentData['seniorHigh_Strand'] ?? ''),
                        _buildDetailRow(Icons.track_changes, 'Belonging to Indigenous People (IP) Group', widget.studentData['indigenous_group'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Father`s Name', widget.studentData['fathersName'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Mother`s Name', widget.studentData['mothersName'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Guardian`s Name', widget.studentData['guardianName'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Relationship to Guardian', widget.studentData['relationshipGuardian'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Junior High School', widget.studentData['juniorHS'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Address of JHS', widget.studentData['schoolAdd'] ?? ''),
                        _buildDetailRow(Icons.cake, 'Transferee', widget.studentData['transferee'] ?? ''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${widget.studentData['accountType']?.toUpperCase()}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                  onTap: () {
                   
                  },
                  child: widget.studentData['image_url'] != null
                      ? CircleAvatar(
                          radius: 100, 
                          backgroundImage: NetworkImage(widget.studentData['image_url']),
                        )
                      : CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(
                              'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                        ),
                ),
                      SizedBox(height: 16),
                      Text(
                        '${widget.studentData['first_name']} ${widget.studentData['middle_name']} ${widget.studentData['last_name']} ${widget.studentData['extension_name']}',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(widget.studentData['email_Address'] ?? ''),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
