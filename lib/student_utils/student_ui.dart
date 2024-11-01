// ignore_for_file: unused_element

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbma_portal/student_utils/cases/case0.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';
import 'package:sidebarx/sidebarx.dart';

class StudentUI extends StatefulWidget {
  const StudentUI({super.key});

  @override
  State<StudentUI> createState() => _StudentUIState();
}

class _StudentUIState extends State<StudentUI> {
  final SidebarXController _sidebarController =
      SidebarXController(selectedIndex: 0);
  final ValueNotifier<String?> _imageNotifier = ValueNotifier<String?>(null);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  String selectedSemester = 'SELECT SEMESTER';
  final Map<String, TextEditingController> gradeControllers = {
    'subject1': TextEditingController(),
    'subject2': TextEditingController(),
    'subject3': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadInitialProfileImage();
  }

  Future<void> _loadInitialProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final docSnapshot = await userDoc.get();
      final imageUrl = docSnapshot.data()?['image_url'];
      _imageNotifier.value = imageUrl; // Set initial profile picture URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _key,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: canvasColor,
              title: Text(
                "Student Dashboard",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () {
                  _key.currentState?.openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      drawer: isSmallScreen
          ? ExampleSidebarX(
              controller: _sidebarController,
              imageNotifier: _imageNotifier, // Pass imageNotifier here
            )
          : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            ExampleSidebarX(
              controller: _sidebarController,
              imageNotifier: _imageNotifier, // Pass imageNotifier here as well
            ),
          Expanded(
            child: Center(
              child: _ScreensExample(
                controller: _sidebarController,
                selectedSemester: selectedSemester,
                onSemesterChanged: (newValue) {
                  setState(() {
                    selectedSemester = newValue;
                  });
                },
                gradeControllers: gradeControllers,
                imageNotifier:
                    _imageNotifier, // Pass imageNotifier to _ScreensExample
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExampleSidebarX extends StatefulWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
    required this.imageNotifier,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;
  final ValueNotifier<String?> imageNotifier;

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  @override
  void initState() {
    super.initState();
    _loadStudentData();

    // Listen to changes in imageNotifier
    widget.imageNotifier.addListener(() {
      setState(() {}); // Rebuild when imageNotifier updates
    });
  }

  String? _studentId;
  String? _imageUrl; // Variable to store the student's image URL

  Future<void> _loadStudentData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          setState(() {
            _studentId = userDoc['student_id'];
            widget.imageNotifier.value = userDoc['image_url'];
          });
        } else {
          print('No matching student document found.');
        }
      } catch (e) {
        print('Failed to load student data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 1, 93, 168),
      child: SidebarX(
        controller: widget._controller,
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(20),
          ),
          hoverColor: scaffoldBackgroundColor,
          textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          selectedTextStyle: const TextStyle(color: Colors.white),
          hoverTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          itemTextPadding: const EdgeInsets.only(left: 30),
          selectedItemTextPadding: const EdgeInsets.only(left: 30),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: canvasColor),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actionColor.withOpacity(0.37),
            ),
            gradient: const LinearGradient(
              colors: [accentCanvasColor, canvasColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 30,
              )
            ],
          ),
          iconTheme: IconThemeData(
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          selectedIconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          ),
        ),
        extendedTheme: const SidebarXTheme(
          width: 200,
          decoration: BoxDecoration(
            color: canvasColor,
          ),
        ),
        footerDivider: divider,
        headerBuilder: (context, extended) {
          return SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: widget.imageNotifier.value != null
                        ? NetworkImage(widget.imageNotifier.value!)
                        : NetworkImage(
                            'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                  ),
                ),
                if (extended)
                  Text(
                    _studentId ?? "No ID", // Display student ID if available
                    style: TextStyle(color: Colors.white),
                  ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        },
        items: [
          SidebarXItem(
            icon: Icons.home,
            label: 'Home',
          ),
          const SidebarXItem(
            icon: Icons.assessment_sharp,
            label: 'View Grades',
          ),
          const SidebarXItem(
            icon: Icons.how_to_reg_sharp,
            label: 'Check Enrollment',
          ),
          const SidebarXItem(
            icon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ScreensExample extends StatefulWidget {
  const _ScreensExample({
    Key? key,
    required this.controller,
    required this.selectedSemester,
    required this.onSemesterChanged,
    required this.gradeControllers,
    required this.imageNotifier,
  }) : super(key: key);

  final SidebarXController controller;
  final String selectedSemester;
  final ValueChanged<String> onSemesterChanged;
  final Map<String, TextEditingController> gradeControllers;
  final ValueNotifier<String?> imageNotifier;

  @override
  State<_ScreensExample> createState() => _ScreensExampleState();
}

class _ScreensExampleState extends State<_ScreensExample> {
  List<String> _sections = [];
  List<Map<String, dynamic>> _subjects = []; // To store the fetched subjects

  String? _studentId;
  String? _fullName;
  late String _strand;
  String? _track;
  String? _gradeLevel;
  String? _semester;
  String? _selectedSection;

  @override
  void initState() {
    super.initState();

    // Call all necessary functions during widget initialization
    _fetchSections();
    _loadStudentData();
    _imageGetterFromExampleState();
    _loadSubjects(); // Ensure _selectedSection is checked before calling this
  }

  Future<void> _fetchSections() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('sections').get();
    setState(() {
      _sections = snapshot.docs
          .map((doc) => doc['section_name'] as String)
          .toList(); // Adjust the field name as necessary
    });
  }

  Future<void> _loadStudentData() async {
    User? user =
        FirebaseAuth.instance.currentUser; // Get the current logged-in user

    if (user != null) {
      try {
        // Query the 'users' collection where the 'uid' field matches the current user's UID
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Assuming only one document will be returned, get the first document
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          setState(() {
            _studentId = userDoc['student_id'];
            _fullName =
                '${userDoc['first_name']} ${userDoc['middle_name'] ?? ''} ${userDoc['last_name']} ${userDoc['extension_name'] ?? ''}'
                    .trim();
            _strand = userDoc['seniorHigh_Strand'];
            _track = userDoc['seniorHigh_Track'];
            _gradeLevel = userDoc['grade_level'];
            _semester = userDoc['semester'];
          });
        } else {
          print('No matching student document found.');
        }
      } catch (e) {
        print('Failed to load student data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  Future<void> _saveSection() async {
    if (_selectedSection != null && _selectedSection!.isNotEmpty) {
      try {
        // Get the currently logged-in user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Query Firestore for the document where 'uid' matches the logged-in user's UID
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: user.uid)
              .get();

          // Check if any documents were returned
          if (userSnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = userSnapshot.docs.first;

            // Fetch the selected section document to check capacity
            QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
                .collection('sections')
                .where('section_name', isEqualTo: _selectedSection)
                .get();

            // Check if any section documents were returned
            if (sectionSnapshot.docs.isNotEmpty) {
              DocumentSnapshot sectionDoc =
                  sectionSnapshot.docs.first; // Get the first section document

              int capacityCount = sectionDoc['capacityCount'] ?? 0;
              int capacity = sectionDoc['section_capacity'] ?? 0;

              // Check if there's available capacity
              if (capacityCount < capacity) {
                // Update the 'section' field in the user's document
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDoc.id)
                    .update({
                  'section': _selectedSection,
                });

                // Increment the capacityCount
                await FirebaseFirestore.instance
                    .collection('sections')
                    .doc(sectionDoc.id)
                    .update({
                  'capacityCount': FieldValue.increment(
                      1), // Use FieldValue.increment to safely increment
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Section saved successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'This section is full. Please select another section.')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Section document not found.')),
              );
            }
          } else {
            print('No document found for the current user.');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User document not found.')),
            );
          }
        } else {
          print('No user is logged in.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'No user is logged in. Please log in to save the section.')),
          );
        }
      } catch (e) {
        print('Error saving section: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving section: $e')),
        );
      }
    } else {
      // Show an error message if no section is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a section before saving.')),
      );
    }
  }

