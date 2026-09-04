import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/themes/colors.dart';

/// Lecteur video d'un element du feed.
///
/// Lance la lecture quand l'element est actif, met en pause sinon, et ne charge
/// la video qu'a la demande (economie de donnees). Son coupe par defaut, pilote
/// par [muted]. Poster en fond pendant le chargement / en repli.
class FeedVideoPlayer extends StatefulWidget {
  const FeedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.posterUrl,
    required this.isActive,
    required this.muted,
  });

  final String? videoUrl;
  final String? posterUrl;
  final bool isActive;
  final bool muted;

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initializing = false;

  bool get _hasVideo => widget.videoUrl != null && widget.videoUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.isActive && _hasVideo) _init();
  }

  @override
  void didUpdateWidget(covariant FeedVideoPlayer old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _init();
    } else if (!widget.isActive && old.isActive) {
      _teardown();
    }
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      c.setVolume(widget.muted ? 0 : 1);
      widget.isActive ? c.play() : c.pause();
    }
  }

  Future<void> _init() async {
    if (!_hasVideo || _controller != null || _initializing) return;
    _initializing = true;
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    try {
      await c.initialize();
      c.setLooping(true);
      c.setVolume(widget.muted ? 0 : 1);
      if (!mounted) {
        await c.dispose();
        return;
      }
      _controller = c;
      if (widget.isActive) c.play();
      setState(() {});
    } catch (_) {
      await c.dispose();
    } finally {
      _initializing = false;
    }
  }

  void _teardown() {
    final c = _controller;
    _controller = null;
    c?.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    return Stack(
      fit: StackFit.expand,
      children: [
        _Poster(url: widget.posterUrl),
        if (ready)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
        if (widget.isActive && _hasVideo && !ready)
          const Center(
            child: SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return Container(color: AppColors.ink);
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppColors.ink),
      errorWidget: (_, __, ___) => Container(color: AppColors.ink),
    );
  }
}
