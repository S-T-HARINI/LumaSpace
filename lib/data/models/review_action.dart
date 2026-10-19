enum ReviewDecision {
  keep,
  pendingDelete,
}

class ReviewAction {
  final String mediaId;
  final ReviewDecision decision;
  final DateTime timestamp;
  final ReviewDecision? previousDecision;

  const ReviewAction({
    required this.mediaId,
    required this.decision,
    required this.timestamp,
    this.previousDecision,
  });

  Map<String, dynamic> toJson() => {
        'mediaId': mediaId,
        'decision': decision.name,
        'timestamp': timestamp.toIso8601String(),
        'previousDecision': previousDecision?.name,
      };

  factory ReviewAction.fromJson(Map<String, dynamic> json) {
    return ReviewAction(
      mediaId: json['mediaId'] as String,
      decision: ReviewDecision.values.firstWhere(
        (e) => e.name == json['decision'],
        orElse: () => ReviewDecision.keep,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      previousDecision: json['previousDecision'] != null
          ? ReviewDecision.values.firstWhere(
              (e) => e.name == json['previousDecision'],
              orElse: () => ReviewDecision.keep,
            )
          : null,
    );
  }
}
