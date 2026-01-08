import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() { runApp(const MyApp()); }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Clone',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const VideoFeedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});
  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final String serverUrl = "https://tiktok-backend-production-a0aa.up.railway.app/feed";
  List<dynamic> videos = [];
  bool isLoading = true;

  @override
  void initState() { super.initState(); fetchVideos(); }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(serverUrl));
      if (response.statusCode == 200) {
        setState(() { videos = json.decode(response.body); isLoading = false; });
      }
    } catch (e) { print("Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator()) : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) => VideoItem(
          url: videos[index]['url'],
          username: videos[index]['username'] ?? 'User',
          description: videos[index]['description'] ?? '',
          likes: (videos[index]['likes'] ?? 0).toString(),
        ),
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  final String url, username, description, likes;
  const VideoItem({super.key, required this.url, required this.username, required this.description, required this.likes});
  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) {
      setState(() { _initialized = true; _controller.play(); _controller.setLooping(true); });
    });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return _initialized ? VideoPlayer(_controller) : const Center(child: CircularProgressIndicator());
  }
}
