import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const ProTikTokApp());

class ProTikTokApp extends StatelessWidget {
  const ProTikTokApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;
  // هنا نقوم بتبديل السيرفرات أو الصفحات بسهولة
  final List<Widget> _screens = [const VideoScrollFeed(), const Center(child: Text("Search")), const Center(child: Text("Profile"))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Following", style: TextStyle(fontSize: 16, color: Colors.white60)),
            SizedBox(width: 15),
            Text("For You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Me"),
        ],
      ),
    );
  }
}

class VideoScrollFeed extends StatefulWidget {
  const VideoScrollFeed({super.key});
  @override
  State<VideoScrollFeed> createState() => _VideoScrollFeedState();
}

class _VideoScrollFeedState extends State<VideoScrollFeed> {
  // ✅ رابط السيرفر الذي نتحكم به
  final String api = "https://tiktok-backend-production-a0aa.up.railway.app/feed";
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    final res = await http.get(Uri.parse(api));
    if (res.statusCode == 200) setState(() { items = json.decode(res.body); loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Colors.pink));
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      itemBuilder: (ctx, i) => PlayerItem(url: items[i]['url'], user: items[i]['username'], desc: items[i]['description']),
    );
  }
}

class PlayerItem extends StatefulWidget {
  final String url, user, desc;
  const PlayerItem({super.key, required this.url, required this.user, required this.desc});
  @override
  State<PlayerItem> createState() => _PlayerItemState();
}

class _PlayerItemState extends State<PlayerItem> {
  late VideoPlayerController _vc;
  @override
  void initState() {
    super.initState();
    _vc = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) {
      setState(() {}); _vc.play(); _vc.setLooping(true);
    });
  }
  @override
  void dispose() { _vc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(child: _vc.value.isInitialized ? VideoPlayer(_vc) : const Center(child: CircularProgressIndicator())),
        Positioned(bottom: 20, left: 15, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("@${widget.user}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(widget.desc, style: const TextStyle(fontSize: 14)),
          ],
        )),
        const Positioned(right: 15, bottom: 100, child: Column(
          children: [
            Icon(Icons.favorite, size: 40, color: Colors.white),
            Text("1.2k"),
            SizedBox(height: 20),
            Icon(Icons.comment, size: 40, color: Colors.white),
            Text("45"),
          ],
        ))
      ],
    );
  }
}
