import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide LegendPosition;

class Candidate {
  final String fullName;
  final String politicalParty;
  final String partySymbolUrl;
  final int votes;

  Candidate({
    required this.fullName,
    required this.politicalParty,
    required this.partySymbolUrl,
    required this.votes,
  });
}

class VotingResults extends StatefulWidget {
  const VotingResults({super.key});

  @override
  State<VotingResults> createState() => _VotingResultsState();
}

class _VotingResultsState extends State<VotingResults> {
  Map<String, List<Candidate>> partyCandidates = {};

  Map<String, List<Candidate>> getTotalVotes(
      List<QueryDocumentSnapshot> documents) {
    partyCandidates.clear();
    // Map<String, List<Candidate>> partyCandidates = {};

    for (var document in documents) {
      final data = document.data() as Map<String, dynamic>;
      final fullName = data['fullName'] as String;
      final politicalParty = data['politicalParty'] as String;
      final partySymbolUrl = data['partySymbolUrl'] as String;
      final votes = data['votes'] as int;

      final candidate = Candidate(
        fullName: fullName,
        politicalParty: politicalParty,
        partySymbolUrl: partySymbolUrl,
        votes: votes,
      );

      if (partyCandidates.containsKey(politicalParty)) {
        partyCandidates[politicalParty]!.add(candidate);
      } else {
        partyCandidates[politicalParty] = [candidate];
      }
    }

    return partyCandidates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voting Results"),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                height: 150.0,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('candidates')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final Set<String> uniqueCategories = {};
                    final List<Color> categoryColors = [
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.purple,
                    ];

                    for (final QueryDocumentSnapshot document
                        in snapshot.data!.docs) {
                      final Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      final String category = data['category'] as String;
                      uniqueCategories.add(category);
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: uniqueCategories.length,
                      itemBuilder: (BuildContext context, int index) {
                        final List<String> categories =
                            uniqueCategories.toList();
                        final String category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  final List<Map<String, dynamic>>
                                      sortedCandidates = [];
                                  for (final QueryDocumentSnapshot document
                                      in snapshot.data!.docs) {
                                    if ((document.data()
                                                    as Map<String, dynamic>?)
                                                ?.containsKey('category') ==
                                            true &&
                                        (document.data() as Map<String,
                                                dynamic>?)?['category'] ==
                                            category) {
                                      sortedCandidates.add({
                                        'votes': (document.data() as Map<String,
                                                dynamic>?)?['votes'] ??
                                            0,
                                        'widget': ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              (document.data() as Map<String,
                                                              dynamic>?)?[
                                                          'leaderPicUrl']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          ),
                                          title: Text(
                                            (document.data() as Map<String,
                                                        dynamic>?)?['fullName']
                                                    ?.toString() ??
                                                '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Political Party: ${((document.data() as Map<String, dynamic>?)?['politicalParty']?.toString()) ?? ''}'),
                                              Text(
                                                  'City: ${((document.data() as Map<String, dynamic>?)?['city']?.toString()) ?? ''}'),
                                              Text(
                                                  'Votes: ${((document.data() as Map<String, dynamic>?)?['votes']?.toString()) ?? ''}'),
                                            ],
                                          ),
                                        ),
                                      });
                                    }
                                  }
                                  sortedCandidates.sort((a, b) =>
                                      b['votes'].compareTo(a['votes']));

                                  return AlertDialog(
                                    title: Text('Candidates for $category'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          for (final candidate
                                              in sortedCandidates)
                                            candidate['widget'],
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  categoryColors[index % categoryColors.length],
                            ),
                            child: Text(category),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('candidates')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final Map<String, List<Candidate>> partyCandidates =
                    getTotalVotes(snapshot.data!.docs);

                final Map<String, num> partyVotes = {};

                partyCandidates.forEach((party, candidates) {
                  final totalVotes = candidates.fold<int>(
                      0,
                      (previousValue, candidate) =>
                          previousValue + candidate.votes);
                  partyVotes[party] = totalVotes;
                });

                getTotalVotes(snapshot.data!.docs).cast<String, num>();

                final List<Map<String, dynamic>> chartData = [];
                final List<Map<String, dynamic>> barData = [];
                final List<Color> barColors = [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                ];

                for (final party in partyVotes.keys) {
                  final totalVotes = partyVotes[party];

                  chartData.add({'party': party, 'votes': totalVotes});
                  barData.add({'party': party, 'votes': totalVotes});
                }

                final sortedPartyVotes = partyVotes.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Padding(
                  padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: sortedPartyVotes.length,
                          itemBuilder: (BuildContext context, int index) {
                            final party = sortedPartyVotes[index].key;
                            final totalVotes = sortedPartyVotes[index].value;

                            // For simplicity, we'll take the first candidate's symbol URL as the party symbol URL.
                            final partySymbolUrl =
                                partyCandidates[party]![0].partySymbolUrl;

                            return IntrinsicWidth(
                              stepWidth: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Card(
                                  color: const Color(0xFF7D91D2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 55,
                                        backgroundImage:
                                            NetworkImage(partySymbolUrl),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        party,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Total Votes: $totalVotes',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelRotation: 90,
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                            title: AxisTitle(
                              text: 'Political Parties',
                              textStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          primaryYAxis: CategoryAxis(
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                            title: AxisTitle(
                              text: 'Votes',
                              textStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // series: <ChartSeries>[
                          //   ColumnSeries<Map<String, dynamic>, String>(
                          //     dataSource: barData,
                          //     xValueMapper: (Map<String, dynamic> data, _) =>
                          //         data['party'] as String,
                          //     yValueMapper: (Map<String, dynamic> data, _) =>
                          //         data['votes'] as num,
                          //     pointColorMapper:
                          //         (Map<String, dynamic> data, index) =>
                          //             barColors[index % barColors.length],
                          //   ),
                          // ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PieChart(
                          dataMap: chartData.fold<Map<String, double>>(
                            {},
                            (previousValue, element) => {
                              ...previousValue,
                              element['party']: element['votes'].toDouble(),
                            },
                          ),
                          chartRadius: MediaQuery.of(context).size.width / 1,
                          chartType: ChartType.disc,
                          chartLegendSpacing: 10,
                          centerText: "Votes",
                          animationDuration: const Duration(milliseconds: 1200),
                          colorList: barColors,
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
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
