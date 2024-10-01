import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'create_suivi.dart';

class SuivisQuotidiens extends StatefulWidget {
  @override
  _SuivisQuotidiensState createState() => _SuivisQuotidiensState();
}

class _SuivisQuotidiensState extends State<SuivisQuotidiens> {
  List<dynamic> _suivis = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSuivis();
  }

  Future<void> _fetchSuivis() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.14:8000/controllers/SuivisQuotidiens/GetAllSuivis.php'));

      if (response.statusCode == 200) {
        setState(() {
          _suivis = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load suivis (status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load suivis: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivis Quotidiens'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('SuiviID')),
                        DataColumn(label: Text('Kilométrage')),
                        DataColumn(label: Text('Volume Carburant')),
                        DataColumn(label: Text('Preuve')),
                        DataColumn(label: Text('Immatriculation')),
                        DataColumn(label: Text('Nom Chauffeur')),
                        DataColumn(label: Text('Prénom Chauffeur')),
                      ],
                      rows: _suivis
                          .map<DataRow>(
                            (suivi) => DataRow(
                              cells: [
                                DataCell(Text(suivi['SuiviID'].toString())),
                                DataCell(Text(suivi['Kilometrage'].toString())),
                                DataCell(
                                    Text(suivi['VolumeCarburant'].toString())),
                                DataCell(
                                  suivi['Preuve'] != null
                                      ? Image.network(
                                          "http://192.168.1.14:8000/uploads/" +
                                              suivi['Preuve'].split('/').last,
                                          width: 50,
                                          height: 50,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                                DataCell(Text(suivi['VehiculeDetails']
                                        ['Immatriculation'] ??
                                    'N/A')),
                                DataCell(Text(
                                    suivi['ChauffeurDetails']['Nom'] ?? 'N/A')),
                                DataCell(Text(suivi['ChauffeurDetails']
                                        ['Prenom'] ??
                                    'N/A')),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSuivi()),
          ).then((value) {
            if (value == true) {
              _fetchSuivis(); // Refresh the list after a new Suivi is created
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
