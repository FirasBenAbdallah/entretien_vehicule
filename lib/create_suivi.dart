import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateSuivi extends StatefulWidget {
  const CreateSuivi({super.key});

  @override
  _CreateSuiviState createState() {
    return _CreateSuiviState();
  }
}

class _CreateSuiviState extends State<CreateSuivi> {
  final _formKey = GlobalKey<FormState>();
  int? vehiculeID;
  int? chauffeurID;
  String? dateSuivi;
  int? kilometrage;
  double? volumeCarburant;
  String? preuve;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Build the request body
      var body = {
        'VehiculeID': vehiculeID.toString(),
        'ChauffeurID': chauffeurID.toString(),
        'DateSuivi': dateSuivi!,
        'Kilometrage': kilometrage.toString(),
        'VolumeCarburant': volumeCarburant.toString(),
        'Preuve':
            preuve!, // In a real app, this should be handled as a file upload
      };

      try {
        final response = await http.post(
          Uri.parse(
              'http://192.168.1.14:8000/controllers/SuivisQuotidiens/CreateSuivi.php'),
          body: body,
        );

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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Preuve'),
                onSaved: (value) => preuve = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Preuve';
                  }
                  return null;
                },
              ),
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
