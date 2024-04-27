import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:tutorial/pages/criteria.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';


class Contestant {
  int contestantNumber;
  String name;
  String course;
  String department;
  File? profilePic;
  File? selectedImage;
  String eventId;
  String? id;
  String? selectedImagePath;
  // final List<Criterias> criterias;

  Contestant(
      {
        required this.contestantNumber,
        required this.name,
      required this.course,
      required this.department,
      required this.eventId,
      // required this.criterias,
      this.profilePic,
      this.selectedImage,
      this.id});

  // map
  factory Contestant.fromJson(Map<String, dynamic> json) {
    return Contestant(
      contestantNumber: json['contestantNumber'] ?? 0,
      name: json['name'] ?? '',
      course: json['course'] ?? '',
      department: json['department'] ?? '',
      profilePic: json['profilePic'] != null ? File(json['profilePic']) : null,
      eventId: json['eventId'] ?? '',
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contestantNumber': contestantNumber.toString(),
      'id': id,
      'name': name,
      'course': course,
      'department': department,
      'profilePic': selectedImage,
      'eventId': eventId,
      'selectedImagePath': selectedImagePath,
    };
  }
}

//BASED ON THE EVENT

/*Map<String, dynamic> createEventFromControllers() {
  String name = _nameController.text;
  String course = _courseController.text;
  String department = _departmentController.text;
  String selectedImagePath = selectedImagePath ?? '';

  return {
    'name': name,
    'course': course,
    'department': department,
    'profilePic': profilePic,
    'eventId': eventId,
    'selectedImagePath': selectedImagePath,
  };
}*/

class Contestants extends StatefulWidget {
  final String eventId;
  final bool isEdit;
  Contestants({required this.eventId, required this.isEdit});
  @override
  _ContestantsState createState() => _ContestantsState();
}

