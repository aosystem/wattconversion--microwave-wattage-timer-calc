import 'package:flutter/material.dart';

import 'package:wattconversion/parse_locale_tag.dart';
import 'package:wattconversion/theme_mode_number.dart';
import 'package:wattconversion/l10n/app_localizations.dart';
import 'package:wattconversion/const_value.dart';
import 'package:wattconversion/setting_page.dart';
import 'package:wattconversion/ad_manager.dart';
import 'package:wattconversion/ad_banner_widget.dart';
import 'package:wattconversion/model.dart';
import 'package:wattconversion/audio_play.dart';
import 'package:wattconversion/loading_screen.dart';
import 'package:wattconversion/theme_color.dart';
import 'package:wattconversion/main.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> with SingleTickerProviderStateMixin {
  late AdManager _adManager;
  final AudioPlay _audioPlay = AudioPlay();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _showBackImage = true;
  int _backImageNumber = 0;
  int _lastBackImageNumber = 0;
  int _wattFrom = 600;
  int _wattTo = 500;
  int _minute = 5;
  int _second = 0;
  //
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;


  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    _audioPlay.playZero();
    final int subSecond = (DateTime.now()).millisecondsSinceEpoch ~/ 100;
    _backImageNumber = subSecond % ConstValue.imageBacks.length;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    _backImageChange();
    //
    _showBackImage = Model.showBackImage;
    _audioPlay.soundVolume = Model.soundVolume;
    _wattFrom = Model.wattFrom;
    _wattTo = Model.wattTo;
    _minute = Model.minute;
    _second = Model.second;
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  Future<void> _onOpenSetting() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingPage()),
    );
    if (!mounted) {
      return;
    }
    if (updated == true) {
      _showBackImage = Model.showBackImage;
      _audioPlay.soundVolume = Model.soundVolume;
      final mainState = context.findAncestorStateOfType<MainAppState>();
      if (mainState != null) {
        mainState
          ..themeMode = ThemeModeNumber.numberToThemeMode(Model.themeNumber)
          ..locale = parseLocaleTag(Model.languageCode)
          ..setState(() {});
      }
      _isFirst = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Scaffold(
        body: LoadingScreen(),
      );
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(themeNumber: Model.themeNumber, context: context);
    }
    final AppLocalizations l = AppLocalizations.of(context)!;
    final TextTheme t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: _themeColor.mainBackColor,
      ),
      child: Container(
        decoration: _decoration2(),
        child: Container(
          decoration: _decoration1(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: _themeColor.mainHeaderColor,
              foregroundColor: _themeColor.mainForeColor,
              title: Text(l.title, style: t.bodySmall),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _onOpenSetting,
                ),
                const SizedBox(width:10),
              ],
            ),
            body: SafeArea(
              child: GestureDetector(
                onTap: () {
                  _audioPlay.play01();
                  _backImageChange();
                },
                child: Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 100),
                        child: Column(children: [
                          _content(),
                        ])
                      )
                    )
                  ),
                ])
              )
            ),
            bottomNavigationBar: AdBannerWidget(adManager: _adManager),
          )
        )
      )
    );
  }
  Decoration _decoration1() {
    if (_showBackImage) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ConstValue.imageBacks[_backImageNumber]),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: _opacityAnimation.value),
            BlendMode.dstATop,
          ),
        )
      );
    } else {
      return const BoxDecoration();
    }
  }
  Decoration _decoration2() {
    if (_showBackImage) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ConstValue.imageBacks[_lastBackImageNumber]),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const BoxDecoration();
    }
  }
  void _backImageChange() {
    final int subSecond = (DateTime.now()).millisecondsSinceEpoch ~/ 100;
    _backImageNumber = subSecond % ConstValue.imageBacks.length;
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _lastBackImageNumber = _backImageNumber;
      _animationController.reverse();
    });
  }

  Widget _content() {
    return Column(children:[
      _widgetWattFrom(),
      _widgetMinute(),
      _widgetSecond(),
      _widgetWattTo(),
      _widgetResult(),
    ]);
  }

  Widget _widgetWattFrom() {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 0),
        color: _themeColor.mainBackColorMono.withValues(alpha: 0.9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 0, bottom: 0),
                child: Row(children: [
                  Text(l.wattFrom, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: _themeColor.mainFromColor)),
                  const Spacer(),
                ])
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 0, bottom: 0),
                child: Row(children: <Widget>[
                  Container(
                    color: _themeColor.mainBackColorMono,
                    child: SizedBox(
                      width: 80,
                      child: Text(_wattFrom.toString(),textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainFromColor)
                      ),
                    )
                  ),
                  Expanded(
                    child: Slider(
                      value: _wattFrom.toDouble(),
                      min: 300,
                      max: 1800,
                      divisions: 15,
                      label: _wattFrom.toString(),
                      activeColor: _themeColor.mainFromColor,
                      onChanged: (double value) {
                        setState(() {
                          _wattFrom = value.toInt();
                          Model.setWattFrom(_wattFrom);
                        });
                      },
                    )
                  )
                ])
              )
            ]
          ),
        ),
      )
    );
  }

  Widget _widgetMinute() {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 4, top: 3, right: 4, bottom: 0),
        color: _themeColor.mainBackColorMono.withValues(alpha: 0.9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 0, bottom: 0),
                child: Row(children: [
                  Text(l.fromMinute, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: _themeColor.mainFromColor)),
                  const Spacer(),
                ])
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 0, bottom: 0),
                child: Row(children: <Widget>[
                  Container(
                    color: _themeColor.mainBackColorMono,
                    child: SizedBox(
                      width: 80,
                      child: Text(_minute.toString(),textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainFromColor)
                      ),
                    )
                  ),
                  Expanded(
                    child: Slider(
                      value: _minute.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: _minute.toString(),
                      activeColor: _themeColor.mainFromColor,
                      onChanged: (double value) {
                        setState(() {
                          _minute = value.toInt();
                          Model.setMinute(_minute);
                        });
                      },
                    )
                  )
                ])
              )
            ]
          ),
        ),
      )
    );
  }

  Widget _widgetSecond() {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 4, top: 3, right: 4, bottom: 0),
        color: _themeColor.mainBackColorMono.withValues(alpha: 0.9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 0, bottom: 0),
                child: Row(children: [
                  Text(l.fromSecond, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: _themeColor.mainFromColor)),
                  const Spacer(),
                ])
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 0, bottom: 0),
                child: Row(children: <Widget>[
                  Container(
                    color: _themeColor.mainBackColorMono,
                    child: SizedBox(
                      width: 80,
                      child: Text(_second.toString(),textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainFromColor)
                      ),
                    )
                  ),
                  Expanded(
                    child: Slider(
                      value: _second.toDouble(),
                      min: 0,
                      max: 50,
                      divisions: 5,
                      label: _second.toString(),
                      activeColor: _themeColor.mainFromColor,
                      onChanged: (double value) {
                        setState(() {
                          _second = value.toInt();
                          Model.setSecond(_second);
                        });
                      },
                    )
                  )
                ])
              )
            ]
          ),
        ),
      )
    );
  }

  Widget _widgetWattTo() {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 4, top: 12, right: 4, bottom: 0),
        color: _themeColor.mainBackColorMono.withValues(alpha: 0.9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 0, bottom: 0),
                child: Row(children: [
                  Text(l.wattTo, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: _themeColor.mainToColor)),
                  const Spacer(),
                ])
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 0, bottom: 0),
                child: Row(children: <Widget>[
                  Container(
                    color: _themeColor.mainBackColorMono,
                    child: SizedBox(
                      width: 80,
                      child: Text(_wattTo.toString(),textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainToColor)
                      ),
                    )
                  ),
                  Expanded(
                    child: Slider(
                      value: _wattTo.toDouble(),
                      min: 300,
                      max: 1800,
                      divisions: 15,
                      label: _wattTo.toString(),
                      activeColor: _themeColor.mainToColor,
                      onChanged: (double value) {
                        setState(() {
                          _wattTo = value.toInt();
                          Model.setWattTo(_wattTo);
                        });
                      },
                    )
                  )
                ])
              ),
            ]
          ),
        ),
      )
    );
  }

  Widget _widgetResult() {
    final l = AppLocalizations.of(context)!;
    final int sec = ((_minute * 60 + _second) / _wattTo * _wattFrom).toInt();
    final int answerMinute = (sec / 60).floor();
    final int answerSecond = sec % 60;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 4, top: 12, right: 4, bottom: 0),
        color: _themeColor.mainBackColorMono.withValues(alpha: 0.9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(children: [
                const Spacer(),
                Text('${l.specified} ${_wattFrom}W',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainFromColor),
                ),
                const Spacer(),
              ]),
              Row(children: [
                const Spacer(),
                Text('${_minute} ${l.minute} ${_second} ${l.second}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainFromColor),
                ),
                const Spacer(),
              ]),
              SizedBox(height: 5),
              Row(children: [
                const Spacer(),
                Text('${l.conversion} ${_wattTo}W',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainToColor),
                ),
                const Spacer(),
              ]),
              Row(children: [
                const Spacer(),
                Text('${answerMinute} ${l.minute} ${answerSecond} ${l.second}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _themeColor.mainToColor),
                ),
                const Spacer(),
              ])
            ]
          ),
        ),
      )
    );
  }

}
