import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:scheduler_app/ChatRoom/groupchart.dart';
import 'package:scheduler_app/result.dart';

class StaffListScreen extends StatefulWidget {
  @override
  _StaffListScreenState createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List<StaffMember> staffMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Staff Scheduler'),
        actions: [
          
            PopupMenuButton<String>(
              color: Colors.cyan,
              icon: const Icon(Icons.group_add),
              iconSize: 30,
              onSelected: (value) async {
                if (value == 'group') {
                  // final user = FirebaseAuth.instance.currentUser;
                  // final uid = user?.uid;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupChatScreen(),
                      ));
                } else if (value == 'download') {
                  // await generateAndSavePDF(context, sortedEntries);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'group',
                  child: Text('Group Chart'),
                ),
                // const PopupMenuItem<String>(
                //   value: 'download',
                //   child: Text('Download'),
                // ),
              ],
            ),
          ],
      ),
      body: ListView.builder(
        itemCount: staffMembers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(staffMembers[index].name),
            subtitle: Text(staffMembers[index].email),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              generateSchedule();
            },
            child: Icon(Icons.schedule),
          ),
          const SizedBox(
            width: 130,
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStaffScreen(),
                ),
              ).then((newStaff) {
                if (newStaff != null) {
                  setState(() {
                    staffMembers.add(newStaff);
                  });
                }
              });
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void generateSchedule() {
    DateTime currentDate = DateTime.now();
    DateTime startDate = currentDate.add(const Duration(days: 1));
    DateTime endDate = startDate.add(const Duration(days: 30));

    Map<StaffMember, List<String>> schedules = {};

    int staffCount = staffMembers.length;
    int daysPerMember = 30 ~/ staffCount;
    int remainingDays = 30 % staffCount;

    int staffIndex = 0;

    for (int i = 0; startDate.isBefore(endDate); i++) {
      StaffMember currentStaff = staffMembers[staffIndex];
      String dateString =
          '${startDate.day}/${startDate.month}/${startDate.year}';

      schedules.putIfAbsent(currentStaff, () => []);
      schedules[currentStaff]!.add(dateString);

      staffIndex = (staffIndex + 1) % staffCount;
      startDate = startDate.add(const Duration(days: 1));

      // If we've assigned the required days to each staff member, reset the index
      if (i % daysPerMember == 0 && i > 0) {
        staffIndex = 0;
      }
    }

    // If there are remaining days, assign them to the first few staff members
    for (int i = 0; i < remainingDays; i++) {
      StaffMember currentStaff = staffMembers[i];
      String dateString =
          '${startDate.day}/${startDate.month}/${startDate.year}';
      schedules.putIfAbsent(currentStaff, () => []);
      schedules[currentStaff]!.add(dateString);

      startDate = startDate.add(const Duration(days: 1));
    }

    // Navigate to the ScheduleScreen with the generated schedule
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScheduleScreen(staffMembers: staffMembers, schedules: schedules),
      ),
    );
  }
}

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  _AddStaffScreenState createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Staff Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }

                  // Return null if the entered password is valid
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Enter email';
                  }
                  if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                      .hasMatch(value)) {
                    return 'Please Enter a valid Email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    StaffMember newStaff = StaffMember(
                      name: _nameController.text,
                      email: _emailController.text,
                    );
                    Navigator.pop(context, newStaff);
                  }
                },
                child: const Text('Add Staff'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffMember {
  final String name;
  final String email;

  StaffMember({required this.name, required this.email});
}

void sendEmail(String recipientEmail, String subject, String body) async {
  final smtpServer = gmail('your.email@gmail.com', 'your_password');

  final message = Message()
    ..from = const Address('your.email@gmail.com', 'Your Name')
    ..recipients.add(recipientEmail)
    ..subject = subject
    ..text = body;

  try {
    final sendReport = await send(message, smtpServer);
    if (kDebugMode) {
      print('Message sent: $sendReport');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}