class _ContestantsState extends State<Contestants> {
  late ImagePicker _picker;
  File? _addSelectImage;
  int _lastContestantNumber = 0; // State for contestant number
  bool isLoopRunning = false;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    contestantsFuture = fetchContestants();
  }

  late Future<List<Contestant>> contestantsFuture;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Contestant> contestants = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  File? _selectedImage;
  bool isContestantsEmpty = true;


  void insertItem(Contestant contestant) {
    final newIndex = 0;
    contestants ??= []; // Ensure contestants is not null
    contestants.insert(contestants.length, contestant);
    _listKey.currentState!.insertItem(newIndex);
  }

  Future<List<Contestant>> fetchContestants() async {
    try {
      String eventId = widget.eventId;
      final url =
          Uri.parse("http://192.168.101.6:8080/get-contestants/$eventId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Contestant> fetchedContestants = data.map((item) {
          Contestant contestant = Contestant.fromJson(item);
          contestant.profilePic = contestant.profilePic != null
              ? File(contestant.profilePic!.path)
              : null; // Load profilePic as File
          return contestant;
        }).toList();
        setState(() {
          contestants = fetchedContestants;
        });
        updateContestantsEmptyState();

        return fetchedContestants;
      } else {
        print(
            'Failed to fetch contestants. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
        // throw Exception('Failed to fetch contestants');
      }
    } catch (e) {
      print('Error fetching contestants: $e');
      throw Exception('Error fetching contestants');
    }
  }

  Future<void> deleteContestant(int index, String? contestantId) async {
    final url = Uri.parse(
        "http://192.168.101.6:8080/delete-contestant/$contestantId");

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Contestant deleted successfully');
      } else {
        print(
            'Failed to delete contestant. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting contestant: $e');
    }
  }


  void removeItem(int index) {
    if (index >= 0 && index < contestants.length) {
      final removedItem = contestants[index];
      contestants.removeAt(index);
      _listKey.currentState!.removeItem(
        index,
            (context, animation) => ListItemWidget(
          contestant: removedItem,
          animation: animation,
          changeProfilePicture: () => changeProfilePicture(removedItem),
          onImageChanged: (File? newImage) {
            // Update the contestant's selectedImage
            contestants[index].selectedImage = newImage;
          },
          onClicked: () {
            // Call deleteContestant function here instead of onPressed
            deleteContestant(index, contestants[index].id);
          },
          onEdit: () => _editContestant(removedItem),
        ),
        duration: const Duration(milliseconds: 300),
      );

      // Update contestant numbers
      updateContestantNumbers();
      updateContestantsEmptyState();
    }
  }

  Future<void> removeAllItems() async {
    for (int i = contestants.length - 1; i >= 0; i--) {
      await deleteContestant(i, contestants[i].id);
      removeItem(i);
    }
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete all contestants?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                removeAllItems(); // Call removeAllItems function if confirmed
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void updateContestantsEmptyState() {
    setState(() {
      isContestantsEmpty = contestants.isEmpty;
    });
  }

  void updateContestantNumbers() {
    for (int i = 0; i < contestants.length; i++) {
      contestants[i].contestantNumber = i + 1;
    }
  }
  Future<void> addProfilePicture(Contestant contestant) async {
    // bool galleryPermission = await _requestGalleryPermission();
    // if (!galleryPermission) {
    //   // Handle permission not granted
    //   return;
    // }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      print('Selected image path: ${image.path}');
      setState(() {
        _selectedImage = File(image.path);
      });
    } else {
      print('Image selection canceled');
    }
  }

  Future<void> changeProfilePicture(Contestant contestant) async {
    // bool galleryPermission = await _requestGalleryPermission();
    // if (!galleryPermission) {
    //   // Handle permission not granted
    //   return;
    // }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      print('Selected image path: ${image.path}');
      setState(() {
        contestant.selectedImage = File(image.path);
      });
    } else {
      print('Image selection canceled');
    }
  }
  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  Future<void> createContestant(
      String eventId, Map<String, dynamic> contestantData) async {

    final url = Uri.parse("http://192.168.101.6:8080/contestants");
    try {
      // Read the image file
      final imageFile = contestantData["profilePic"];
      print("File Image: ${imageFile}");
      if (imageFile != null) {
        // Create a multipart request
        var request = http.MultipartRequest('POST', url);
        request.headers['Content-Type'] = 'multipart/form-data';
        // Add other fields to the request
        request.fields['contestantId'] =
            contestantData['id'] != null ? contestantData['id'] : "";
        request.fields['contestantNumber'] = contestantData['contestantNumber'] ?? "";
        request.fields['eventId'] = eventId;
        request.fields['name'] = contestantData['name'];
        request.fields['course'] = contestantData['course'];
        request.fields['department'] = contestantData['department'];

        // Add the image file to the request
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePic', // This should match the field name in your multer configuration
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        // Send the request
        var response = await request.send();

        if (response.statusCode == 201) {
          setState(() {
            contestantsFuture = fetchContestants();
          });
          print('Contestant created successfully');
        } else {
          print(
              'Failed to create contestant. Staus code: ${response.statusCode}');
          print('Response body: ${await response.stream.bytesToString()}');
        }
      } else {
        // Create a request
        var request = http.Request('POST', url);
        request.headers['Content-Type'] = 'application/json';

        // Add JSON fields to the request
        request.body = jsonEncode({
          'contestantId': contestantData['id'],
          'contestantNumber': contestantData['contestantNumber'],
          'eventId': eventId,
          'name': contestantData['name'],
          'course': contestantData['course'],
          'department': contestantData['department'],
        });
        // Send the request
        var response = await request.send();

        if (response.statusCode == 201) {
          print('Contestant created successfully');
        } else {
          print(
              'Failed to create contestant. Status code: ${response.statusCode}');
          print('Response body: ${await response.stream.bytesToString()}');
        }

        print("Image file not found: ${contestantData["profilePic"]}");
      }
    } catch (e) {
      setState(() {
        isLoopRunning = false; // Loop has ended
      });
      print('Error creating contestant: $e');
    }
  }

  void _editContestant(Contestant contestant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _selectedImage = contestant.profilePic != null
            ? File(contestant.profilePic!.path)
            : null;
        _nameController.text = contestant.name;
        _courseController.text = contestant.course;
        _departmentController.text = contestant.department;

        return ProfilePictureDialog(
          contestant: contestant,
          onChanged: (File? newImage) {
            setState(() {
              contestant.profilePic = _selectedImage;
            });
          },
          onImageChanged: (File? newImage) {
            // Update the contestant's selectedImage
            setState(() {
              contestant.selectedImage = newImage;
            });
          },
        );
      },
    );
  }

