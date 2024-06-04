import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'increment_votes_mutation.dart';

class ViewDivisasSection extends StatefulWidget {
  @override
  _ViewDivisasSectionState createState() => _ViewDivisasSectionState();
}

class _ViewDivisasSectionState extends State<ViewDivisasSection> {
  final String feedQuery = """
  query {
    divisas {
      id
      nombre
      pais
      acronimo
      precio
      postedBy {
        username
      }
      votes {
        id
      }
    }
  }
  """;

  final List<bool> _hoveredIndices = [];

  void _onHoverChanged(int index, bool isHovered) {
    setState(() {
      if (index >= _hoveredIndices.length) {
        _hoveredIndices.addAll(List.generate(index - _hoveredIndices.length + 1, (_) => false));
      }
      _hoveredIndices[index] = isHovered;
    });
  }

  bool _isHovered(int index) {
    return index < _hoveredIndices.length && _hoveredIndices[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Divisas'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(feedQuery),
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(
              child: Text(result.exception.toString()),
            );
          }

          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final List<dynamic> divisas = result.data!['divisas'];

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: divisas.length,
            itemBuilder: (context, index) {
              final divisa = divisas[index];
              return MouseRegion(
                onEnter: (_) => _onHoverChanged(index, true),
                onExit: (_) => _onHoverChanged(index, false),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isHovered(index) ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: _isHovered(index)
                        ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ]
                        : [],
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  divisa['nombre'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('País: ${divisa['pais']}'),
                                Text('Acrónimo: ${divisa['acronimo']}'),
                                Text('Precio: ${divisa['precio']}'),
                                Text('Publicado por: ${divisa['postedBy']['username']}'),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    IncrementVotesMutation(
                                      divisaId: divisa['id'].toString(),
                                      onCompleted: () {
                                        if (refetch != null) {
                                          refetch();
                                        }
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    Text('${divisa['votes'].length} votos'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
