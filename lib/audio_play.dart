import 'package:just_audio/just_audio.dart';

import 'package:wattconversion/const_value.dart';

class AudioPlay {
  static final List<AudioPlayer> _player01 = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  int _player01Ptr = 0;

  double _soundVolume = 0.0;

  AudioPlay() {
    constructor();
  }
  void constructor() async {
    for (int i = 0; i < _player01.length; i++) {
      await _player01[i].setVolume(0);
      await _player01[i].setAsset(ConstValue.audioHiyoko[i]);
    }
    playZero();
  }
  void dispose() {
    for (int i = 0; i < _player01.length; i++) {
      _player01[i].dispose();
    }
  }
  double get soundVolume {
    return _soundVolume;
  }
  set soundVolume(double vol) {
    _soundVolume = vol;
  }
  void playZero() async {
    AudioPlayer ap = AudioPlayer();
    await ap.setAsset(ConstValue.audioZero);
    await ap.load();
    await ap.play();
  }
  //
  void play01() async {
    if (_soundVolume == 0) {
      return;
    }
    _player01Ptr += 1;
    if (_player01Ptr >= _player01.length) {
      _player01Ptr = 0;
    }
    await _player01[_player01Ptr].setVolume(_soundVolume);
    await _player01[_player01Ptr].pause();
    await _player01[_player01Ptr].seek(Duration.zero);
    await _player01[_player01Ptr].play();
  }
}