// Function to update the contestant information in the database
  Future<void> updateContestant(String eventId, Contestant contestant) async {
    final url =
        Uri.parse("http://192.168.101.6:8080/contestants/${contestant.id}");

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          ...contestant.toJson(),
          "eventId": eventId,
        }),
      );

      if (response.statusCode == 200) {
        print('Contestant updated successfully');
      } else {
        print(
            'Failed to update contestant. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating contestant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Contestants',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF054E07),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Contestant>>(
        future: contestantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            // Display a message when there's an error or no contestants available
            return Center(child: Text('Error or No contestants available.'));
          } else if (snapshot.data!.isEmpty) {
            contestants = snapshot.data!;
            return AnimatedList(
              key: _listKey,
              initialItemCount: contestants.length,
              itemBuilder: (context, index, animation) {
                final contestant = contestants[index];
                return ListItemWidget(
                  onImageChanged: (File? newImage) {
                    // Update the contestant's selectedImage
                    contestants[index].selectedImage = newImage;
                  },
                  contestant: contestant,
                  animation: animation,
                  changeProfilePicture: () =>
                      changeProfilePicture(contestants[index]),
                  onClicked: () {
                    removeItem(index);
                  },
                  onEdit: () => _editContestant(contestants[index]),
                );
              },
            );
            return Center(child: Text('No contestants available.'));
          } else {
            contestants.sort((a, b) => a.contestantNumber.compareTo(b.contestantNumber));
            contestants = snapshot.data!;
            return AnimatedList(
              key: _listKey,
              initialItemCount: contestants.length,
              itemBuilder: (context, index, animation) {
                final contestant = contestants[index];
                return ListItemWidget(
                  contestant: contestant,
                  animation: animation,
                  onImageChanged: (File? newImage) {
                    // Update the contestant's selectedImage
                    contestants[index].selectedImage = newImage;
                  },
                  changeProfilePicture: () =>
                      changeProfilePicture(contestants[index]),
                  onClicked: () async {
                    await deleteContestant(index, contestants[index].id);
                    removeItem(index);

                  },
                  onEdit: () => _editContestant(contestants[index]),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {

              return AddContestantDialog(
                eventId: widget.eventId,
                onImageChanged: (File? newImage) {
                  setState(() {
                    _addSelectImage = newImage;
                  });
                },
                onContestantAdded: (Contestant newContestant) {
                  // Increment the contestant number and then add the contestant
                  _lastContestantNumber++;
                  newContestant.contestantNumber = _lastContestantNumber;
                  insertItem(newContestant);
                  updateContestantNumbers();
                  updateContestantsEmptyState();
                },
                lastContestantNumber: _lastContestantNumber, // Pass contestant number
              );

            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {
                showDeleteConfirmationDialog();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 2.2,
                  color: Colors.black,
                ),
              ),
              child: const Text('CLEAR', style: TextStyle(color: Colors.green)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: isContestantsEmpty || isLoopRunning ? null : () async {
                if (contestants.isNotEmpty) {
                  setState(() {
                    isLoopRunning = true; // Loop is starting
                  });

                  for (final contestant in contestants) {
                    await createContestant(widget.eventId, contestant.toJson());
                  }

                  setState(() {
                    isLoopRunning = false; // Loop has ended
                  });
                }

                fetchContestants();
                //  String eventId = widget.eventId;

                if (widget.isEdit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contestants updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Criterias(
                        eventId: widget.eventId,
                        isEdit: false,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 2.2,
                  color: Colors.white,
                ),
              ),
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItemWidget extends StatelessWidget {
  final Contestant contestant;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final VoidCallback changeProfilePicture;
  final VoidCallback onEdit;
  final Function(File?) onImageChanged;

  ListItemWidget({
    required this.contestant,
    required this.animation,
    required this.onClicked,
    required this.changeProfilePicture,
    required this.onEdit,
    required this.onImageChanged,
  });

  static void _defaultCallback() {
    // Provide a default implementation or leave it empty
  }
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: buildItem(context),
    );
  }

  Future<void> deleteContestant(String contestantId) async {
    final url = Uri.parse(
        "http://192.168.101.6:8080/delete-contestant/$contestantId");

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Contestant deleted successfully');
      } else {
        print(
            'Failed to delete contestant. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting contestant: $e');
    }
  }

  Widget buildItem(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: GestureDetector(
            onTap: () => changeProfilePicture(),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[400],
              backgroundImage: contestant.selectedImage != null
                  ? FileImage(contestant.selectedImage!)
                  : contestant.profilePic != null
                      ? NetworkImage("${contestant.profilePic?.path}")
                      : null as ImageProvider<Object>?,

              // ? NetworkImage(
              //     "http://192.168.101.6:8080/uploads/${contestant.profilePic?.path}")
              // : null as ImageProvider<Object>?,
            ),
          ),
          title: Text(
            contestant.name,
            style: const TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Contestant #: ${contestant.contestantNumber}\nAge: ${contestant.course}\nAddress: ${contestant.department}',
            style: const TextStyle(
                fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 25),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 25),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete this contestant?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              onClicked(); // Call the deletion function
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePictureDialog extends StatefulWidget {
  final Contestant contestant;
  final Function(File?) onChanged;
  final Function(File?) onImageChanged;

  ProfilePictureDialog({
    required this.contestant,
    required this.onChanged,
    required this.onImageChanged,
  });

  @override
  _ProfilePictureDialogState createState() => _ProfilePictureDialogState();
}

class _ProfilePictureDialogState extends State<ProfilePictureDialog> {
  File? _selectedImage;
  late TextEditingController _nameController;
  late TextEditingController _courseController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with contestant's values
    _selectedImage = widget.contestant.selectedImage != null
        ? File(widget.contestant.selectedImage!.path)
        : null;
    _nameController = TextEditingController(text: widget.contestant.name);
    _courseController = TextEditingController(text: widget.contestant.course);
    _departmentController = TextEditingController(text: widget.contestant.department);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Change Profile Picture',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF054E07),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: Colors.grey[200],
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : widget.contestant.profilePic != null
                  ? NetworkImage("${widget.contestant.profilePic?.path}")
                  : null as ImageProvider<Object>?,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await changeProfilePicture();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Change Profile Picture'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Contestant Name',
                labelStyle: TextStyle(fontSize: 15, color: Colors.green),
              ),
            ),
            TextField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(fontSize: 15, color: Colors.green),
              ),
                          ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(fontSize: 15, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.green),
          ),
        ),
        TextButton(
          onPressed: () {
            // Update the contestant's values with the new ones
            widget.contestant.name = _nameController.text;
            widget.contestant.course = _courseController.text;
            widget.contestant.department = _departmentController.text;
            widget.onChanged(_selectedImage);
            widget.onImageChanged(_selectedImage);
            Navigator.pop(context);
          },
          child: Text(
            'Save',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  Future<void> changeProfilePicture() async {
    // bool galleryPermission = await _requestGalleryPermission();
    // if (!galleryPermission) {
    //   // Handle permission not granted
    //   return;
    // }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      print('Selected image path: ${image.path}');
      setState(() {
        _selectedImage = File(image.path);
      });
    } else {
      print('Image selection canceled');
    }
  }
}


class AddContestantDialog extends StatefulWidget {
  final Function(File?) onImageChanged;
  final Function(Contestant) onContestantAdded;
  late int lastContestantNumber; // Add a field to receive the last contestant number

  String eventId;
  AddContestantDialog(
      {required this.onImageChanged,
      required this.onContestantAdded,
      required this.eventId,
      required this.lastContestantNumber,
      });

  @override
  _AddContestantDialogState createState() => _AddContestantDialogState();
}

class _AddContestantDialogState extends State<AddContestantDialog> {
  File? _selectedImage;


  TextEditingController _nameController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  int _lastContestantNumber = 0;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: const Text(
        'Add Contestant Information',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF054E07),
        ),
      ),
      content: SingleChildScrollView(
          child: Column(
        children: [
          CircleAvatar(
            radius: 64,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                _selectedImage != null ? FileImage(_selectedImage!) : null,
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () async {
              await addProfilePicture();
              if (_selectedImage != null) {
                print(
                    'Selected Image: ${_selectedImage!.path.split('/').last}');
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Select Image'),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Contestant Name',
              labelStyle: TextStyle(fontSize: 15, color: Colors.green),
            ),
          ),
        TextField(
          controller: _courseController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Age',
            labelStyle: TextStyle(fontSize: 15, color: Colors.green),
          ),
          onChanged: (value) {
            // Ensure the entered age is a valid integer
            if (value.isNotEmpty) {
              int age = int.tryParse(value) ?? 0; // Default to 0 if parsing fails
              if (age < 0 || age > 150) {
                // If the age is not within the valid range, clear the text field
                _courseController.clear();
              }
            }
          },
        ),
          TextField(
            controller: _departmentController,
            decoration: const InputDecoration(
              labelText: 'Address',
              labelStyle: TextStyle(fontSize: 15, color: Colors.green),
            ),
          ),
        ],
      )),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.green),
          ),
        ),
        TextButton(
          onPressed: () async {
            widget.lastContestantNumber++;
            Contestant newContestant = Contestant(
              contestantNumber: widget.lastContestantNumber, // Assign the new contestant number
              name: _nameController.text,
              course: _courseController.text,
              department: _departmentController.text,
              profilePic: _selectedImage,
              selectedImage: _selectedImage,
              eventId: widget.eventId,
            );

            // Invoke the callback function to notify the parent widget
            widget.onContestantAdded(newContestant);

            // Clear form fields and selected image
            _nameController.clear();
            _courseController.clear();
            _departmentController.clear();
            _selectedImage = null;


            Navigator.pop(context);
          },
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  Future<void> addProfilePicture() async {
    // bool galleryPermission = await _requestGalleryPermission();
    // if (!galleryPermission) {
    //   // Handle permission not granted
    //   return;
    // }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      print('Selected image path: ${image.path}');
      setState(() {
        _selectedImage = File(image.path);
      });
    } else {
      print('Image selection canceled');
    }
  }
}
