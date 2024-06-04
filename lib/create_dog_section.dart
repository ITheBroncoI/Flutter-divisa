import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateDivisaSection extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController acronymController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController valueController = TextEditingController();

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Divisa'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la divisa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: acronymController,
                decoration: InputDecoration(
                  labelText: 'Acrónimo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  counterText: '',
                ),
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z]'))],
              ),
              SizedBox(height: 10),
              TextField(
                controller: countryController,
                decoration: InputDecoration(
                  labelText: 'País de la divisa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: 'Valor de la divisa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              ),
              SizedBox(height: 20),
              Mutation(
                options: MutationOptions(
                  document: gql(r'''
                    mutation PostMutation(
                      $nombre: String!
                      $acronimo: String!
                      $pais: String!
                      $precio: Float!
                    ) {
                      createDivisa(nombre: $nombre, acronimo: $acronimo, pais: $pais, precio: $precio) {
                        id
                        nombre
                        acronimo
                        pais
                        precio
                      }
                    }
                  '''),
                  onCompleted: (dynamic resultData) {
                    _showSnackBar(context, "La divisa se ha creado correctamente");
                  },
                  onError: (error) {
                    print(error);
                    _showSnackBar(context, "Ocurrió un error al crear la divisa");
                  },
                ),
                builder: (RunMutation runMutation, QueryResult? result) {
                  return ElevatedButton(
                    onPressed: () {
                      final String name = nameController.text;
                      final String acronym = acronymController.text;
                      final String country = countryController.text;
                      final String valueText = valueController.text;

                      if (name.isEmpty || acronym.isEmpty || country.isEmpty || valueText.isEmpty) {
                        _showSnackBar(context, "Por favor, completa todos los campos");
                        return;
                      }

                      if (acronym.length < 3 || acronym.length > 4 || !RegExp(r'^[A-Z]+$').hasMatch(acronym)) {
                        _showSnackBar(context, "El acrónimo debe ser de 3 a 4 letras mayúsculas");
                        return;
                      }

                      final double? value = double.tryParse(valueText);
                      if (value == null) {
                        _showSnackBar(context, "Valor de la divisa no válido");
                        return;
                      }

                      runMutation({
                        'nombre': nameController.text,
                        'acronimo': acronymController.text,
                        'pais': countryController.text,
                        'precio': value,
                      });
                    },
                    child: Text('Crear Divisa'),
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

