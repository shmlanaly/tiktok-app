import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const InstagramVideoApp());

class InstagramVideoApp extends StatelessWidget {
  const InstagramVideoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const VideoFeed(), const Center(child: Text("Search")), const Center(child: Text("Profile"))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Instagram Video", style: TextStyle(fontFamily: 'Billabong', fontSize: 28)),
        actions: [IconButton(icon: const Icon(Icons.send_rounded), onPressed: () {})],
      ) : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}

class VideoFeed extends StatefulWidget {
  const VideoFeed({super.key});
  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  final String url = "https://tiktok-backend-production-a0aa.up.railway.app/feed";
  List videos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    http.get(Uri.parse(url)).then((res) {
      if (res.statusCode == 200) setState(() { videos = json.decode(res.body); loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      itemBuilder: (context, i) => VideoStack(url: videos[i]['url'], user: videos[i]['username']),
    );
  }
}

class VideoStack extends StatefulWidget {
  final String url, user;
  const VideoStack({super.key, required this.url, required this.user});
  @override
  State<VideoStack> createState() => _VideoStackState();
}

class _VideoStackState extends State<VideoStack> {
  late VideoPlayerController _c;
  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) {
      setState(() {});
      _c.play();
      _c.setLooping(true);
    });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _c.value.isInitialized ? SizedBox.expand(child: VideoPlayer(_c)) : const Center(child: CircularProgressIndicator()),
        Positioned(bottom: 20, left: 10, child: Text("@${widget.user}", style: const TextStyle(fontWeight: FontWeight.bold))),
        const Positioned(right: 10, bottom: 100, child: Column(children: [Icon(Icons.favorite_border, size: 35), SizedBox(height: 20), Icon(Icons.chat_bubble_outline, size: 35)]))
      ],
    );
  }
}
