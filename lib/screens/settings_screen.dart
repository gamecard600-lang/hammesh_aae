import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/local_storage_service.dart';
import '../services/apk_share_service.dart';
import '../services/auto_update_service.dart';
import '../config/app_config.dart';
import 'suggestion_report_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final Function(String mode)? onThemeChanged;

  const SettingsScreen({super.key, this.onDataChanged, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _restoreController = TextEditingController();
  String _currentTheme = 'light';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await LocalStorageService.loadThemeMode();
    if (mounted) {
      setState(() {
        _currentTheme = mode;
      });
    }
  }

  Future<void> _changeTheme(String mode) async {
    await LocalStorageService.saveThemeMode(mode);
    if (mounted) {
      setState(() {
        _currentTheme = mode;
      });
    }
    widget.onThemeChanged?.call(mode);
  }

  void _showBackupDialog() async {
    final json = await LocalStorageService.generateBackupJson();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Data Backup (JSON)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Copy and store this backup text safely:'),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: json),
              maxLines: 5,
              readOnly: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    _restoreController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste your backup JSON text here:'),
            const SizedBox(height: 10),
            TextField(
              controller: _restoreController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Paste JSON here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                if (_restoreController.text.isEmpty) return;
                await LocalStorageService.restoreFromBackupJson(_restoreController.text);
                navigator.pop();
                widget.onDataChanged?.call();
                messenger.showSnackBar(const SnackBar(content: Text('Data restored successfully!')));
              } catch (e) {
                messenger.showSnackBar(const SnackBar(content: Text('Invalid backup data!')));
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _saveAiApiKey(BuildContext dialogContext, String apiKey) {
    Navigator.pop(dialogContext);
    LocalStorageService.saveAiApiKey(apiKey).then((_) {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Key saved successfully!')),
        );
      }
    });
  }

  void _showAiApiKeyDialog() async {
    final currentKey = await LocalStorageService.loadAiApiKey();
    final keyController = TextEditingController(text: currentKey);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🤖 Set Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API Key:\n(Leave empty to use AI Standby/Offline Mode)',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
                labelText: 'Gemini API Key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveAiApiKey(dialogContext, keyController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPersonalNotesPdf() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('note_'));

    final Map<String, String> notes = {};
    for (var k in keys) {
      final val = prefs.getString(k) ?? '';
      if (val.trim().isNotEmpty) {
        final cleanKey = k.replaceFirst('note_', '').replaceAll('_', ' - ');
        notes[cleanKey] = val;
      }
    }

    if (notes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have no saved personal notes yet.')),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('HAMMESH AAE - MY PERSONAL NOTES',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.SizedBox(height: 4),
                  pw.Text('Exported Personal Revision Notes', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            ...notes.entries.map((entry) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.blue50,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(entry.key, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 6),
                      pw.Text(entry.value, style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Generated by Ham\'s AAE App', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'My_Personal_Notes.pdf',
    );
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all exam history, bookmarks, and study progress. Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await LocalStorageService.clearAll();
              navigator.pop();
              widget.onDataChanged?.call();
              messenger.showSnackBar(const SnackBar(content: Text('All progress has been reset!')));
            },
            child: const Text('Yes, Reset'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    ApkShareService.shareInstalledApk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Appearance & Theme',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: Colors.purple),
                  title: const Text('App Theme'),
                  subtitle: Text(_currentTheme == 'dark' ? 'Dark Theme' : 'Light Theme'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'light',
                        label: Text('Light Mode'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'dark',
                        label: Text('Dark Mode'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {_currentTheme},
                    onSelectionChanged: (Set<String> newSelection) {
                      _changeTheme(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '🤖 AI Assistant Configuration',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.key, color: Colors.blue),
                  title: const Text('Configure Gemini API Key'),
                  subtitle: FutureBuilder<String>(
                    future: LocalStorageService.loadAiApiKey(),
                    builder: (context, snapshot) {
                      final key = snapshot.data ?? '';
                      return Text(
                        key.isEmpty
                            ? 'Status: Standby / Offline Mode (Key Not Set)'
                            : 'Status: Live AI Active (${key.substring(0, key.length > 6 ? 6 : key.length)}...)',
                        style: TextStyle(
                          color: key.isEmpty ? Colors.orange : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showAiApiKeyDialog,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Feedback & Support',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined, color: Colors.orange),
                  title: const Text('Suggestions & Report (સૂચન અને રિપોર્ટ)'),
                  subtitle: const Text('Report bugs, wrong MCQ, material errors, or request features'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuggestionReportScreen(currentScreen: 'SettingsScreen'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Data Management',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload, color: Colors.blue),
                  title: const Text('Create Backup (JSON)'),
                  subtitle: const Text('Copy and save your study progress'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showBackupDialog,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.cloud_download, color: Colors.green),
                  title: const Text('Restore Backup'),
                  subtitle: const Text('Restore progress from backup JSON'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showRestoreDialog,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.purple),
                  title: const Text('Export Personal Notes PDF'),
                  subtitle: const Text('Generate PDF of your saved revision notes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _exportPersonalNotesPdf,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.red),
                  title: const Text('Reset All Progress', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Clear test history, bookmarks and progress'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _confirmResetProgress,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'About & Share',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.engineering, color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'hammesh_aae',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'GSSSB AAE Mechanical Companion',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('v1.0.0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.share, color: Colors.blue),
                    title: const Text('Share App with Aspirants'),
                    subtitle: const Text('Share with fellow GSSSB AAE exam candidates'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _shareApp,
                  ),
                  const Divider(),
                  FutureBuilder<int>(
                    future: AutoUpdateService.getLocalContentVersion(),
                    builder: (context, snapshot) {
                      final contentVer = snapshot.data ?? AppConfig.defaultContentVersion;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.system_update_alt, color: Colors.indigo),
                        title: const Text('Automatic Background Updates'),
                        subtitle: Text('App v${AppConfig.currentAppVersion} • Content v$contentVer (Auto Sync Active)'),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          tooltip: 'Check background update',
                          onPressed: () {
                            AutoUpdateService.checkForUpdates(force: true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Checking background updates silently...')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Made by Hammesh Vasoya',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
