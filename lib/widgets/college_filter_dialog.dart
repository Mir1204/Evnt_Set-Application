// import 'package:flutter/material.dart';
//
// class CollegeFilterDialog extends StatelessWidget {
//   final List<String> colleges;
//   final String selectedCollege;
//   final ValueChanged<String> onCollegeSelected;
//
//   const CollegeFilterDialog({
//     Key? key,
//     required this.colleges,
//     required this.selectedCollege,
//     required this.onCollegeSelected,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("Filter by College"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: colleges.map((college) {
//           return RadioListTile<String>(
//             title: Text(college),
//             value: college,
//             groupValue: selectedCollege,
//             onChanged: (value) {
//               Navigator.pop(context); // Close the dialog
//               onCollegeSelected(value!); // Update the selected value in the parent widget
//             },
//           );
//         }).toList(),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context), // Close the dialog without making changes
//           child: Text("Cancel"),
//         ),
//       ],
//     );
//   }
// }
