import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'notification_service.dart';

class PersistentRadioPlayer extends StatefulWidget {
  const PersistentRadioPlayer({super.key});

  @override
  _PersistentRadioPlayerState createState() => _PersistentRadioPlayerState();
}

class _PersistentRadioPlayerState extends State<PersistentRadioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource('https://stream.zeno.fm/3u4rvdaxhrhvv'));
        await NotificationService().showNotificationWithControls(true);
      }

      if (mounted) {
        setState(() {
          _isPlaying = !_isPlaying;
        });
      }

      // Actualiza la notificación
      await NotificationService().showNotificationWithControls(_isPlaying);
    } catch (e) {
      print('Error al reproducir/pausar audio: $e');
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
    await NotificationService().cancelAllNotifications();
  }

  @override
  void initState() {
    super.initState();
    NotificationService().init();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    NotificationService().cancelAllNotifications();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: GestureDetector(
        onTap: _togglePlayback, //Detectar toques en todo el área
        child: Container(
          height: 80,
          color: const Color(0xFF0B375E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'assets/logo_el_contraste_radio.png',
                width: 100,
                height: 100,
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emisora Contraste',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'En vivo ahora',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                onPressed: _togglePlayback,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              IconButton(
                onPressed: _stopPlayback,
                icon: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
