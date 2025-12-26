class SearchLog {
  final int? id;
  final String method;
  final int price;
  final int executionTimeUs;
  final int steps;
  final String timestamp;

  SearchLog({
    this.id,
    required this.method,
    required this.price,
    required this.executionTimeUs,
    required this.steps,
    required this.timestamp,
  });

  factory SearchLog.fromMap(Map<String, dynamic> map) {
    return SearchLog(
      id: map['id'],
      method: map['method'],
      price: map['price'],
      executionTimeUs: map['execution_time_us'],
      steps: map['steps'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method,
      'price': price,
      'execution_time_us': executionTimeUs,
      'steps': steps,
      'timestamp': timestamp,
    };
  }
}
