// lib/add_subjects_form.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';

class EditSectionsForm extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeEditSections;
  final String? sectionId;

  EditSectionsForm({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.closeEditSections,
    this.sectionId,
  });

  @override
  State<EditSectionsForm> createState() => _EditSectionsFormState();
}

class _EditSectionsFormState extends State<EditSectionsForm> {
  final TextEditingController _sectionAdviser = TextEditingController();
  final TextEditingController _sectionCapacity = TextEditingController();
  String? _selectedSemester = '--';
  String? _selectedAdviser;
  List<DropdownMenuItem<String>> advisersDropdownItems = [];

  final CollectionReference sectionsCollection =
      FirebaseFirestore.instance.collection('sections');

  @override
  void initState() {
    super.initState();
    _fetchSectionData();
    _fetchAdvisers(); // Fetch advisers when form loads
  }

  // Fetch section details from Firestore using the sectionId
  Future<void> _fetchSectionData() async {
    DocumentSnapshot sectionDoc = await sectionsCollection.doc(widget.sectionId).get();

    if (sectionDoc.exists) {
      Map<String, dynamic>? data = sectionDoc.data() as Map<String, dynamic>?;

      setState(() {
        _selectedAdviser = data?['section_adviser'] ?? '';
        _selectedSemester = data?['semester'] ?? '--';
        _sectionCapacity.text = data?['section_capacity'].toString() ?? '';
      });
    }
  }

  Future<void> _fetchAdvisers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'instructor')
        .where('adviser', isEqualTo: 'yes')  // Only fetch instructors who are advisers
        .get();

    setState(() {
    advisersDropdownItems = [
      DropdownMenuItem<String>(
        value: 'N/A',
        child: Text('N/A'),
      ),
      ...querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String adviserName = '${data['first_name']} ${data['last_name']}';
        return DropdownMenuItem<String>(
          value: adviserName,
          child: Text(adviserName),
        );
      }).toList(),
    ];
  });
}

  // Update the section in Firestore
  Future<void> _updateSection() async {
    if (_selectedAdviser == null || _selectedSemester == '--' || _sectionCapacity.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Please fill all fields'),
          ],
        )),
      );
      return;
    }

    int newCapacity = int.tryParse(_sectionCapacity.text) ?? 0;

    // Fetch the current capacityCount
    DocumentSnapshot sectionDoc = await sectionsCollection.doc(widget.sectionId).get();
    Map<String, dynamic>? data = sectionDoc.data() as Map<String, dynamic>?;

    int currentCapacityCount = data?['capacityCount'] ?? 0;

    // Validate capacity
    if (newCapacity < currentCapacityCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Capacity cannot be less than current enrolled count of $currentCapacityCount'),
          ],
        )),
      );
      return;
    }

    try {
      await sectionsCollection.doc(widget.sectionId).update({
        'section_adviser': _selectedAdviser,
        'semester': _selectedSemester,
        'section_capacity': newCapacity,
        'updated_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Section updated successfully!'),
          ],
        )),
      );

      widget.closeEditSections();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Error updating section: $e'),
          ],
        )),
      );
    }
  }

  @override
  void dispose() {
    _sectionAdviser.dispose();
    _sectionCapacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.closeEditSections,
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: widget.screenWidth / 2,
                height: widget.screenHeight / 1.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: widget.closeEditSections,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child: Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Form title
                      Text(
                        'Edit Section',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Section Adviser
                      DropdownButtonFormField<String>(
                        value: _selectedAdviser,
                        decoration: InputDecoration(
                          labelText: 'Section Adviser',
                          border: OutlineInputBorder(),
                        ),
                        items: advisersDropdownItems,
                        onChanged: (val) {
                          setState(() {
                            _selectedAdviser = val;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      // Semester Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        decoration: InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          '--',
                          'Grade 11 - 1st Semester',
                          'Grade 11 - 2nd Semester',
                          'Grade 12 - 1st Semester',
                          'Grade 12 - 2nd Semester'
                        ].map((semester) => DropdownMenuItem<String>(
                          value: semester,
                          child: Text(semester),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSemester = val;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      // Section Capacity
                      TextFormField(
                        controller: _sectionCapacity,
                        decoration: InputDecoration(
                          labelText: 'Section Capacity',
                          border: OutlineInputBorder(),
                          hintText: 'Enter section capacity',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      ),
                      // Save Changes button
                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: widget.screenWidth * 1,
                          height: widget.screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _updateSection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              elevation: 5, // Elevation level for shadow depth
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                            ),
                            ),
                            child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 14,),),
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
