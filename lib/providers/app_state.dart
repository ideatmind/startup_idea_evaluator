import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../models/idea.dart';

class AppState extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Idea> _ideas = [];
  Set<String> _votedIdeas = {};
  bool _isLoading = false;

  List<Idea> get ideas => _ideas;
  Set<String> get votedIdeas => _votedIdeas;
  bool get isLoading => _isLoading;

  AppState() {
    _bindAuthListener();
    loadIdeas();
  }

  void _bindAuthListener() {
    _supabase.auth.onAuthStateChange.listen((event) async {
      await _onAuthChanged();
    });
  }

  Future<void> _onAuthChanged() async {
    _votedIdeas.clear();
    notifyListeners();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _loadUserVotes();
    }

    await loadIdeas();
  }

  Future<void> _loadUserVotes() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _votedIdeas.clear();
        notifyListeners();
        return;
      }

      final rows = await _supabase
          .from('votes')
          .select('idea_id')
          .eq('user_id', userId);

      _votedIdeas = (rows as List)
          .map((e) => e['idea_id'] as String)
          .toSet();

      notifyListeners();
    } catch (e) {
      _votedIdeas.clear();
      notifyListeners();
    }
  }

  Future<void> loadIdeas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('ideas')
          .select('id, startup_name, tagline, description, ai_rating, vote_count, created_at, user_id')
          .order('created_at', ascending: false);

      _ideas = (response as List)
          .map((json) => Idea.fromJson(json))
          .toList();
    } catch (e) {
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Idea>> loadTopIdeas({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('ideas')
          .select('id, startup_name, tagline, description, ai_rating, vote_count, created_at, user_id')
          .order('vote_count', ascending: false)
          .limit(limit);

      return (response as List).map((e) => Idea.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitIdea({
    required String startupName,
    required String tagline,
    required String description,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final aiRating = Random().nextInt(101);

      final payload = {
        'startup_name': startupName,
        'tagline': tagline,
        'description': description,
        'ai_rating': aiRating,
        'user_id': userId,
      };

      await _supabase.from('ideas').insert(payload);

      await loadIdeas();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> voteForIdea(String ideaId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    if (_votedIdeas.contains(ideaId)) return false;

    try {
      final existing = await _supabase
          .from('votes')
          .select('id')
          .eq('idea_id', ideaId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        _votedIdeas.add(ideaId);
        notifyListeners();
        return false;
      }

      await _supabase.from('votes').insert({
        'idea_id': ideaId,
        'user_id': userId,
      });

      _votedIdeas.add(ideaId);

      final idx = _ideas.indexWhere((i) => i.id == ideaId);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(voteCount: current.voteCount + 1);
      }

      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('duplicate key') || msg.contains('23505')) {
        _votedIdeas.add(ideaId);
        notifyListeners();
      }
      return false;
    }
  }

  void sortIdeas(String sortBy) {
    if (sortBy == 'rating') {
      _ideas.sort((a, b) => b.aiRating.compareTo(a.aiRating));
    } else if (sortBy == 'votes') {
      _ideas.sort((a, b) => b.voteCount.compareTo(a.voteCount));
    } else {
      _ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    notifyListeners();
  }
}