  Future<bool> _canSelectSection() async {
    if (_selectedSection != null) {
      // Fetch the section's document to check the capacity
      final sectionDoc = await FirebaseFirestore.instance
          .collection('sections')
          .doc(_selectedSection)
          .get();

      if (sectionDoc.exists) {
        int capacityCount = sectionDoc['capacityCount'] ?? 0;
        int capacity = sectionDoc['capacity'] ?? 0;
        return capacityCount <
            capacity; // Return true if there's available capacity
      }
    }
    return true; // Default to true if no section is selected
  }

  String getStrandCourse(String seniorHighStrand) {
    switch (seniorHighStrand) {
      case 'Accountancy, Business, and Management (ABM)':
        return 'ABM';
      case 'Information and Communication Technology (ICT)':
        return 'ICT';
      case 'Science, Technology, Engineering and Mathematics (STEM)':
        return 'STEM';
      case 'Humanities and Social Sciences (HUMSS)':
        return 'HUMSS';
      case 'Home Economics (HE)':
        return 'HE';
      case 'Industrial Arts (IA)':
        return 'IA';
      default:
        return ''; // Return an empty string or some default value if there's no match
    }
  }

  Future<void> _loadSubjects() async {
    if (_selectedSection != null) {
      try {
        // Fetch the selected section's document
        QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
            .collection('sections')
            .where('section_name', isEqualTo: _selectedSection)
            .get();

        if (sectionSnapshot.docs.isNotEmpty) {
          DocumentSnapshot sectionDoc = sectionSnapshot.docs.first;
          String sectionSemester = sectionDoc[
              'semester']; // Assuming 'semester' field exists in 'sections'

          // Query subjects that have the same semester as the selected section
          QuerySnapshot subjectSnapshot = await FirebaseFirestore.instance
              .collection('subjects')
              .where('semester', isEqualTo: sectionSemester)
              .get();

          setState(() {
            _subjects = subjectSnapshot.docs
                .where((doc) {
                  String strandCourse =
                      doc['strandcourse']; // Assuming this field exists

                  // Call the getStrandCourse method to check if the courses match
                  return strandCourse == getStrandCourse(_strand);
                })
                .map((doc) => {
                      'subject_code': doc[
                          'subject_code'], // Adjust field names if necessary
                      'subject_name': doc['subject_name'],
                      'category':
                          doc['category'], // Assuming 'category' field exists
                    })
                .toList();
          });

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subjects loaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No matching section found.')),
          );
        }
      } catch (e) {
        print('Error loading subjects: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a section before loading subjects.')),
      );
    }
  }

  File? _imageFile; // For mobile (Android/iOS)
  Uint8List? _imageBytes; // For web

  String? _imageUrl;

  Future<void> _imageGetterFromExampleState() async {
    User? user =
        FirebaseAuth.instance.currentUser; // Get the current logged-in user

    if (user != null) {
      try {
        // Query the 'users' collection where the 'uid' field matches the current user's UID
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Assuming only one document will be returned, get the first document
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          setState(() {
            _imageUrl = userDoc['image_url'];
          });
        } else {
          print('No matching student document found.');
        }
      } catch (e) {
        print('Failed to load student data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  final ImagePicker picker = ImagePicker();

  bool _isHovered = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, store the image as Uint8List
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null; // Clear mobile file if on web
        });
      } else {
        // For mobile, store the image as File
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null; // Clear web bytes if on mobile
        });
      }
    }
  }

  Future<void> replaceProfilePicture() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("No user is currently signed in.");
        return;
      }

      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        print("User document not found for UID: ${currentUser.uid}");
        return;
      }

      final userDoc = userQuerySnapshot.docs.first;
      final userDocRef = userDoc.reference;

      String? oldImageUrl = userDoc.data()['image_url'];
      print("Old Image URL: $oldImageUrl");

      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          final oldImageRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
          await oldImageRef.delete();
          print("Old profile picture deleted successfully.");
        } catch (e) {
          print("Failed to delete old profile picture: $e");
        }
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('student_pictures')
          .child('${DateTime.now().toIso8601String()}.png');

      if (_imageBytes != null) {
        await storageRef.putData(_imageBytes!);
      } else if (_imageFile != null) {
        await storageRef.putFile(_imageFile!);
      } else {
        print("No image selected.");
        return;
      }

      final newImageUrl = await storageRef.getDownloadURL();
      print("New Image URL: $newImageUrl");

      await userDocRef.update({'image_url': newImageUrl});
      print("Profile picture updated successfully.");

      // Update the imageNotifier with the new URL to trigger a rebuild in ExampleSidebarX
      if (mounted) {
        widget.imageNotifier.value = newImageUrl;
      }
    } catch (e) {
      print("Failed to replace profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final pageTitle = _getTitleByIndex(widget.controller.selectedIndex);
        switch (widget.controller.selectedIndex) {
          case 0:
            return Case0();
          case 1:
            return Container(
              padding: EdgeInsets.all(16.0),
              color: Color.fromARGB(255, 1, 93, 168),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REPORT CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: widget.selectedSemester,
                      items: [
                        'SELECT SEMESTER',
                        'First Semester',
                        'Second Semester'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        widget.onSemesterChanged(newValue!);
                      },
                      underline: SizedBox(),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    color: Colors.white,
                    child: Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(
                            4), // Adjust for balanced column width
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Course Code',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Subject',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Grade',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ]),
                        // First subject row
                        TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('COURSE001',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Subject 1',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              widget.gradeControllers['subject1']?.text ??
                                  'N/A',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ]),
                        // Second subject row
                        TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('COURSE002',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Subject 2',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              widget.gradeControllers['subject2']?.text ??
                                  'N/A',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ]),
                        // Third subject row
                        TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('COURSE003',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Subject 3',
                                style: TextStyle(color: Colors.black)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              widget.gradeControllers['subject3']?.text ??
                                  'N/A',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle finalizing grades (e.g., validation)
                              print('Grades finalized:');
                              widget.gradeControllers
                                  .forEach((key, controller) {
                                print('$key: ${controller.text}');
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 1, 93, 168),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              minimumSize: Size(80, 20),
                            ),
                            child: Text(
                              'Finalize',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Note: You can only finalize this \nwhen the subject is completed.',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),

                      // Print Result button aligned to the right
                      ElevatedButton(
                        onPressed: () {
                          // Handle print result functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text('Print Result'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          case 2:
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                color: Color.fromARGB(255, 1, 93, 168),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Student Data",
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                      SizedBox(height: 20),
                      Text('Student ID no: ${_studentId ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Text('Student Full Name: ${_fullName ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Text('Strand: ${_strand ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Text('Track: ${_track ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Text('Grade Level: ${_gradeLevel ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Text('Semester: ${_semester ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Text("Subjects",
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                      DropdownButton<String>(
                        value: _selectedSection,
                        hint: Text('Select a section',
                            style: TextStyle(color: Colors.white)),
                        items: _sections.map((String section) {
                          return DropdownMenuItem<String>(
                            value: section,
                            child: Text(section,
                                style: TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          // Check if the user can select the section
                          bool canSelect = await _canSelectSection();

                          if (canSelect) {
                            setState(() {
                              _selectedSection =
                                  newValue; // Update selected section
                            });
                          } else {
                            // Show a message if the section is full
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'This section is full. Please choose another section.')),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveSection, // Call the save function
                        child: Text('Save Section'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: _loadSubjects,
                          child: Text('Load Subjects')),
                      _subjects.isNotEmpty
                          ? Table(
                              border: TableBorder.all(color: Colors.black),
                              columnWidths: {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(
                                    4), // Adjust for balanced column width
                                2: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text('Course Code',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text('Subject',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text('Grade',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ]),
                                // Dynamically create rows based on the fetched subjects
                                ..._subjects.map((subject) {
                                  return TableRow(children: [
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(subject['subject_code'],
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(subject['subject_name'],
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(subject['category'] ?? 'N/A',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ]);
                                }).toList(),
                              ],
                            )
                          : Text('No subjects available',
                              style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            );
          case 3:
            return Container(
              color: Color.fromARGB(255, 1, 93, 168),
              height: screenHeight,
              width: screenWidth,
              child: Container(
                margin: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _pickImage(); // Open image picker to select a new image

                                if (_imageBytes != null || _imageFile != null) {
                                  await replaceProfilePicture(); // Upload and replace the profile picture

                                  // Reload the new image URL from Firestore after uploading
                                  await _imageGetterFromExampleState();

                                  setState(
                                      () {}); // Refresh the UI after updating the image URL
                                }
                              },
                              child: MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _isHovered = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _isHovered = false;
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 85,
                                      backgroundImage: _imageBytes != null
                                          ? MemoryImage(_imageBytes!)
                                              as ImageProvider
                                          : _imageFile != null
                                              ? FileImage(_imageFile!)
                                                  as ImageProvider
                                              : _imageUrl != null
                                                  ? NetworkImage(_imageUrl!)
                                                      as ImageProvider
                                                  : const NetworkImage(
                                                      'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png',
                                                    ),
                                    ),
                                    if (_isHovered)
                                      Container(
                                        width: 170,
                                        height: 170,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 60,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ).showCursorOnHover,
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gerick M. Velasquez",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "B",
                                      fontSize: 30),
                                ),
                                SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () async {
                                    await _pickImage(); // Open image picker to select a new image

                                    if (_imageBytes != null ||
                                        _imageFile != null) {
                                      await replaceProfilePicture(); // Upload and replace the profile picture

                                      // Reload the new image URL from Firestore after uploading
                                      await _imageGetterFromExampleState();

                                      setState(
                                          () {}); // Refresh the UI after updating the image URL
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "B",
                                            fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ).showCursorOnHover.moveUpOnHover,
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Student Number",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "B",
                                  fontSize: 20),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "2024-PBMA-0011",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontFamily: "B",
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Learner Reference Number",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "B",
                                  fontSize: 20),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "101815080468",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontFamily: "B",
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "First Name",
                              style: TextStyle(
                                fontFamily: "M",
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 13),
                            Container(
                              width: 350,
                              child: TextFormField(
                                initialValue: "Gerick",
                                enabled: false,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "R",
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  filled: true,fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Middle Name",
                              style: TextStyle(
                                fontFamily: "M",
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 13),
                            Container(
                              width: 350,
                              child: TextFormField(
                                initialValue: "Molina",
                                enabled: false,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "R",
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  filled: true,
                                 fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Last Name",
                              style: TextStyle(
                                fontFamily: "M",
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 13),
                            Container(
                              width: 350,
                              child: TextFormField(
                                initialValue: "Velasquez",
                                enabled: false,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "R",
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          default:
            return Text(
              pageTitle,
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'View Grades';
      case 2:
        return 'Check Enrollment';
      case 3:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }
}

// Your colors here, replace with actual color values if needed
const canvasColor = Color(0xFF1D3557);
const scaffoldBackgroundColor = Color(0xFF457B9D);
const accentCanvasColor = Color(0xFFA8DADC);
const actionColor = Color(0xFFF4A261);
const divider = Divider(color: Colors.white54, thickness: 1);
