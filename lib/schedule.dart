// import 'package:flutter/material.dart';


// class ScheduleApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Schedule App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 // Get staff members from database or input
//                 List<StaffMember> staffMembers = [
//                   StaffMember(name: 'John Doe', email: 'johndoe@example.com'),
//                   StaffMember(name: 'Jane Doe', email: 'janedoe@example.com'),
//                   StaffMember(name: 'Peter Jones', email: 'peterjones@example.com'),
//                 ];

//                 // Generate schedule
//                 Map<StaffMember, List<DateTime>> schedule = _generateSchedule(staffMembers);

//                 // // Send emails with scheduled timetables
//                 // for (StaffMember staffMember in schedule.keys) {
//                 //   await _sendEmail(staffMember, schedule[staffMember]!);
//                 // }

//                 // // Display success message
//                 // // ignore: use_build_context_synchronously
//                 // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                 //   content: Text('Schedule generated and emails sent successfully!'),
//                 // ));
//               },
//               child: const Text('Generate Schedule and Send Emails'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Map<StaffMember, List<DateTime>> _generateSchedule(List<StaffMember> staffMembers) {
//     // Calculate total working days in a year
//     int totalWorkingDays = 252; // Assuming 22 working days per month, excluding holidays and weekends

//     // Distribute working days evenly among staff members
//     int daysPerStaff = totalWorkingDays ~/ staffMembers.length;

//     // Assign specific days to each staff member
//     Map<StaffMember, List<DateTime>> schedule = {};
//     for (StaffMember staffMember in staffMembers) {
//       List<DateTime> assignedDays = [];
//       for (int i = 0; i < daysPerStaff; i++) {
//         DateTime nextAvailableDate = DateTime.now().add(Duration(days: i));
//         if (nextAvailableDate.weekday != DateTime.saturday && nextAvailableDate.weekday != DateTime.sunday) {
//           assignedDays.add(nextAvailableDate);
//         }
//       }
//       schedule[staffMember] = assignedDays;
//     }

//     return schedule;
//   }

//   // Future<void> _sendEmail(StaffMember staffMember, List<DateTime> assignedDays) async {
//   //   final email = Email(
//   //     body: 'Dear ${staffMember.name},\n\nYour assigned schedule for the year is as follows:\n\n${_formatAssignedDays(assignedDays)}\n\nPlease let us know if you have any questions or concerns.\n\nSincerely,\nThe Admin Team',
//   //     subject: 'Your Schedule for the Year',
//   //     recipients: [staffMember.email],
//   //     isHTML: false,
//   //   );

//   //   try {
//   //     await FlutterEmailSender.send(email);
//   //     print('Email sent successfully to ${staffMember.email}');
//   //   } catch (error) {
//   //     print('Error sending email: ${error.toString()}');
//   //   }
//   // }

//   String _formatAssignedDays(List<DateTime> assignedDays) {
//     String formattedDays = '';
//     for (DateTime assignedDay in assignedDays) {
//       formattedDays += '${assignedDay.weekday}, ${assignedDay.month}/${assignedDay.day}\n';
//     }
//     return formattedDays.trim();
//   }
// }

// class StaffMember {
//   final String name;
//   final String email;

//   StaffMember({required this.name, required this.email});
// }
