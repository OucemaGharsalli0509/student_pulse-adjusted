import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;



class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2f887d),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance.collection('form_questions').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      final questions = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final title = questions[index].get('title');

                          return Card(
                            color: Color(0xff2f887d),
                            elevation: 2.0,
                            margin: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth * 0.1, // Adjust horizontal margin based on available width
                              vertical: 8.0,
                            ),
                            child: ListTile(
                              title: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BarChartScreen(title: title),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BarChartScreen extends StatefulWidget {
  final String title;

  const BarChartScreen({required this.title});

  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  List<charts.Series<SentimentData, String>> _seriesList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final formRef = FirebaseFirestore.instance.collection('forms');

    final querySnapshot = await formRef.where('title', isEqualTo: widget.title).get();
    final forms = querySnapshot.docs;

    int satisfiedCount = 0;
    int notSatisfiedCount = 0;

    for (var form in forms) {
      final sentiment = form.get('sentiment');
      if (sentiment == 'Satisfied') {
        satisfiedCount++;
      } else if (sentiment == 'Not satisfied') {
        notSatisfiedCount++;
      }
    }

    final total = satisfiedCount + notSatisfiedCount;

    final data = [
      SentimentData('Satisfied', (satisfiedCount / total) * 100, Colors.green),
      SentimentData('Not Satisfied', (notSatisfiedCount / total) * 100, Colors.red),
    ];

    setState(() {
      _seriesList = [
        charts.Series<SentimentData, String>(
          id: 'Sentiment',
          domainFn: (SentimentData data, _) => data.sentiment,
          measureFn: (SentimentData data, _) => data.percentage,
          data: data,
          colorFn: (SentimentData data, _) => charts.ColorUtil.fromDartColor(data.color),
          labelAccessorFn: (SentimentData data, _) => '${data.percentage}%',
        )
      ];
    });
  }

  void _navigateToFeedbacksScreen(String sentiment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbacksScreen(sentiment: sentiment, title: widget.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: charts.BarChart(
          _seriesList,
          animate: true,
          barGroupingType: charts.BarGroupingType.grouped,
          vertical: true,
          domainAxis: charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                fontSize: 14,
              ),
            ),
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                fontSize: 14,
              ),
            ),
          ),
          barRendererDecorator: charts.BarLabelDecorator<String>(
            insideLabelStyleSpec: charts.TextStyleSpec(
              fontSize: 14,
              color: charts.Color.black,
            ),
            outsideLabelStyleSpec: charts.TextStyleSpec(
              fontSize: 14,
              color: charts.Color.black,
            ),
          ),
          defaultRenderer: charts.BarRendererConfig(
            groupingType: charts.BarGroupingType.grouped,
            strokeWidthPx: 2.0,
            barRendererDecorator: charts.BarLabelDecorator<String>(
              insideLabelStyleSpec: charts.TextStyleSpec(
                fontSize: 18,
                color: charts.Color.white,
              ),
              outsideLabelStyleSpec: charts.TextStyleSpec(
                fontSize: 18,
                color: charts.Color.black,
              ),
            ),
          ),
          selectionModels: [
            charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: (model) {
                if (model.hasDatumSelection && model.selectedDatum.isNotEmpty) {
                  final selectedDatum = model.selectedDatum.first;
                  final sentiment = selectedDatum.datum.sentiment;

                  if (sentiment == 'Satisfied') {
                    _navigateToFeedbacksScreen(sentiment);
                  } else if (sentiment == 'Not Satisfied') {
                    _navigateToFeedbacksScreen(sentiment);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SentimentData {
  final String sentiment;
  final double percentage;
  final MaterialColor color;

  SentimentData(this.sentiment, this.percentage, this.color);
}

class FeedbacksScreen extends StatelessWidget {
  final String sentiment;
  final String title;

  const FeedbacksScreen({required this.sentiment, required this.title});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('forms')
          .where('sentiment', isEqualTo: sentiment)
          .where('title', isEqualTo: title)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final feedbacks = snapshot.data!.docs;

          return Scaffold(
            appBar: AppBar(
              title: Text('Feedbacks - $sentiment'),
            ),
            body: ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index].data() as Map<String, dynamic>?;

                if (feedback != null) {
                  final message = feedback['feedback'] as String?;
                  final user = feedback['user'] as String?;

                  return ListTile(
                    title: Text(message ?? ''),
                    subtitle: Text('User: ${user ?? ''}'),
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        } else {
          return Center(
            child: Text('No feedbacks found'),
          );
        }
      },
    );
  }
}
