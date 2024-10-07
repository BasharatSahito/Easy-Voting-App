import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide LegendPosition;
import 'package:rxdart/rxdart.dart';

class CheckResults extends StatefulWidget {
  const CheckResults({super.key});

  @override
  State<CheckResults> createState() => _CheckResultsState();
}

class _CheckResultsState extends State<CheckResults> {
  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Results"),
        centerTitle: true,
        actions: [
          // Refresh Button
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('politicalParties')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parties = snapshot.data?.docs;
          if (parties == null || parties.isEmpty) {
            return const Center(child: Text('No Parties Found'));
          }

          return StreamBuilder<List<ChartData>>(
            stream: _calculateChartData(parties),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final barChartData = snapshot.data ?? [];
              final pieChartData = _generatePieChartData(barChartData);

              final List<String> uniqueCategories = [];
              for (final data in barChartData) {
                if (!uniqueCategories.contains(data.category)) {
                  uniqueCategories.add(data.category);
                }
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 150, // You can adjust the height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: uniqueCategories.length,
                        itemBuilder: (context, index) {
                          final category = uniqueCategories[index];
                          final color = categoryCardColors[
                              index % categoryCardColors.length];
                          return SizedBox(
                            width: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  _showCandidatesByCategoryDialog(
                                      context, category);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        color, // Use the color based on the category index
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 220, // You can adjust the height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: barChartData.length,
                        itemBuilder: (context, index) {
                          final sortedData = List.from(barChartData)
                            ..sort(
                                (a, b) => b.totalVotes.compareTo(a.totalVotes));

                          final data = sortedData[index];
                          return SizedBox(
                            width: 200, // You can adjust the width as needed
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  _showCandidatesDialog(
                                      context, data.partyName);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(
                                        10), // Add rounded corners
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center the content vertically
                                    children: [
                                      CircleAvatar(
                                        radius:
                                            60, // Decrease the radius slightly to add a border effect
                                        backgroundImage:
                                            NetworkImage(data.partySymbolUrl),
                                      ),
                                      const SizedBox(height: 11),
                                      Text(
                                        data.partyName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                20), // Set font color to white
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Total Votes: ${data.totalVotes.toInt()}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                18), // Set font color to white
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.4, // Adjust the height as needed

                      child: const SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        // series: <ChartSeries>[
                        //   ColumnSeries<ChartData, String>(
                        //     dataSource: barChartData,
                        //     xValueMapper: (ChartData data, _) => data.partyName,
                        //     yValueMapper: (ChartData data, _) =>
                        //         data.totalVotes,
                        //     dataLabelSettings: const DataLabelSettings(
                        //       isVisible: true,
                        //     ),
                        //     // Set the color for each data point in the series
                        //     pointColorMapper: (ChartData data, _) => barColors[
                        //         uniqueCategories.indexOf(data.category) %
                        //             barColors.length], // Update this line
                        //   ),
                        // ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.4, // Adjust the height as needed

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PieChart(
                          dataMap: pieChartData,
                          chartRadius: MediaQuery.of(context).size.width / 1.5,
                          chartType: ChartType.disc,
                          chartLegendSpacing: 32,
                          centerText: "Votes",
                          animationDuration: const Duration(milliseconds: 1200),
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendPosition: LegendPosition.left,
                            legendShape: BoxShape.rectangle,
                            legendTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValuesInPercentage: true,
                            showChartValueBackground: true,
                            showChartValues: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 1,
                            chartValueStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<ChartData>> _calculateChartData(
      List<QueryDocumentSnapshot> parties) {
    final List<Stream<ChartData>> streams =
        parties.map((party) => _getPartyVotes(party)).toList();
    return CombineLatestStream.list<ChartData>(streams);
  }

  Stream<ChartData> _getPartyVotes(QueryDocumentSnapshot party) {
    final partyName = party['partyName'];
    final partySymbolUrl = party['partySymbolUrl'];
    String candidateCategory = "";
    return party.reference.collection('candidates').snapshots().map((snapshot) {
      int totalVotes = 0;
      for (final candidate in snapshot.docs) {
        final votes = candidate['votes'];
        candidateCategory = candidate['category'];
        if (votes is int) {
          totalVotes += votes;
        } else if (votes is num) {
          totalVotes += votes.toInt();
        }
      }

      return ChartData(
          partyName, totalVotes.toDouble(), partySymbolUrl, candidateCategory);
    });
  }

  Map<String, double> _generatePieChartData(List<ChartData> barChartData) {
    final Map<String, double> pieChartData = {};

    for (final data in barChartData) {
      pieChartData[data.partyName] = data.totalVotes;
    }

    return pieChartData;
  }
}

final List<Color> barColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
];

final List<Color> categoryCardColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
];

class ChartData {
  final String partyName;
  final double totalVotes;
  final String partySymbolUrl;
  final String category; // Add this field

  ChartData(this.partyName, this.totalVotes, this.partySymbolUrl,
      this.category); // Update the constructor
}

void _showCandidatesDialog(BuildContext context, String partyName) {
  showDialog(
    context: context,
    builder: (context) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('politicalParties')
            .doc(partyName)
            .collection('candidates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates = snapshot.data?.docs;
          if (candidates == null || candidates.isEmpty) {
            return const Text('No Candidates Found');
          }

          return AlertDialog(
            title: Text('Candidates for $partyName'),
            content: SizedBox(
              width: 300, // Adjust the width as needed
              height: 300, // Adjust the height as needed
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final candidateData =
                      candidates[index].data() as Map<String, dynamic>;
                  final candidateDp = candidateData['leaderPicUrl'] as String;
                  final candidateName = candidateData['fullName'] as String;
                  final candidateCategory = candidateData['category'] as String;
                  final candidateVotes = candidateData['votes'] as int;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(candidateDp),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                candidateName,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                candidateCategory,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Votes: $candidateVotes',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showCandidatesByCategoryDialog(BuildContext context, String category) {
  showDialog(
    context: context,
    builder: (context) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('politicalParties')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parties = snapshot.data?.docs;
          if (parties == null || parties.isEmpty) {
            return const Center(child: Text('No Parties Found'));
          }

          return FutureBuilder<List<Widget>>(
            future: _fetchCandidateWidgets(parties, category),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final candidateWidgets = snapshot.data ?? [];

              return AlertDialog(
                title: Text('Candidates for $category'),
                content: SizedBox(
                  width: 300, // Adjust the width as needed
                  height: 300, // Adjust the height as needed
                  child: candidateWidgets.isNotEmpty
                      ? ListView(children: candidateWidgets)
                      : const Text('No Candidates Found'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

Future<List<Widget>> _fetchCandidateWidgets(
    List<QueryDocumentSnapshot>? parties, String category) async {
  final List<Widget> candidateWidgets = [];

  if (parties != null) {
    for (final party in parties) {
      // Fetch candidates for the current party
      final querySnapshot = await FirebaseFirestore.instance
          .collection('politicalParties')
          .doc(party.id)
          .collection('candidates')
          .where('category', isEqualTo: category)
          .get();

      final candidates = querySnapshot.docs;

      for (final candidate in candidates) {
        final candidateData = candidate.data();
        final candidateDp = candidateData['leaderPicUrl'] as String;
        final candidateName = candidateData['fullName'] as String;
        final candidateCity = candidateData['city'] as String;
        final candidateVotes = candidateData['votes'] as int;

        candidateWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(candidateDp),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'City: $candidateCity',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Votes: $candidateVotes',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  return candidateWidgets;
}
