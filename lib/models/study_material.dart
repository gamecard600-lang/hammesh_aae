class VisualLearning {
  final bool enabled;
  final bool visualRequired;
  final String type; // cycle, animation, diagram, graph, process, mechanism, none
  final String animationKey; // carnot_cycle, otto_cycle, centrifugal_pump, etc.
  final String title;
  final String purpose;
  final String mobileLayout;
  final List<String> sequence;
  final List<String> diagrams; // pv, ts, ph, schematic, component
  final String rule;
  final String? videoUrl;
  final String? imageUrl;

  VisualLearning({
    required this.enabled,
    required this.visualRequired,
    required this.type,
    required this.animationKey,
    required this.title,
    required this.purpose,
    required this.mobileLayout,
    required this.sequence,
    required this.diagrams,
    required this.rule,
    this.videoUrl,
    this.imageUrl,
  });

  factory VisualLearning.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return VisualLearning(
        enabled: false,
        visualRequired: false,
        type: 'none',
        animationKey: '',
        title: '',
        purpose: '',
        mobileLayout: '',
        sequence: [],
        diagrams: [],
        rule: '',
        videoUrl: null,
        imageUrl: null,
      );
    }
    List<String> safeList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    final bool isEnabled = json['enabled'] as bool? ?? json['visualRequired'] as bool? ?? false;

    return VisualLearning(
      enabled: isEnabled,
      visualRequired: isEnabled,
      type: json['type'] as String? ?? (isEnabled ? 'animation' : 'none'),
      animationKey: json['animationKey'] as String? ?? json['animation'] as String? ?? '',
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      mobileLayout: json['mobileLayout'] as String? ?? '',
      sequence: safeList(json['sequence']),
      diagrams: safeList(json['diagrams']),
      rule: json['rule'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'visualRequired': visualRequired,
      'type': type,
      'animationKey': animationKey,
      'title': title,
      'purpose': purpose,
      'mobileLayout': mobileLayout,
      'sequence': sequence,
      'diagrams': diagrams,
      'rule': rule,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class StudyMaterial {
  final int id;
  final String subject;
  final String topic;
  final String title;
  final String overview;
  final String concept;
  final List<String> definitions;
  final String detailedTheory;
  final List<String> keyPoints;
  final List<String> formulas;
  final List<String> solvedExamples;
  final List<String> importantPoints;
  final List<String> examPoints;
  final List<String> commonMistakes;
  final List<String> quickRevision;
  final VisualLearning? visualLearning;

  final List<String> mcqs;
  final List<String> msqs;

  StudyMaterial({
    required this.id,
    required this.subject,
    required this.topic,
    required this.title,
    required this.overview,
    required this.concept,
    required this.definitions,
    required this.detailedTheory,
    required this.keyPoints,
    required this.formulas,
    required this.solvedExamples,
    required this.importantPoints,
    required this.examPoints,
    required this.commonMistakes,
    required this.quickRevision,
    this.visualLearning,
    required this.mcqs,
    required this.msqs,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    List<String> safeList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    return StudyMaterial(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subject: json['subject'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      concept: json['concept'] as String? ?? '',
      definitions: safeList(json['definitions']),
      detailedTheory: json['detailedTheory'] as String? ?? '',
      keyPoints: safeList(json['keyPoints']),
      formulas: safeList(json['formulas']),
      solvedExamples: safeList(json['solvedExamples']),
      importantPoints: safeList(json['importantPoints']),
      examPoints: safeList(json['examPoints']),
      commonMistakes: safeList(json['commonMistakes']),
      quickRevision: safeList(json['quickRevision']),
      visualLearning: json['visualLearning'] != null
          ? VisualLearning.fromJson(Map<String, dynamic>.from(json['visualLearning']))
          : null,
      mcqs: safeList(json['mcqs']),
      msqs: safeList(json['msqs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'title': title,
      'overview': overview,
      'concept': concept,
      'definitions': definitions,
      'detailedTheory': detailedTheory,
      'keyPoints': keyPoints,
      'formulas': formulas,
      'solvedExamples': solvedExamples,
      'importantPoints': importantPoints,
      'examPoints': examPoints,
      'commonMistakes': commonMistakes,
      'quickRevision': quickRevision,
      if (visualLearning != null) 'visualLearning': visualLearning!.toJson(),
      'mcqs': mcqs,
      'msqs': msqs,
    };
  }
}
