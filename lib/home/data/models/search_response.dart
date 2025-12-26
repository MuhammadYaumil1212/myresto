import 'Restaurant.dart';

class SearchResponse {
  final Restaurant? data;
  final int executionTimeUs;
  final int steps;

  SearchResponse({
    this.data,
    required this.executionTimeUs,
    required this.steps,
  });
}
