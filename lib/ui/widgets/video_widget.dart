import 'package:flutter/material.dart';
import 'package:better_player_enhanced/better_player.dart';

class BetterVideoWidget extends StatefulWidget {
  final String videoUrl;

  const BetterVideoWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<BetterVideoWidget> createState() => _BetterVideoWidgetState();
}

class _BetterVideoWidgetState extends State<BetterVideoWidget> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 10 * 1024 * 1024, // 10MB
        maxCacheSize: 100 * 1024 * 1024, // 100MB
        maxCacheFileSize: 10 * 1024 * 1024,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true, // Puedes cambiar a false si no quieres loop
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePlayPause: true,
          showControlsOnInitialize: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _betterPlayerController),
    );
  }
}
