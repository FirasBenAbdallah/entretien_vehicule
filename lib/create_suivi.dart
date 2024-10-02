import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateSuivi extends StatefulWidget {
  const CreateSuivi({super.key});

  @override
  _CreateSuiviState createState() => _CreateSuiviState();
}

class _CreateSuiviState extends State<CreateSuivi> {
  final _formKey = GlobalKey<FormState>();
  int? vehiculeID;
  int? chauffeurID;
  String? dateSuivi;
  int? kilometrage;
  double? volumeCarburant;
  File? preuve; // The selected image file

  final ImagePicker _picker = ImagePicker();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && preuve != null) {
      _formKey.currentState!.save();

      try {
        // Prepare multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://192.168.1.14:8000/controllers/SuivisQuotidiens/CreateSuivi.php'),
        );

        // Add form fields
        request.fields['VehiculeID'] = vehiculeID.toString();
        request.fields['ChauffeurID'] = chauffeurID.toString();
        request.fields['DateSuivi'] = dateSuivi!;
        request.fields['Kilometrage'] = kilometrage.toString();
        request.fields['VolumeCarburant'] = volumeCarburant.toString();

        // Attach image file as multipart
        if (preuve != null) {
          request.files
              .add(await http.MultipartFile.fromPath('Preuve', preuve!.path));
        }

        // Send the request
        var response = await request.send();

        if (response.statusCode == 200) {
          Navigator.pop(
              context, true); // Return to the previous screen with success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to create suivi: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create suivi: $e')),
        );
      }
    } else if (preuve == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image file')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        preuve = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        preuve = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Suivi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'VehiculeID'),
                keyboardType: TextInputType.number,
                onSaved: (value) => vehiculeID = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter VehiculeID';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ChauffeurID'),
                keyboardType: TextInputType.number,
                onSaved: (value) => chauffeurID = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ChauffeurID';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'DateSuivi'),
                keyboardType: TextInputType.datetime,
                onSaved: (value) => dateSuivi = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter DateSuivi';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Kilométrage'),
                keyboardType: TextInputType.number,
                onSaved: (value) => kilometrage = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Kilométrage';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Volume Carburant'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    volumeCarburant = double.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Volume Carburant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: const Text('Select from Gallery'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text('Take Picture'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              preuve != null
                  ? Text('File selected: ${preuve!.path.split('/').last}')
                  : const Text('No file selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Suivi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
