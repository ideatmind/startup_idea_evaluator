import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class IdeaSubmissionScreen extends StatefulWidget {
  const IdeaSubmissionScreen({super.key});

  @override
  State<IdeaSubmissionScreen> createState() => _IdeaSubmissionScreenState();
}

class _IdeaSubmissionScreenState extends State<IdeaSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _tagline = TextEditingController();
  final _desc = TextEditingController();
  bool _submitting = false;

  void _msg(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Your Idea'), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_name, 'Startup Name', Icons.business, minLen: 2),
                const SizedBox(height: 12),
                _field(_tagline, 'Tagline', Icons.campaign, minLen: 5),
                const SizedBox(height: 12),
                _field(_desc, 'Description', Icons.description, minLen: 20, maxLines: 5),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                    label: Text(_submitting ? 'Submitting...' : 'Submit Idea'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {int minLen = 1, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().length < minLen) {
          return 'Please enter at least $minLen characters';
        }
        return null;
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final app = context.read<AppState>();
    final ok = await app.submitIdea(
      startupName: _name.text.trim(),
      tagline: _tagline.text.trim(),
      description: _desc.text.trim(),
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        _msg('🎉 Idea submitted!');
        Navigator.pop(context, true);
      } else {
        _msg('Failed to submit idea.', error: true);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _tagline.dispose();
    _desc.dispose();
    super.dispose();
  }
}
