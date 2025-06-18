import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';

class PersistentRadioPlayer extends StatefulWidget {
  const PersistentRadioPlayer({super.key});

  @override
  _PersistentRadioPlayerState createState() => _PersistentRadioPlayerState();
}

class _PersistentRadioPlayerState extends State<PersistentRadioPlayer> {
  late AudioHandler _audioHandler;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.elcontraste.radio',
        androidNotificationChannelName: 'El Contraste Radio',
        androidNotificationOngoing: true,
      ),
    );

    AudioService.playbackStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _audioHandler.pause();
    } else {
      _audioHandler.play();
    }
  }

  void _stopPlayback() {
    _audioHandler.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: GestureDetector(
        onTap: _togglePlayback,
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