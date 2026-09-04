import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/study_material.dart';
import '../data/subjects.dart';
import '../services/question_service.dart';
import '../services/question_search_service.dart';
import '../services/study_material_loader.dart';
import '../services/study_material_search_service.dart';
import 'review_screen.dart';
import 'study_material/study_material_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Question Search State
  List<Question> _allQuestions = [];
  List<Question> _filteredQuestions = [];
  bool _isLoadingQuestions = true;
  String? _selectedQuestionSubject;
  String? _selectedQuestionTopic;

  // Study Material Search State
  List<StudyMaterial> _allMaterials = [];
  List<StudyMaterial> _filteredMaterials = [];
  bool _isLoadingMaterials = true;
  String? _selectedMaterialSubject;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAllQuestions(),
      _loadAllMaterials(),
    ]);
  }

  Future<void> _loadAllQuestions() async {
    final subjects = technicalSubjects.map((s) => s.name).toList();
    final questions = await QuestionService.loadQuestionsBySubjects(subjects);
    if (mounted) {
      setState(() {
        _allQuestions = questions;
        _filteredQuestions = questions;
        _isLoadingQuestions = false;
      });
    }
  }

  Future<void> _loadAllMaterials() async {
    final materials = await StudyMaterialLoader.loadAllMaterials();
    if (mounted) {
      setState(() {
        _allMaterials = materials;
        _filteredMaterials = materials;
        _isLoadingMaterials = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_tabController.index == 0) {
      _applyQuestionFilters();
    } else {
      _applyMaterialFilters();
    }
  }

  void _applyQuestionFilters() {
    setState(() {
      _filteredQuestions = QuestionSearchService.applyFilters(
        questions: _allQuestions,
        subject: _selectedQuestionSubject,
        topic: _selectedQuestionTopic,
        query: _searchController.text,
      );
    });
  }

  void _applyMaterialFilters() {
    setState(() {
      _filteredMaterials = StudyMaterialSearchService.search(
        materials: _allMaterials,
        query: _searchController.text,
        subject: _selectedMaterialSubject,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Questions', icon: Icon(Icons.quiz)),
            Tab(text: 'Study Material', icon: Icon(Icons.menu_book)),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _tabController.index == 0 
                    ? 'Search questions...' 
                    : 'Search notes, formulas, topics...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionSearchView(),
                _buildMaterialSearchView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSearchView() {
    if (_isLoadingQuestions) return const Center(child: CircularProgressIndicator());
    
    return Column(
      children: [
        _buildQuestionFilterChips(),
        Expanded(
          child: _filteredQuestions.isEmpty
              ? const Center(child: Text('No questions found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final q = _filteredQuestions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          q.question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${q.subject} > ${q.subTopic}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                questions: [q],
                                selectedAnswers: const [null],
                                selectedMSQAnswers: const [[]],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Found ${_filteredQuestions.length} questions'),
        ),
      ],
    );
  }

  Widget _buildMaterialSearchView() {
    if (_isLoadingMaterials) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _buildMaterialFilterChips(),
        Expanded(
          child: _filteredMaterials.isEmpty
              ? const Center(child: Text('No study materials found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredMaterials.length,
                  itemBuilder: (context, index) {
                    final m = _filteredMaterials[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          m.topic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(m.subject),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudyMaterialScreen(material: m),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Found ${_filteredMaterials.length} materials'),
        ),
      ],
    );
  }

  Widget _buildQuestionFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: Text(_selectedQuestionSubject ?? 'All Subjects'),
            selected: _selectedQuestionSubject != null,
            onSelected: (_) => _showQuestionSubjectPicker(),
          ),
          const SizedBox(width: 8),
          if (_selectedQuestionSubject != null)
            FilterChip(
              label: Text(_selectedQuestionTopic ?? 'All Topics'),
              selected: _selectedQuestionTopic != null,
              onSelected: (_) => _showQuestionTopicPicker(),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: Text(_selectedMaterialSubject ?? 'All Subjects'),
            selected: _selectedMaterialSubject != null,
            onSelected: (_) => _showMaterialSubjectPicker(),
          ),
        ],
      ),
    );
  }

  void _showQuestionSubjectPicker() {
    _showSubjectPicker((subject) {
      setState(() {
        _selectedQuestionSubject = subject;
        _selectedQuestionTopic = null;
      });
      _applyQuestionFilters();
    });
  }

  void _showMaterialSubjectPicker() {
    _showSubjectPicker((subject) {
      setState(() {
        _selectedMaterialSubject = subject;
      });
      _applyMaterialFilters();
    });
  }

  void _showSubjectPicker(Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: const Text('All Subjects'),
              onTap: () {
                onSelected(null);
                Navigator.pop(context);
              },
            ),
            ...technicalSubjects.map((s) => ListTile(
                  title: Text(s.name),
                  onTap: () {
                    onSelected(s.name);
                    Navigator.pop(context);
                  },
                )),
          ],
        );
      },
    );
  }

  void _showQuestionTopicPicker() {
    if (_selectedQuestionSubject == null) return;
    
    final topics = _allQuestions
        .where((q) => q.subject == _selectedQuestionSubject)
        .map((q) => q.subTopic)
        .toSet()
        .toList()
        ..sort();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: const Text('All Topics'),
              onTap: () {
                setState(() => _selectedQuestionTopic = null);
                _applyQuestionFilters();
                Navigator.pop(context);
              },
            ),
            ...topics.map((t) => ListTile(
                  title: Text(t),
                  onTap: () {
                    setState(() => _selectedQuestionTopic = t);
                    _applyQuestionFilters();
                    Navigator.pop(context);
                  },
                )),
          ],
        );
      },
    );
  }
}
