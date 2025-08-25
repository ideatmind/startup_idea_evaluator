import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../providers/theme_provider.dart';
import '../widgets/idea_card.dart';
import 'idea_submission_screen.dart';
import 'leaderboard_screen.dart';
import 'auth_screen.dart';

class IdeaListingScreen extends StatefulWidget {
  const IdeaListingScreen({super.key});

  @override
  State<IdeaListingScreen> createState() => _IdeaListingScreenState();
}

class _IdeaListingScreenState extends State<IdeaListingScreen> {
  int _currentIndex = 0;
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadIdeas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          IdeasListView(),
          LeaderboardScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const IdeaSubmissionScreen(),
            ),
          );
          if (res == true && mounted) {
            context.read<AppState>().loadIdeas();
          }
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Idea'),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) {
            context.read<AppState>().loadIdeas();
          }
        },
        selectedItemColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Ideas'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Startup Ideas'),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Theme Toggle Button
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: () {
                themeProvider.toggleTheme();
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  key: ValueKey(themeProvider.isDarkMode),
                ),
              ),
            );
          },
        ),
        // Refresh Button
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => context.read<AppState>().loadIdeas(),
          icon: const Icon(Icons.refresh),
        ),
        // Sort Menu
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() => _sortBy = value);
            context.read<AppState>().sortIdeas(value);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'recent',
              child: Row(children: [Icon(Icons.access_time), SizedBox(width: 8), Text('Recent')]),
            ),
            PopupMenuItem(
              value: 'rating',
              child: Row(children: [Icon(Icons.star), SizedBox(width: 8), Text('AI Rating')]),
            ),
            PopupMenuItem(
              value: 'votes',
              child: Row(children: [Icon(Icons.thumb_up), SizedBox(width: 8), Text('Most Voted')]),
            ),
          ],
          icon: const Icon(Icons.sort),
        ),
        // Logout Button
        IconButton(
          tooltip: 'Logout',
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

class IdeasListView extends StatelessWidget {
  const IdeasListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.purple));
        }

        if (appState.ideas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ideas yet!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text('Be the first to share your startup idea', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => appState.loadIdeas(),
          color: Colors.purple,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.ideas.length,
            itemBuilder: (context, index) {
              final idea = appState.ideas[index];
              final hasVoted = appState.votedIdeas.contains(idea.id);
              return IdeaCard(
                key: Key('idea_${idea.id}'),
                idea: idea,
                hasVoted: hasVoted,
                onVote: (id) => appState.voteForIdea(id),
              );
            },
          ),
        );
      },
    );
  }
}
