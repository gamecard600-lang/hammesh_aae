import '../models/question.dart';
class QuestionValidator {
  static List<String> errors(Question q) {
    final e=<String>[]; if(q.id<=0)e.add('invalid id'); if(q.subject.isEmpty)e.add('missing subject'); if(q.subTopic.isEmpty)e.add('missing subTopic'); if(q.question.isEmpty)e.add('missing question'); if(q.options.length<2)e.add('invalid options'); if(q.options.any((x)=>x.trim().isEmpty))e.add('empty option'); if(q.explanation.isEmpty)e.add('missing explanation'); final a=q.isMSQ?q.correctAnswers:[q.correctAnswer]; if(a.isEmpty)e.add('missing answer'); if(a.any((x)=>x<0||x>=q.options.length))e.add('answer index out of range'); return e; }
  static bool isValid(Question q)=>errors(q).isEmpty;
}
